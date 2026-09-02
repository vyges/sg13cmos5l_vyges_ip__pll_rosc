# Datasheet

`pll_rosc_schematic.md` is generated. Do not edit it.

```bash
sh sim/run.sh && sh sim/run_pvt.sh     # produce the results
python3 tools/datasheet.py             # emit the table
python3 tools/datasheet.py --check     # verify README.md against them; exit 1 on drift
```

## The format

One table per netlist source, the same rows in every one, rows that cannot run against a
given source marked **Skip** rather than dropped. Only `schematic` exists today: there is no
layout, so `layout`, `pex` and `rcx`, and with them every physical row, have nothing to run
against. They are still listed, because a missing row reads as an oversight while a Skipped
row states that the check exists and says what it will be judged against. The format is
CACE's; the tool is not a dependency (it cannot consume `.spice` testbenches at all).

## Why this file matters more here than for the LDO

🔑 **The numbers this block publishes used to come from a script that was not in this
repository.** Phase margin, Kvco and the tuning range were derived by external tooling, so
"where does 49.3° come from?" answered "somewhere you cannot look". `tools/datasheet.py`
closes that: every figure is derived here, from inputs that ship here, by a rule stated here.

⛔ **And the loop constants belong with the design, not with the checker.** The external gate
carried two constants that the design had moved past, and neither could be seen from here:

| | external gate | this design |
| --- | --- | --- |
| `Cz`, `Cp` | 9.21 pF, 0.75 pF | **5.11 pF, 0.417 pF** |
| `rhigh` corners | ±25 %, scaled from sheet | **±14.7 %, measured per corner** |

The capacitors are the same geometry at the MoM density *before* it was recalibrated from
2.320 to 1.287 fF/µm²; the resistor corners are the spread from *before* this PDK pin's
`rhigh` fix. Held together they reproduce 38.4° at N = 8 — the figure this block was
published as failing on, and which it has not measured since the re-pin.

⚠️ **`Rz` is measured per corner, never scaled from sheet × geometry.** res_wcs is 1.147× the
typical *sheet* but 1.197× the measured *resistor*; the difference is a width correction that
geometry arithmetic cannot see. Scaling gives 92.7 kΩ instead of 96.64 kΩ, and the wrong
phase margin. With the measured values this file reproduces the published corner table cell
for cell — 58.1/58.5/59.0, 54.3/55.1/56.4, 49.3/50.3/52.0.

## Plots

Three, and each is drawn because a table cannot show what it shows:

- **`pll_rosc_tuning.svg`** — the typical tuning curve against the 800 MHz line it misses.
  The headline shortfall is a distance on this plot rather than a claim in a row.
- **`pll_rosc_tuning_pvt.svg`** — all nine corner curves. The typical curve is not what the
  part guarantees; drawing the spread shows where the 600 MHz ceiling comes from.
- **`pll_rosc_phase_margin.svg`** — margin at every Kvco and resistor corner, for BOTH
  divider settings, because their worst corners are opposite ones. A single-N plot would
  suggest margin moves one way with corner, and it does not.

They are emitted as hand-written SVG rather than through matplotlib: the block's tooling is
stdlib-only, an SVG diffs and reviews like the rest of the repository, and no plotting
library's version can quietly change what a published figure looks like.

## The check is the point

`--check` parses the table in `README.md` and compares every published figure against the
simulation behind it, to half of the last digit that figure is published to. It found one
figure that had **no bench behind it at all**: the 737 MHz top of the tuning band. The sweep
stopped at vctrl 1.10 V and never measured the 1.20 V rail the figure was quoted at. A 1.20 V
point was added to `sim/tb_vco_sweep.spice`; it measures **735.3 MHz**, and the band is now
115–735 MHz with a bench behind both ends.

⛔ The tolerance comes from the published literal, never a constant, and the check is only
worth running because it can fail — it did, four times, before these were reconciled.

ℹ️ Two rows are deliberately **reported rather than judged**. The band's low end is the lowest
control point clearing the 100 MHz floor, and the 0.1 V control grid cannot resolve where the
ring actually crosses it (34.4 MHz at 0.50 V, 115.4 at 0.60) — gating it would report a
failure that belongs to the sampling, not the design. Lock time is resolved to the bench's
sample grid and no finer.

## Schematics

`tools/sch2svg.py` renders `xschem/*.sch` to `doc/schematics/`, using the PDK's own symbol
artwork cached in `sym_art.json` beside it:

```bash
python3 tools/sch2svg.py xschem/*.sch --out doc/schematics
```

It moved here from private tooling on 2026-09-02 for the same reason the numbers did: a
published figure whose generator is private cannot be re-derived by the person reading it.

⚠️ **It caught stale figures the moment it arrived.** The schematics changed in the
`dev@ab1510c` re-pin on 2026-09-01 but the committed SVGs were last generated on 2026-08-29,
so the published drawings showed the pre-re-pin circuit. Regenerated.

ℹ️ **Not xschem's own SVG export.** That dumps the editor canvas — whatever zoom happened to
be set — and in headless mode here it renders a fragment: for a 69-instance schematic it
emitted 44 elements containing one instance, with `tkwait visibility .drw failed`. This
renderer reads the `.sch` directly, so the picture cannot drift from the netlisted circuit.
