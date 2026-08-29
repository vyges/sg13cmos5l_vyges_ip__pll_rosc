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

## The loop filter is the area decision

The loop-filter capacitor is what the slot budget is spent on. Two filters are carried
so the choice can be made on measurements rather than on argument:

**`loop_filter` (baseline).** A conventional type-II RC. At the `cap_mfringe` density of
2.32 fF/µm² on an M1–M4 stack, its 20 pF zero capacitor is 93 × 93 µm — 6.6% of a
520 × 250 µm slot. It fits, but it ties loop bandwidth to that capacitor.

**`loop_filter_lownoise` (candidate).** A dual-path filter: the series resistor is
replaced by a proportional voltage source in series with a small capacitor, so the
capacitive divider reproduces the resistive step while noise injected by the voltage
source is attenuated by the capacitor ratio rather than reaching the control node. The
whole filter then scales down, provided the charge-pump current scales with it. Its
integrating capacitor is a MOS capacitor held in inversion, which is far denser than
MOM, at 5× the minimum thick-oxide channel length.

**The swap is not free, and this is the part to carry forward:** a MOS capacitor only has
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
