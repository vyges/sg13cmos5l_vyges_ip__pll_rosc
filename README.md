# sg13cmos5l_vyges_ip__pll_rosc

Ring-oscillator **PLL** for the IHP **SG13CMOS5L** process — a self-biased,
dual-control-path ring-VCO PLL with an integrated ÷N feedback divider and
digital lock detect. **All-CMOS** (no SiGe HBT / MiM cap / deep-N-well /
Schottky — none of which SG13CMOS5L provides); the loop-filter cap is MOM/poly
within the 5-metal stack. Built for the **Chipalooza Challenge #2 (IHP
SG13CMOS5L)** as an openframe analog-slot IP.

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
| Output, typical corner | 115–737 MHz | 100–1000 MHz |
| Output, guaranteed over PVT | ceiling **600 MHz** | 1000 MHz |
| Divider | ÷8 and ÷16 usable (÷2, ÷4 need a reference above 50 MHz) | N = 4…64 |
| Lock time | ~5 µs | 20 µs max |
| Phase margin, worst over PVT | 45.6° (ff/−40 °C, N=8) | 45° min |
| Loop filter | Rz 80.8 kΩ, Cz 9.21 pF (63 × 63 µm) | — |

⚠️ The 1 GHz output ceiling is **not** met: the loaded ring reaches 737 MHz at the typical
corner and 600 MHz at the slow corner with the control voltage already at the supply rail.
See [`doc/implementation.md`](doc/implementation.md).

## For the integrator

[`doc/implementation.md`](doc/implementation.md) carries two sections written for scoping
this block into a slot:

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
clone. It needs xschem, ngspice and the `ihp-sg13cmos5l` PDK at `/foss/pdks`.

Apache-2.0. See [`NOTICE`](NOTICE) for attribution.
