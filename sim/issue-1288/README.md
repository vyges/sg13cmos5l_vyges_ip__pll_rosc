# IHP-Open-PDK#1288: the tt lock deck that still aborts

The closed-loop lock bench at tt / 27 °C / 1.20 V, as a self-contained netlist for
[IHP-Open-PDK#1288](https://github.com/IHP-GmbH/IHP-Open-PDK/issues/1288). With the antenna-diode
models as they are on IHP-Open-PDK `dev` (`ffb30b55f`), ngspice aborts this transient part-way
through the run.

| File | What it is |
| --- | --- |
| `tb_pll_lock_tt_27.spice` | The top-level deck. The real PFD, charge pump, loop filter and divider, with a behavioural VCO. |
| `pll_cells.spice` | Every subcircuit the deck instantiates. It includes nothing further. |

Everything else comes from the sg13cmos5l PDK under `$PDK_ROOT`:
- `cornerMOSlv.lib` (`mos_tt`), `cornerRES.lib` (`res_typ`) and `cap_cmomf.lib`;
- `diodes.lib`, unmodified (`dantenna` through `sg13cmos5l_antennanp`, two instances in the PFD);
- the standard-cell SPICE netlist.

## Running it

```sh
export PDK_ROOT=/path/to/IHP-Open-PDK      # holding ihp-sg13cmos5l
export SPICE_USERINIT_DIR=$PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice   # the PDK's .spiceinit
cd sim/issue-1288
ngspice -b tb_pll_lock_tt_27.spice
```

## Observed

```text
doAnalyses: TRAN:  Timestep too small; time = 1.31582e-05, timestep = 1.25e-22: trouble with node "xpfd.xup.net2"
tran simulation(s) aborted
```

These are the same failure time and node on ngspice-46 and ngspice-47 (IIC-OSIC-TOOLS
containers). With the `dantenna` instances removed, the deck runs to completion (24 µs).

## Where it comes from

`sim/run_lock.sh` generated it from `sim/tb_pll_lock.tpl` and the schematics at commit `af23567`
of this repository. There are three changes from the generated file, each listed in the deck's
header:
- the PDK paths are rewritten to `$PDK_ROOT`;
- the antenna diodes come from the PDK's own `diodes.lib`, not this repository's modified copy
  (`sim/diodes_rev.sh`);
- the output CSV is written to the working directory.

In the run quoted above, the diode models were a copy of the merged IHP fix. That copy matches
`diodes.lib` on `dev` (`ffb30b55f`) except for one blank line, which holds spaces in the PDK file.
