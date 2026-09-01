# sg13cmos5l_vyges_ip__pll_rosc

Ring-oscillator **PLL** for the IHP **SG13CMOS5L** process — a self-biased,
dual-control-path ring-VCO PLL with a register-selectable ÷N feedback divider.
**All-CMOS** (no SiGe HBT / MiM cap / deep-N-well / Schottky — none of which
SG13CMOS5L provides); the loop-filter cap is MOM/poly within the 5-metal stack.
Built for the **Chipalooza Challenge #2 (IHP SG13CMOS5L)** as an openframe
analog-slot IP.

> Status: **schematic**. The full cell hierarchy is captured in xschem, netlists, and
> simulates. See [`doc/implementation.md`](doc/implementation.md) for what is built and
> measured, and [`doc/proposal.md`](doc/proposal.md) for the original design intent.

![Block diagram](doc/schematics/pll_rosc_block.svg)

## What it is

A foundational on-chip clock multiplier. Designed to drop into
one openframe pallet slot: 3.3 V from the slot power switch, bias from the
harness V/I references, and `enable` / ÷N-select / `lock` over the digital
control-status bus.

Measured on the schematic hierarchy; the loop figures come from a closed-loop run with
every block real except the VCO, which is behavioural and matched to the measured curve.

| Parameter | Measured | Specification |
| --- | --- | --- |
| Reference in | 16–50 MHz usable | 10–50 MHz |
| Output, typical corner | 115–737 MHz ❌ | 100–800 MHz |
| Output, guaranteed over PVT | ceiling **600 MHz** ❌ | 800 MHz |
| Divider | ÷8 and ÷16 usable (÷2, ÷4 need a reference above 50 MHz) ❌ | N = 4…64 |
| Lock time | ~5 µs ✅ | 20 µs max |
| Phase margin, N = 16 | 49.5° ✅ | 45° min |
| **Phase margin, N = 8** | **38.4°** ❌ (ff / −40 °C / worst-case sheet) | 45° min |
| Loop filter | Rz 80.8 kΩ, Cz 9.21 pF (63 × 63 µm) | — |

⚠️ **What is not met, stated here rather than left to be found.** Three measured
specifications fall short: the **output range** — the loaded ring tops out at 737 MHz
typical and 600 MHz at the slow corner, with the control voltage already at the supply
rail, so 800 MHz is a hard limit and not a margin; the **divider range**, since only ÷8
and ÷16 are usable against a specified 10–50 MHz reference; and **phase margin at N = 8**,
38.4° against a 45° minimum once the `rhigh` corner is swept rather than held at nominal
(N = 16 passes at every resistor corner). Six further specifications — period and RMS
jitter, phase noise, reference spur, duty cycle and power — are **not measured**, all for
the one reason given in [`doc/implementation.md`](doc/implementation.md). Lock detect and
the output post-divider are **not implemented**.

## For the integrator

[`doc/implementation.md`](doc/implementation.md) carries two sections written for scoping
this block into a slot:

- **Assumptions** — the process, slot supply and harness resources the design rests on. One is load-bearing and unconfirmed: the block runs from 1.2 V and the slot supply is 3.3 V.
- **Slot requirements** — pads, harness resources, control bits and clocks. Two pads, one
  of them an up-to-737 MHz output that needs a dedicated path; the block runs entirely
  from 1.2 V, with **no 3.3 V analog rail required**.
- **Against the proposal** — every specification line with what the schematic measures,
  including the output range and divider range that fall short.

## Layout

| Dir | Contents |
| --- | --- |
| `xschem/` | schematics — `cs_inv`, `rosc_vco`, `pfd`, `charge_pump`, `loop_filter`, `divn`, `pll_rosc` |
| `doc/schematics/` | rendered SVGs of every cell, readable without opening xschem |
| `magic/` | analog layout |
| `netlist/` | extracted / simulation netlists |
| `sim/` | testbenches — **`sim/ringvco_feasibility.spice`** + `run_tuning_sweep.sh` |
| `verilog/` | digital control/status wrapper (LibreLane) |
| `signoff/` | DRC / LVS / extract / STA reports |
| `doc/` | design notes, characterization |

## Toolchain

IHP open flow: **xschem / ngspice / magic / netgen / klayout** + **LibreLane**
for digital. ngspice must support **OSDI v0.4** (the IHP PSP103 models —
SG13CMOS5L shares them with SG13G2) — use IIC-OSIC-TOOLS or ngspice ≥ 43.

[**Vyges Loom**](https://vyges.com/products/loom) provides independent sign-off
alongside it — `vyges loom lvs` gates connectivity against a known-good netlist,
`vyges loom extract` supplies parasitics once there is layout, and `vyges loom meas`
measures swept transfers. Each exits non-zero on a violation, so they run as build
gates. Install: <https://docs.vyges.com/installation.html>. Commands and results are
in [`doc/implementation.md`](doc/implementation.md).

## Reproducing the results

`sim/run.sh` netlists the schematic hierarchy and runs every testbench from a clean
clone. It needs xschem, ngspice, and **both** IHP PDKs under one root: the
`ihp-sg13cmos5l` overlay for the models and stdcells, and the `ihp-sg13g2` base for the
compiled OSDI models. That root is `$PDK_ROOT`, which defaults to `/foss/pdks` (what
IIC-OSIC-TOOLS sets), so pass `PDK_ROOT=/your/pdks` to run against a checkout anywhere
else; `$PDK` names the base directory and defaults to `ihp-sg13g2`.

Apache-2.0. See [`NOTICE`](NOTICE) for attribution.
