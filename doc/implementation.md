# Implementation — ring-oscillator PLL

What is actually built, what it measures, and what is deliberately not in this
revision. The design intent is in [`proposal.md`](proposal.md); this file records the
schematic that realises it.

## PDK pin

Every measured number in this document is scoped to this PDK state. Quote it with any
result taken from here.

✅ **The PDK is now ONE repository and one commit.** Upstream merged the SG13CMOS-5L
overlay into IHP-Open-PDK on 2026-09-01 (PR #1124), so `ihp-sg13cmos5l/`, `ihp-sg13g2/`
and `ihp-common/` sit in one tree on the `dev` branch.

| | repository | branch @ commit |
| --- | --- | --- |
| base + overlay | [`IHP-GmbH/IHP-Open-PDK`](https://github.com/IHP-GmbH/IHP-Open-PDK) | `dev@ab1510cbdcbd61fe82e24ec28179c02ea7083299` |

⚠️ **A branch pin, not a release.** `dev` carries no version tags, so quote the commit; it
also carries git submodules under `ihp-sg13g2/libs.tech/`, so clone `--recurse-submodules`
or the PDK is silently incomplete. The overlay is not self-contained — 528 symlinks, the
overlay's pointing back into the base by relative path — so base and overlay must be
siblings under one root. One tree guarantees that; two pinned repositories only promised it.

Content hashes of the model files actually read, so the pin is verifiable independently of
git:

| model file | sha256 (first 16) | comes from |
| --- | --- | --- |
| `cornerMOShv.lib` | `5a1f862dc304fdfe` | sg13g2 |
| `cornerMOSlv.lib` | `03d505847c880d23` | sg13g2 |
| `cornerRES.lib` | `c6d749e72cfa2e06` | sg13g2 |
| `cap_cmomf.lib` | `4704625f619ad55a` | sg13cmos5l |

🔑 **Both MOS hashes are byte-identical to the old pin**, which is why the VCO tuning curve
below is unchanged to the last digit. The entire delta sits in `cornerRES.lib` and in the
capacitor model.

`tools/report.py` prints this block above every set of results, so a number cannot be
quoted without the pin that produced it.

✅ **The `pdk-store` mirror now covers the whole PDK.**
[`vyges-tools/ihp-open-pdk`](https://github.com/vyges-tools/ihp-open-pdk) tracks upstream
`dev`, and both descriptors pin this commit, so one fetch reproduces these results.

## Assumptions

Everything below is an assumption the design rests on, with what it is based on. They are
stated here so a reviewer can check them against the harness rather than discover a
mismatch in the schematic. **Two are known to be unconfirmed and are marked.**

### Process

| | |
| --- | --- |
| PDK | IHP Open Source PDK, `ihp-sg13cmos5l` overlay in IHP-Open-PDK `dev@ab1510c` |
| Source | <https://github.com/IHP-GmbH/ihp-sg13cmos5l> |
| lv devices | maximum Vds **1.5 V** (`cornerMOSlv.lib`) |
| hv devices | maximum Vds **3.3 V** (`cornerMOShv.lib`) |
| Standard cells | characterised **1.08 – 1.65 V**. They are 1.2/1.5 V core cells and **cannot be operated from 3.3 V.** |
| Passives | `rhigh` 1360 Ω/sq, `rppd` 260, `rsil` 7; `cap_cmomf` at 0.372 + (mmax−mmin)×0.305 fF/µm², so **1.287 fF/µm²** on an M1–M4 stack — measured from the model, not read off its header |
| No MiM capacitor | correct for this process — the CMOS5L overlay deliberately omits `capacitors_mod.lib` |

### Slot supply — the one to check first

> "Each pallet has an identical footprint. **It gets its 3.3V power supply from a pMOS power
> switch**, and is given pins to connect to the digital interface of the harness (control and
> status lines), regulated voltage bias signals, and regulated current bias signals."
>
> — `sg13cmos5l_ocd_openframe/README`, the openframe harness this block targets

So the slot has **one supply, 3.3 V**. ⚠️ **A 1.2 V rail is assumed available and this is
NOT confirmed.** The harness's own digital controller is built from 1.2 V standard cells, so
the rail exists on the die; whether it is distributed to the pallets is the open question.

### Harness resources assumed

| Resource | Assumed | Basis |
| --- | --- | --- |
| `vin` / slot supply | 3.3 V through an enable-gated pMOS switch | harness README |
| Bandgap reference | 1.2 V | harness bandgap, `bandgap*` nets |
| Bias current | see the block-specific note below | harness `ibias1_250n`, `ibias1u_*`, `ibias2_1u` nets — i.e. **250 nA and 1 µA sources** |
| Control / status | a register field on the harness SPI bus, at standard-cell logic levels | harness README |

### Simulation

| | |
| --- | --- |
| Corners | `cornerMOShv/lv.lib` (tt, ss, ff) **crossed with** `cornerRES.lib` (`res_typ`, `res_bcs`, `res_wcs`) — swept **independently**, not paired. `Rz` is an `rhigh`, and holding it at nominal is exactly what made the phase-margin figure wrong for several revisions |
| Temperature | −40, 27, 110 °C |
| Supply | 3.0, 3.3, 3.6 V |
| Tools | xschem 3.4.8RC, ngspice-46, in an IIC-OSIC-TOOLS-derived container |
| Not covered | Monte-Carlo mismatch, and post-layout parasitics — both after layout |

### Block-specific

⚠️ **The entire block runs from 1.2 V, and the slot supply is 3.3 V.** The ring oscillator,
phase detector, charge pump and divider are all lv devices and 1.2 V standard cells. This is
the single largest open assumption in the design: if no 1.2 V rail reaches the pallet, the
block has no supply. The proposal's specification table listed "Supply (digital)
1.08–1.32 V" as a given, and that is the assumption in question.

Rebuilding in hv devices at 3.3 V is possible but is not a port: the ring's delay per stage,
and therefore the entire tuning curve and every loop number derived from it, is a function
of the supply.

✅ **`Icp` = 1 µA matches what the harness provides** (`ibias1u_*`). The loop was designed
around a small charge-pump current for filter-area reasons, and that happens to line up with
the available bias rather than requiring a new one.

## Cell hierarchy

| Cell | What it does | Schematic |
| --- | --- | --- |
| `cs_inv` | One current-starved inverter stage | [SVG](schematics/cs_inv.svg) |
| `rosc_vco` | 7-stage ring with bias mirror, matched loading, buffered tap | [SVG](schematics/rosc_vco.svg) |
| `pfd` | Tri-state phase-frequency detector, two flops with a POR-gated reset | [SVG](schematics/pfd.svg) |
| `charge_pump` | Current-steering pump, mirrored from the harness bias line | [SVG](schematics/charge_pump.svg) |
| `loop_filter` | Type-II RC filter — the baseline | [SVG](schematics/loop_filter.svg) |
| `loop_filter_lownoise` | Dual-path small-capacitor alternative | [SVG](schematics/loop_filter_lownoise.svg) |
| `divn` | Programmable feedback divider, ÷2 ÷4 ÷8 ÷16 (only ÷8 and ÷16 usable — see below) | [SVG](schematics/divn.svg) |
| `pll_rosc` | Top level | [SVG](schematics/pll_rosc.svg) |

## VCO tuning curve — measured on the loaded ring

`sim/tb_vco_sweep.spice` sweeps the control voltage and measures the oscillation frequency
on the real cell, with its output tap and matched per-stage dummy loads.

| vctrl | f_out | local Kvco |
| --- | --- | --- |
| 0.60 V | 115.4 MHz | 1411 MHz/V |
| 0.70 V | 256.5 MHz | 1649 MHz/V |
| 0.80 V | 421.4 MHz | 1375 MHz/V |
| 0.90 V | 558.9 MHz | 881 MHz/V |
| 1.00 V | 647.0 MHz | 537 MHz/V |
| 1.10 V | 700.7 MHz | 346 MHz/V |
| 1.20 V | 735.3 MHz | — |

⚠️ **The specification's 1 GHz upper limit is not reached.** Loaded, the ring tops out at
**735 MHz with the control voltage at the 1.2 V supply rail**. The 957 MHz figure in the
proposal was measured on a bare ring driving nothing, which is not a shippable
configuration. The achievable output band is **115–735 MHz**.

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
| Rz | 80.77 kΩ | `rhigh`, w = 1 µm, l = 56.9 µm — **measured**, not sheet arithmetic |
| Cz | 5.11 pF | `cap_cmomf`, 63 × 63 µm — **2.4 % of the slot** |
| Cp | 0.417 pF | `cap_cmomf`, 18 × 18 µm |

⚠️ **`Cz` and `Cp` fell by 45 % at the same drawn size**, because the re-pin renamed
`cap_mfringe` to `cap_cmomf` and recalibrated its density from 2.32 to 1.287 fF/µm². Unlike
the LDO — where the capacitor is Miller compensation and less of it costs margin — **less
`Cz` at a fixed `Rz` raises the loop zero and *gains* margin here.** The drawn geometry is
therefore unchanged, and the block was left alone.

**Worst-case phase margin is 56.4° across every selectable operating point _at the nominal
resistor value_**, and the crossover stays below f_ref/10 everywhere. `Rz` is an `rhigh`
whose corners are ±14.7 % on this pin, and it sets both the loop zero and the filter's
high-frequency gain: swept, **the worst case is 49.3° at N = 8**, which now clears the 45°
minimum. See the PVT section.

ℹ️ **`Rz` is measured on the PDK now rather than derived from sheet × geometry**, because
the two disagree. The old pin applied a −0.04 µm width correction that this document's
arithmetic did not model, so its true worst-case `Rz` was 110.1 kΩ where the tables said
101.0 kΩ — and its true worst-case margin was **35.7°, not the 38.4° previously
published**. The re-pin removed that correction; drawn `Rz` now spans 66.16 / 80.77 /
96.64 kΩ across best / typical / worst sheet.

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
tuning curve rather than from a round number brought the zero capacitor to 63 × 63 µm,
about **2.4 % of a 530 × 310 µm slot** — 5.11 pF under this pin's capacitor model, 9.21 pF
under the previous one at the same drawn size. The area problem the proposal anticipated is
largely answered by designing the loop properly; it does not need an exotic filter.

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
characterised on a configuration that cannot be shipped**. It has since been re-measured
with the tap in place — see the tuning curve above — giving 115–735 MHz at the typical
corner and a 600 MHz ceiling across PVT.

## Verification with Vyges Loom

[Vyges Loom](https://vyges.com/products/loom) is a suite of open-source silicon sign-off
engines. Each is a deterministic command that exits non-zero on a violation, so it works
as a build gate rather than as something a human has to read and interpret. Install
instructions: <https://docs.vyges.com/installation.html>.

Running these at the *schematic* stage, before any layout exists, is what makes a
connectivity fault cheap: it is a one-line fix now and a re-layout later.

| Engine | Why we run it | Stage |
| --- | --- | --- |
| `vyges loom lvs` | Compares two netlists by graph isomorphism, independent of net names, **and compares device sizing** — so an edit that changes connectivity *or* re-sizes a component fails instead of surviving to silicon. | now, and again against layout at sign-off |
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

Exit status 0. Two deliberate-failure checks, because a gate that cannot fail is not a
gate: shorting the charge pump's `up` and `dn` inputs together gives `LVS MISMATCH` and
exit 3, and so does re-sizing the loop-filter components while leaving the topology
untouched — the second names each device and its two values:

```text
  device parameter mismatch (topology matches):
    X Xlf/XRz: l layout 0.0000569 vs schematic 0.000035
    X Xlf/XCz: w layout 0.000063  vs schematic 0.000093
```

ℹ️ Device-sizing comparison needs a build newer than v0.1.33; that release compares
topology only and returns a clean MATCH across a complete re-sizing.

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

## Closed-loop acquisition

`sim/tb_pll_lock.spice` runs the loop at N = 16 with a 16 MHz reference — 256 MHz out,
the bottom of the band and the **highest-Kvco corner**, so the most aggressive loop gain
among the selectable settings.

Everything in the loop is the real cell — phase detector, charge pump, filter, divider —
except the VCO, which is behavioural and matched to the measured tuning curve. That is
deliberate. A transistor-level ring must be integrated at picosecond steps while the loop
settles over microseconds, seven orders of magnitude apart; a full transistor run reached
18 ns of a 30 µs target. Loop dynamics are what this bench is for.

| time | vctrl | was, at the old pin |
| --- | --- | --- |
| 1 µs | 0.411 V | 0.297 V |
| 2 µs | 0.596 V | 0.463 V |
| 4 µs | 0.699 V | 0.716 V |
| 6 µs | 0.6998 V | 0.698 V |
| 7.8 µs | **0.6997 V** | **0.6998 V** |

**The loop acquires and locks in roughly 4 µs**, settling at the control voltage that
produces 256 MHz. ✅ **Acquisition is faster and better damped than at the old pin**: it is
within a millivolt of the final value by 4 µs where the old filter was still 16 mV above
it, and the residual drift over the last 1.8 µs is **0.10 mV against 1.61 mV** — a factor
of 16. That is the smaller `Cz` and the extra phase margin showing up in the time domain,
and it is the independent confirmation that the frequency-domain numbers below are real.
The specification allows 20 µs.

## PVT

`sim/run_pvt.sh` measures the tuning curve at three process corners, three temperatures
and the two control voltages that bracket the high-gain end, then evaluates the designed
filter against the local Kvco at each. Loop gain is proportional to Kvco, so the corner
that moves the tuning curve moves phase margin — but it is not the only one that does, and
treating it as such is what made the number below wrong for a while. The loop-filter
resistor is the other, and it turns out to matter more.

| corner | f @ 0.7 V | f @ 1.2 V | Kvco | PM (N=16) | PM (N=8) |
| --- | --- | --- | --- | --- | --- |
| ff/−40 °C | 320 MHz | 904 MHz | 1989 MHz/V | 59.3° | **54.3°** |
| ff/27 °C | 380 MHz | 894 MHz | 1863 MHz/V | 59.3° | 55.1° |
| ff/110 °C | 431 MHz | 875 MHz | 1606 MHz/V | 59.0° | 56.7° |
| tt/−40 °C | 202 MHz | 740 MHz | 1682 MHz/V | 59.1° | 56.2° |
| tt/27 °C | 256 MHz | 735 MHz | 1649 MHz/V | 59.1° | 56.4° |
| tt/110 °C | 312 MHz | 727 MHz | 1475 MHz/V | 58.7° | 57.4° |
| ss/−40 °C | 121 MHz | 613 MHz | 1387 MHz/V | 58.4° | 57.9° |
| ss/27 °C | 162 MHz | 605 MHz | 1407 MHz/V | 58.4° | 57.8° |
| ss/110 °C | 212 MHz | 600 MHz | 1313 MHz/V | 58.0° | 58.2° |

ℹ️ The frequency and Kvco columns are **unchanged to the last digit** from the old pin —
both MOS model hashes are identical, so nothing about the ring moved. Only the two
phase-margin columns changed, and they changed because of the loop filter.

⚠️ **These figures hold `Rz` at its nominal 80.77 kΩ at every corner, and that is wrong.**
`Rz` is an `rhigh` poly resistor whose corners on this pin are **±14.7 %** — they were ±25 %
before the re-pin — and it sets both the loop zero and the filter's high-frequency gain.
Sweeping it against the same measured Kvco values, with `Rz` measured on the PDK at each
corner rather than derived from sheet × geometry:

| `rhigh` corner | `Rz` (measured) | ff/−40 °C, N=8 | ff/27 °C, N=8 | tt/27 °C, N=8 |
| --- | --- | --- | --- | --- |
| res_bcs, 1160 Ω/sq | 66.16 kΩ | 58.1° | 58.5° | 59.0° |
| res_typ, 1360 Ω/sq | 80.77 kΩ | 54.3° | 55.1° | 56.4° |
| res_wcs, 1560 Ω/sq | 96.64 kΩ | **49.3°** | 50.3° | 52.0° |

✅ **Worst-case phase margin is 49.3°, at ff/−40 °C with N = 8 and worst-case sheet
resistance — against a 45° minimum. The loop meets its phase-margin specification.** It was
38.4° as published, and 35.7° once `Rz` is measured rather than derived.

**Two independent changes both moved it the same way, and they are worth separating:**

Each was evaluated on its own by holding the other at the old pin's value, rather than by
splitting the total:

| at ff/−40 °C, N = 8 | `Rz` (wcs) | `Cz` | phase margin | |
| --- | --- | --- | --- | --- |
| old pin | 110.08 kΩ | 9.208 pF | 35.7° | |
| `rhigh` change alone | 96.64 kΩ | 9.208 pF | 39.8° | **+4.1°** |
| capacitor change alone | 110.08 kΩ | 5.108 pF | 45.1° | **+9.4°** |
| both — this pin | 96.64 kΩ | 5.108 pF | **49.3°** | **+13.6°** |

They are very nearly additive (the two singles sum to +13.5° against +13.6° together), and
**the capacitor recalibration is more than twice the resistor fix** — on its own it would
have just cleared the bar at 45.1°, while the `rhigh` fix on its own would not have, at
39.8°.

Neither was a design decision. ⚠️ **The larger one is a warning as much as a gain**: a
device model changed under a finished schematic and moved a specification by 9.4°. This
block passes today because the change happened to push the right way — in the LDO the same
recalibration pushed the other way and had to be paid for in area.

Raising `Rz` lowers the zero, which alone would help, but it raises the filter's
high-frequency gain and pushes crossover up faster — so a worst-case sheet loses margin
net. Note this is the **opposite direction** to the LDO, where the same resistor in a
nulling role fails at *both* extremes for different reasons. The direction is not
guessable from the role of the resistor; it has to be swept, and it now is, on every run.

N = 16 passes at every resistor corner, worst case 54.1°, and **N = 8 now passes too** at
49.3°. N = 8 remains the exposed setting — the loop gain is doubled there, and every corner
in the table above is 3–4° tighter at N = 8 than at N = 16 — but it is no longer a failing
one.

⚠️ **The output ceiling across PVT is 600 MHz**, set by the slow corner with the control
voltage already at the 1.2 V rail. Against a specification of 1 GHz that is a substantial
shortfall, and it is a *hard* limit rather than a margin: there is no more control range to
give. At the typical corner the ring reaches 735 MHz.

The floor moves the other way — 431 MHz at ff/110 °C against 121 MHz at ss/−40 °C for the
same control voltage — so the band that is guaranteed at **every** corner without
recalibration is much narrower than the band at any single one. A trim on the VCO bias, or
accepting a per-part calibration, is what would recover it.

## Against the proposal

| Parameter | Proposal | Measured | |
| --- | --- | --- | --- |
| Reference in | 10–50 MHz | 16–50 MHz usable | ⚠️ narrowed |
| **Output range** | **100–800 MHz** | 115–735 MHz typical, **600 MHz ceiling over PVT** | ❌ |
| **Feedback divider N** | **4–64, register-set** | ÷2 ÷4 ÷8 ÷16; only ÷8 and ÷16 usable | ❌ |
| **Output post-divider ÷1/2/4/8** | required | **not implemented** | ❌ |
| Kvco | 1.0–2.1 GHz/V | 0.35–1.65 GHz/V | ⚠️ below the stated minimum at high control voltage |
| Supply, digital | 1.08–1.32 V | 1.2 V | ✅ |
| Supply, analog | 3.0–3.6 V | **not used** — the block is entirely 1.2 V | ℹ️ simplification, see below |
| Lock time | 6 µs typ, 20 max | **~4 µs** | ✅ |
| Phase margin | — | 49.3° worst, Kvco × resistor corner, N = 8 | ✅ |
| Temperature | −40 to 110 °C | all 9 corners | ✅ |
| **Period jitter** | 6 ps typ, 12 max | **not measured** | ❌ |
| **RMS jitter** | 3 ps typ, 5 max | **not measured** | ❌ |
| **Phase noise @ 1 MHz** | −95 dBc/Hz | **not measured** | ❌ |
| **Reference spur** | −45 dBc | **not measured** | ❌ |
| **Output duty cycle** | 45–55 % | **not measured** | ❌ |
| **Power @ f_out** | 5 mW typ, 8 max | **not measured** | ❌ |
| **Digital lock detect** | promised in §1 | **not implemented** | ❌ |

**The analog supply is not used, and that is a simplification rather than a gap.** The
proposal assumed a 3.3 V analog rail for the oscillator and bias; the implementation runs
the ring, phase detector, charge pump and divider entirely from the 1.2 V digital rail. One
fewer supply to route into the slot, and it should be stated to the integrator rather than
left as a surprise.

**What the failures have in common** is that four of the six unmeasured lines — jitter,
phase noise, spur, duty cycle — need a long transient on the locked loop, which is exactly
the simulation that is expensive here. The lock run is behavioural for that reason. Getting
these needs either a much faster transistor-level setup or accepting behavioural numbers
and saying so.

## Slot requirements — pins, power and clocks

For scoping pin allocation. This is the **implemented** port list.

```text
.subckt pll_rosc  ref porb rstb nsel0 nsel1 ibias vco_out vdd vss
```

### Pads required

| Signal | Kind | Requirement |
| --- | --- | --- |
| `ref` | clock in | Reference, **16–50 MHz**. Needs a clean edge; a shared analog mux is acceptable electrically but any added jitter appears directly at the output multiplied by N. |
| `vco_out` | clock out | **Up to 735 MHz.** This is the demanding one: a shared mux path will not carry it intact, so it wants a **dedicated pad with a proper output buffer**, and the board side needs a controlled-impedance route. If only a muxed pad is available, we would add an on-slot divider and characterise a lower output frequency instead. |

**Two pads, one of them a genuine high-frequency output.** That is the block's main ask.

### Harness resources (shared, no pads)

| Signal | From the harness |
| --- | --- |
| `vdd` | **1.2 V.** The whole block runs from it — no 3.3 V analog rail is needed. |
| `ibias` | Bias current. **The loop is designed around Icp = 1 µA**, mirrored 1:1, so this is a requirement on the harness bias rather than an internal size. |
| `vss` | Ground. |

### Control bits (register field, no pads)

| Bits | Direction | |
| --- | --- | --- |
| 4 | control | `nsel[1:0]` divider select (2), `porb` phase-detector power-on reset (1), `rstb` divider reset (1) |
| 0 | status | none — **lock detect is not implemented**, so there is nothing to report yet |

### Clocks

| | |
| --- | --- |
| In | `ref`, 16–50 MHz |
| Out | `vco_out`, up to 735 MHz typical, 600 MHz guaranteed over PVT |

## Not in this revision

Stated here rather than left to be discovered:

- **Monte-Carlo of the loop transfer function** over capacitor ratio error.
- **Full integer-N divider.** The specification asks for N = 4…64; this revision provides
  the four binary taps of the existing chain. Extending it is additive — a loadable
  down-counter in place of the ripple chain — and does not disturb the phase detector,
  charge pump or filter.
- **Lock detect.**
- **Output post-divider ÷1/2/4/8.**

## Work remaining, in the order it should be done

1. ✅ **Loop phase margin at N = 8 — closed by the 2026-09-01 re-pin, not by a change
   here.** 49.3° against a 45° minimum, at the same ff/−40 °C worst-case-sheet corner that
   read 38.4° before (35.7° once `Rz` is measured rather than derived). No geometry moved.
   ⚠️ **The item that replaces it is a smaller one: confirm this is not luck.** The gain
   came mostly from a capacitor model that was recalibrated underneath a finished
   schematic, and a model that moved 1.8× once can move again — so the block should be
   re-measured whenever the PDK pin moves, and the divider restriction to N ≥ 16 stays
   worth keeping in reserve rather than being spent now.
2. **Decide what to do about the 1 GHz specification.** The ring reaches 735 MHz typical
   and 600 MHz at the slow corner with the control voltage already at the rail, so this
   is not a tuning problem. The options are a shorter ring (five stages rather than seven,
   which costs phase-noise margin), a faster stage at higher current, or declaring a lower
   maximum. All three are specification changes and belong to the review, not to a later
   silent revision.
3. **Extend the divider to the full N = 4…64.** Purely additive, and it makes the ÷2 and
   ÷4 cases usable, which is what narrows the reference range today.
4. **The four unmeasured dynamic specifications** — period and RMS jitter, phase noise,
   reference spur — plus duty cycle and power. These share one blocker: they need a long
   transient on the locked loop, which is why the acquisition run is behavioural. Deciding
   *how* to get them is the real item: a faster transistor-level setup, or behavioural
   numbers stated as such.
5. **Lock detect and the output post-divider**, both additive digital.
6. **Monte-Carlo the loop transfer function** over capacitor ratio error, varying the MOS
   and MOM capacitors independently — a mixed-type divider mismatches systematically
   rather than as a pair.

## Questions that need answers before layout

1. **Is 600 MHz guaranteed acceptable, against a specification of 1 GHz?** The block's
   largest gap, and the cheapest to resolve by conversation rather than by silicon.
2. ✅ **Is N ≥ 16 an acceptable restriction?** Answered at the 2026-09-01 review — yes,
   acceptable. **It is no longer needed to meet phase margin**, which N = 8 now clears at
   49.3°, so it is held in reserve rather than spent: keeping ÷8 usable keeps the
   reference range wider.
3. ✅ **Should this design be re-pinned for the PDK's `rhigh` corner fix?** Done. Commit
   `4b7d7422` is an ancestor of `dev`, and the block is pinned to `dev@ab1510c`. ⚠️ The
   estimate made here — that the fix alone would move the worst case to 41.2° — was close
   (measured 39.8° in isolation) but it was **not what closed the gap**; the capacitor
   model recalibration in the same re-pin was worth more than twice as much. The decision
   was shared with the LDO, where the same commit is worth +5.4°.
4. **Is a 1.2 V rail distributed to the pallets?** The entire block runs from 1.2 V and
   the slot supply is 3.3 V. If no low rail is distributed, this block needs a regulator
   in front of it — which is a substantially different block. This is shared with the LDO
   and is the single largest unknown for both.
5. **Are behavioural numbers acceptable for jitter, phase noise and spur** at the
   schematic gate, with transistor-level figures to follow at layout? See item 3.
6. **What reference frequency will actually be supplied?** The usable range narrows to
   16–50 MHz because only ÷8 and ÷16 are usable today; item 2 removes that constraint if
   the answer needs it.
