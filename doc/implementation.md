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
