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

## Summary

Measured on the schematic hierarchy, on the 1.2 V core rail this block is specified for.

| Parameter | Measured | Goal |
| --- | --- | --- |
| Digital supply (`vccd`) input | **1.08 / 1.20 / 1.32 V** — the 1.2 V ±10 % core rail, a hard input. Arrives on the block's `vdd` port. **Not** the 3.3 V pallet supply, which this block does not use | 1.08–1.32 V |
| Reference in | 16–50 MHz usable | 10–50 MHz |
| Output, typical corner | 115.4–735.3 MHz | 100–800 MHz |
| Output, guaranteed over PVT | **352.6 MHz** ceiling, within charge-pump compliance | 800 MHz |
| Divider | ÷8 and ÷16 usable (÷2, ÷4 need a reference above 50 MHz) | N = 4…64 |
| Lock time, typical | **16.0 µs** (tt / 27 °C / 1.20 V) | 20 µs max |
| Lock time, worst measured corner | **24.0 µs** ❌ (ss / −40 °C / 1.08 V) | 20 µs max |
| Phase margin, N = 8 | **51.3°** ✅ (ff / 27 °C / 1.32 V / worst-case sheet) | 45° min |
| Phase margin, N = 16 | **51.2°** ✅ (ss / 27 °C / 1.08 V / best-case sheet) | 45° min |
| Crossover vs f_ref/10 | **1.20×** — exceeds the guideline | ≤ 1.0 |
| Charge-pump current | **0.31–0.63 µA** measured, from the harness 250 nA reference | — |
| Loop filter | Rz 125.09 kΩ, Cz 8.65 pF (82 × 82 µm), Cp 0.33 pF (16 × 16 µm) | — |

Every figure in this table is derived by `tools/datasheet.py`, which **exits non-zero if any
published number has drifted from the simulation behind it** — so the table cannot quietly go
stale. Detail, and what each miss costs, below.

## What it is

A foundational on-chip clock multiplier. Designed to drop into one openframe pallet slot —
**allocated slot 6, two pins**, which is exactly what it asks for: `ref` in and `vco_out` out.
It runs entirely from the **1.2 V core rail**, takes its bias from the harness 250 nA current
reference, and receives ÷N-select and its two resets as a register field on the digital
control-status bus. It needs **no 3.3 V analog rail**, and it reports no status: lock detect
is not implemented.

The loop figures come from a closed-loop run with every block real except the VCO, which is
behavioural and matched to the measured tuning curve of the real ring.

🔑 **The goals column is a goal, not a contract.** It was written before the PDK, the charge
pump's real output current and the supply's own tolerance could be modelled. They can be now,
and the measured column is what this design does on a 1.2 V rail. The output ceiling is the
clearest case: the ring reaches 735 MHz at the typical corner with the control voltage at the
top of the pump's compliance range, so 800 MHz guaranteed is not a margin that can be tuned
back — it is a property of a seven-stage ring on this process at this supply.

✅ **Phase margin passes at both divider settings**, 51.3° and 51.2° against a 45° floor,
over every operating point the part can be commanded into. Getting there needed two things
that had never been measured rather than any change to the oscillator:

- **The charge-pump current.** It was carried as 1 µA because the pump mirrors the harness
  bias 1:1. The mirror is 1:1 in *width*, not in drain-source voltage — measured over 27
  corners it delivered **1.16–2.26 µA**, so the loop ran at roughly twice the gain its filter
  was designed for. The block now takes the harness **250 nA** reference instead, measuring
  0.31–0.63 µA; required filter capacitance scales with it, so this also made the fix cheap
  (6,980 µm² of capacitor against 15,908 µm² at the 1 µA rail).
- **The top of the control range is not an operating point.** The pump's up branch runs out
  of compliance at about 0.85–0.91 × vdd and collapses to zero at the rail, so tuning-curve
  points above that cannot hold lock. The lowest Kvco in the whole sweep lives there, and it
  had been setting the phase-margin worst case.

📏 **Acquisition, per corner.** The bench models the ring behaviourally at one corner, so the
spread is measured explicitly rather than inferred — transistor-level, 100 ps over a 32 µs
window, at the corners with the lowest loop gain at the lock point:

| Corner | Lock time | |
| --- | --- | --- |
| tt / 27 °C / 1.20 V | 16 µs | ✅ |
| ss / 110 °C / 1.08 V | 16 µs | ✅ |
| ss / 27 °C / 1.08 V | 20 µs | ✅ at the limit |
| tt / −40 °C / 1.08 V | 20 µs | ✅ at the limit |
| **ss / −40 °C / 1.08 V** | **24 µs** | ❌ |

⛔ **One corner of the specified set misses the 20 µs goal** — cold, slow process, bottom of
the rail. At 20 µs it is still 3 % from its lock point, so this is a real miss and not a
sampling artifact. It is a direct consequence of bringing the loop inside its own bandwidth
bound: the previous 4 µs was fast *because* the crossover sat at twice the f_ref/10 it
claimed. Four corners were measured, not twenty-seven — each is a multi-hour transient, so
they were chosen by loop gain at the lock point and the rest are inference from them.

⚠️ **What is not met, stated here rather than left to be found.** The **output ceiling**,
above. The **divider range**, since only ÷8 and ÷16 are usable against a 16–50 MHz reference.
And the **crossover bound**: the loop's crossover reaches 1.20 × f_ref/10 at worst case
(N = 8, worst-case sheet, ff/27 °C/1.32 V), against the classical ≤ f_ref/10 guideline — 11 of
456 corner/point combinations exceed it, all at N = 8 and worst-case sheet resistance, by at
most 20 %. It is published as measured rather than bought back, because the only lever that
lowers it is a faster loop, and acquisition time is the tighter constraint. Six further
specifications — period and RMS jitter, phase noise, reference spur, duty cycle and power —
are **not measured**, for the one reason given in
[`doc/implementation.md`](doc/implementation.md). Lock detect and the output post-divider are
**not implemented**.

⛔ **Supply rails, because these have been conflated more than once.** **1.2 V is the core
rail and this block runs entirely from it** — ring, PFD, charge pump and divider are all lv
devices and 1.2 V standard cells. **3.3 V is the pallet supply** from the harness pMOS power
switch, and this block does not use it at all. The corner set is **1.08 / 1.20 / 1.32 V**,
which is what the PDK characterises (`sg13cmos5l_stdcell_*_1p08/1p20/1p32`); an earlier sweep
of 0.98 / 1.20 / 1.50 V was neither — 0.98 V is *below* the slowest characterised standard
cell, and 1.50 V is the other rail family's nominal. Detail and the traps that caused it:
[`doc/implementation.md`](doc/implementation.md).

## For the integrator

[`doc/implementation.md`](doc/implementation.md) carries two sections written for scoping
this block into a slot:

- **Supply rails** — which rail is which, why the corner set is 1.08/1.20/1.32 V, and the three ways 1.2 V and 3.3 V have been conflated here before.
- **Assumptions** — the process and harness resources the design rests on, each with what it is based on.
- **Slot requirements** — pads, harness resources, control bits and clocks. Two pads, one
  of them an up-to-735 MHz output that needs a dedicated path; the block runs entirely
  from 1.2 V, with **no 3.3 V analog rail required**.
- **Against the proposal** — every goal line with what the schematic measures, including the
  output range and divider range that fall short of it.

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
clone. It needs xschem, ngspice, and the IHP PDK — **one checkout now covers both halves**,
since upstream merged the `ihp-sg13cmos5l` overlay into IHP-Open-PDK:

```sh
git clone --branch dev --recurse-submodules https://github.com/IHP-GmbH/IHP-Open-PDK.git
git -C IHP-Open-PDK checkout ab1510cbdcbd61fe82e24ec28179c02ea7083299
PDK_ROOT=$PWD/IHP-Open-PDK python3 IHP-Open-PDK/ihp-sg13g2/libs.tech/ngspice/install.py
PDK_ROOT=$PWD/IHP-Open-PDK PDK=ihp-sg13cmos5l sh sim/run.sh
```

`--recurse-submodules` is not optional, and `install.py` compiles the Verilog-A models
(`psp103`, `psp103_nqs`, `r3_cmc`, `mosvar`) that ship as sources rather than binaries.

⚠️ **One upstream gap to work around.** Both `.spiceinit` files load all six OSDI models
from `$PDK_ROOT/$PDK/libs.tech/ngspice/osdi/`, but `install.py` writes its four only into
`ihp-sg13g2`, while `ihp-sg13cmos5l` ships only the other two (`cap_cmomf`, `cap_cmomi`)
prebuilt. Neither directory holds all six, so whichever `$PDK` you select the elaboration
fails on the missing pair. Symlink the two sets into each other after installing.

`$PDK_ROOT` defaults to `/foss/pdks` (what IIC-OSIC-TOOLS sets) and `$PDK` to
`ihp-sg13g2`, so the bundled PDK still works — but it is the *old* two-repository pin and
will not reproduce the numbers above.

⛔ **A PDK missing `cap_cmomf` does not fail — it silently drops every capacitor.** For a
symbol it cannot resolve, xschem writes `*  Cz -  cap_cmomf  IS MISSING !!!!` as a
*comment*: the netlist stays syntactically valid and simulates. The IIC-OSIC-TOOLS bundled
PDK still ships the pre-rename `cap_mfringe` and no `cap_cmomf` at all, so the loop filter
netlists against it as a bare resistor with both capacitors gone. ⟹ Grep a fresh netlist for
`IS MISSING` before trusting anything derived from it.

Apache-2.0. See [`NOTICE`](NOTICE) for attribution.
