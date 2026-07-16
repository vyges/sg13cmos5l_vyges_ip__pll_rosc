# Feasibility simulation — ring VCO (IHP SG13G2)

`ringvco_feasibility.spice` — a 5-stage current-starved inverter ring VCO in
3.3 V `sg13_hv_nmos/pmos` devices; Vctrl on the footer nmos sets the starving
current (tuning). `run_tuning_sweep.sh` sweeps Vctrl and reports oscillation
frequency — the proposal's feasibility data point.

**Toolchain:** needs ngspice with **OSDI v0.4** support (the PDK's PSP103 models
are v0.4). Use **IIC-OSIC-TOOLS** (bundles a matching ngspice + the SG13G2 PDK)
or ngspice ≥ 43. Ubuntu `apt` ngspice-42 is OSDI v0.3 and will report
"Unknown model type psp103va".
