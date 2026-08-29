# Implementation — ring-oscillator PLL

What is actually built, what it measures, and what is deliberately not in this
revision. The design intent is in [`proposal.md`](proposal.md); this file records the
schematic that realises it.

## Cell hierarchy

| Cell | What it does | Schematic |
| --- | --- | --- |
| `cs_inv` | One current-starved inverter stage | [SVG](schematics/cs_inv.svg) |
| `rosc_vco` | 7-stage ring with bias mirror, matched loading, buffered tap | [SVG](schematics/rosc_vco.svg) |
| `pfd` | Tri-state phase-frequency detector, two flops with a POR-gated reset | [SVG](schematics/pfd.svg) |
| `charge_pump` | Current-steering pump, mirrored from the harness bias line | [SVG](schematics/charge_pump.svg) |
| `loop_filter` | Type-II RC filter — the baseline | [SVG](schematics/loop_filter.svg) |
| `loop_filter_lownoise` | Dual-path small-capacitor alternative | [SVG](schematics/loop_filter_lownoise.svg) |
| `divn` | Programmable feedback divider, ÷2 ÷4 ÷8 ÷16 | [SVG](schematics/divn.svg) |
| `pll_rosc` | Top level | [SVG](schematics/pll_rosc.svg) |

## VCO tuning curve — measured on the loaded ring

`sim/tb_vco_sweep.spice` sweeps the control voltage and measures the oscillation frequency
on the real cell, with its output tap and matched per-stage dummy loads.

| vctrl | f_out | local Kvco |
| --- | --- | --- |
| 0.60 V | 115.4 MHz | 1411 MHz/V |
| 0.70 V | 256.6 MHz | 1653 MHz/V |
| 0.80 V | 421.8 MHz | 1382 MHz/V |
| 0.90 V | 560.0 MHz | 885 MHz/V |
| 1.00 V | 648.5 MHz | 540 MHz/V |
| 1.10 V | 702.5 MHz | 349 MHz/V |
| 1.20 V | 737.4 MHz | — |

⚠️ **The specification's 1 GHz upper limit is not reached.** Loaded, the ring tops out at
**737 MHz with the control voltage at the 1.2 V supply rail**. The 957 MHz figure in the
proposal was measured on a bare ring driving nothing, which is not a shippable
configuration. The achievable output band is **115–737 MHz**.

**Kvco varies 4.7× across the range** (349–1653 MHz/V). That is a loop-design constraint,
not a curiosity: loop gain is proportional to Kvco, so the filter has to hold margin across
the whole spread.

## Loop filter — designed against that curve

Open loop is `T(s) = (Icp·Kvco/N)·Z(s)/s`, with the filter contributing a zero at
`1/(Rz·Cz)` and a pole at `(Cz+Cp)/(Rz·Cz·Cp)`. Two things move inside it — Kvco across
4.7×, and N with the divider setting — so the zero and pole are placed symmetrically about
the crossover in log frequency, centred on the geometric-mean loop gain.

| | value | drawn as |
| --- | --- | --- |
| Icp | 1 µA | mirrored 1:1 from the harness bias |
| Rz | 80.8 kΩ | `rhigh`, w = 1 µm, l = 56.9 µm |
| Cz | 9.21 pF | `cap_mfringe`, 63 × 63 µm — **3.1 % of the slot** |
| Cp | 0.75 pF | `cap_mfringe`, 18 × 18 µm |

**Worst-case phase margin is 48.6°** across every selectable operating point, against a 45°
minimum, and the crossover stays below f_ref/10 everywhere.

`Icp = 1 µA` is a requirement on the harness bias rather than a device size here, since the
charge pump mirrors 1:1. It is also the direction that shrinks the filter: required
capacitance scales as Icp/fc².

## Divider range — what is actually usable

`f_out = N × f_ref`, and the specification limits f_ref to 10–50 MHz. Against the measured
VCO band that constrains which taps can be used at all:

| Tap | Reference it would need | Usable? |
| --- | --- | --- |
| ÷2 | 128–369 MHz | no |
| ÷4 | 64–184 MHz | no |
| ÷8 | 32–92 MHz | yes, over 32–50 MHz |
| ÷16 | 16–46 MHz | yes |

⚠️ **The ÷2 and ÷4 settings cannot be used with a reference in the specified range** — they
would need a reference far above 50 MHz. ÷8 and ÷16 together cover the whole achievable
output band, so the block is usable, but **the practical reference range narrows to
16–50 MHz** rather than the specified 10–50 MHz.

Extending the taps to ÷32/÷64 was evaluated and rejected: it widens the loop-gain spread
past what a single fixed filter can cover while still respecting fc ≤ f_ref/10.

## The loop filter alternative

The loop-filter capacitor is what the slot budget is spent on. Two filters are carried
so the choice can be made on measurements rather than on argument:

**`loop_filter` (in use).** The type-II RC designed above. Sizing it from the measured
tuning curve rather than from a round number brought the zero capacitor to 9.21 pF —
63 × 63 µm, about 3.1 % of a 520 × 250 µm slot. The area problem the proposal anticipated
is largely answered by designing the loop properly; it does not need an exotic filter.

**`loop_filter_lownoise` (candidate).** A dual-path filter: the series resistor is
replaced by a proportional voltage source in series with a small capacitor, so the
capacitive divider reproduces the resistive step while noise injected by the voltage
source is attenuated by the capacitor ratio rather than reaching the control node. The
whole filter then scales down, provided the charge-pump current scales with it. Its
integrating capacitor is a MOS capacitor held in inversion, which is far denser than
MOM, at 5× the minimum thick-oxide channel length.

With the RC filter now at 3.1 % of the slot, the low-noise variant is no longer needed for
area — its remaining argument is control-node noise, which has not been measured. **The
swap is not free, and this is the part to carry forward:** a MOS capacitor only has
its capacitance while the channel is formed, so `vctrl` must stay above the thick-oxide
threshold of roughly 0.7 V. Substituting this filter requires re-centring the VCO band
above that. The two filters are to be compared at *equal loop bandwidth* — capacitor
area and control-node noise both measured — which is the only honest way to claim the
saving. The capacitor ratio itself is settled by a Monte-Carlo of the closed-loop
response over mismatch, varying the MOS and MOM capacitors independently, since ratio
error moves loop shape (peaking, lock time, jitter transfer) rather than noise.

## Measured

| Metric | Prototype netlist | Schematic hierarchy |
| --- | --- | --- |
| Ring oscillation at `vctrl` = 0.6 V | 155.7 MHz (unloaded) | 115.4 MHz (loaded) |
| Output swing | rail-to-rail | rail-to-rail |

**The difference is the point, not an error.** The prototype ring drove nothing. This one
taps its output through a small inverter and gives every stage an identical dummy load,
because a ring is only as symmetric as its loading: buffering one stage and leaving the
others unloaded slows that stage, and the stage-to-stage delay that Kvco is derived from
stops being uniform. A first cut with a large buffer on a single stage measurably slowed
the ring, which is what prompted the matched-load arrangement.

The consequence for the specification is that **the published 21–957 MHz tuning range was
characterised on a configuration that cannot be shipped**, and the curve must be
re-measured with the tap in place — and, if the low-noise filter is adopted, over the
restricted control range that its MOS capacitor imposes.

## Verification with Vyges Loom

[Vyges Loom](https://vyges.com/products/loom) is a suite of open-source silicon sign-off
engines. Each is a deterministic command that exits non-zero on a violation, so it works
as a build gate rather than as something a human has to read and interpret. Install
instructions: <https://docs.vyges.com/installation.html>.

Running these at the *schematic* stage, before any layout exists, is what makes a
connectivity fault cheap: it is a one-line fix now and a re-layout later.

| Engine | Why we run it | Stage |
| --- | --- | --- |
| `vyges loom lvs` | Compares two netlists by graph isomorphism, independent of net names — so a schematic edit that silently changes connectivity fails instead of surviving to silicon. | now, and again against layout at sign-off |
| `vyges loom extract` | Parasitics from layout (DEF/GDS → SPEF) to re-simulate against. The ring's stage delay, and so Kvco, is set by loading — which is exactly what extraction adds. | after layout |
| `vyges loom meas` | Extracts a scalar from a simulated sweep (gain, bandwidth, phase margin, or spectral SNR/THD). | once closed-loop and jitter benches exist |

### Connectivity gate — `vyges loom lvs`

**Why:** the schematics are generated, so a routing change can alter connectivity without
changing anything visible in the drawing. This compares the current netlist against a
known-good one and fails if the circuit is no longer the same circuit.

⚠️ xschem comments out the *top* `.subckt` line, so the netlist needs unwrapping first or
the tool reports the top cell as missing:

```sh
sed 's/^\*\*\.subckt/.subckt/; s/^\*\*\.ends/.ends/' \
    sim/netlist/pll_rosc.spice > sim/lvs/current.spice
cat > sim/lvs/check.lvs <<EOF
layout: sim/lvs/current.spice
schematic: sim/lvs/golden.spice
top: pll_rosc
EOF
vyges loom lvs run sim/lvs/check.lvs --fail-on-mismatch
```

Against an unchanged netlist — the whole hierarchy, phase detector through divider:

```text
  nets      A 60  B 60
  refine    12 iteration(s)
  the two netlists are structurally equivalent (verified by explicit isomorphism).
```

Exit status 0. Shorting the charge pump's `up` and `dn` inputs together and re-running
gives `LVS MISMATCH` and exit status 3 — verified, because a gate that cannot fail is not
a gate.

**This is worth having here specifically.** Routing the eight cells introduced six
connectivity faults that the rendered schematics looked entirely correct with: ring hops
running through the next stage's bias pin, six dummy-load taps sharing a channel and
merging `n2..n7` into one net, a mux stub landing on its neighbour's pin. Every one was
found by netlisting and comparing, not by looking.

### What is not yet applicable

`vyges loom meas` measures a swept transfer or a coherent tone capture. The PLL has
neither yet: loop dynamics need a closed-loop or open-loop AC bench, and jitter needs a
long transient. Both are on the list below, and the engine applies once they exist.

The gate-level engines — `power`, `sta-si`, `cdc`, `lec` — need a Verilog netlist with
Liberty timing and switching activity, which an analog block does not have. `em-ir` and
`thermal` need layout and a power map. None apply to this block at this stage.

## Not in this revision

Stated here rather than left to be discovered:

- **Closed-loop lock simulation** of the transistor-level hierarchy.
- **PVT corner sweeps.** Only the typical corner has been run.
- **Monte-Carlo of the loop transfer function** over capacitor ratio error.
- **Full integer-N divider.** The specification asks for N = 4…64; this revision provides
  the four binary taps of the existing chain. Extending it is additive — a loadable
  down-counter in place of the ripple chain — and does not disturb the phase detector,
  charge pump or filter.
- **Lock detect.**
