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

| Parameter | Preliminary target |
| --- | --- |
| Reference in | ~10–50 MHz |
| Output | ~100–800 MHz (÷N programmable) |
| Supply | 3.3 V |

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
for digital, with **Vyges Loom** (`vyges-drc` / `-lvs` / `-extract` / `-sta-si`)
as independent sign-off. ngspice must support **OSDI v0.4** (the IHP PSP103
models — SG13CMOS5L shares them with SG13G2) — use IIC-OSIC-TOOLS or ngspice ≥ 43.

## Reproducing the results

`sim/run.sh` netlists the schematic hierarchy and runs every testbench from a clean
clone. It needs xschem, ngspice and the `ihp-sg13cmos5l` PDK at `/foss/pdks`.

Apache-2.0. See [`NOTICE`](NOTICE) for attribution.
