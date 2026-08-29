# Vyges IHP SG13CMOS5L (SG13G2) analog/mixed-signal flow

How to design, simulate, lay out, and sign off an analog IP for the IHP
SG13G2 open PDK — the flow this ring-PLL IP (and the Chipalooza harness) use.
Captured from standing the flow up end-to-end on 2026-07-15.

## 0. The environment — IIC-OSIC-TOOLS container

The open analog toolchain (ngspice / xschem / magic / netgen / klayout) is *not*
part of a digital LibreLane host. Use the **IIC-OSIC-TOOLS** container, which
bundles a matched toolset **and** the SG13G2 PDK:

```bash
docker pull hpretl/iic-osic-tools:latest        # ngspice-46, xschem, magic, netgen, klayout
```

- PDK inside the container: `/foss/pdks/ihp-sg13g2`
- Tools on PATH via the container's login shell.

Run a batch command (the image has a GUI entrypoint — override it):

```bash
docker run --rm --entrypoint bash \
  -v "$PWD":/work \
  -v ~/.ciel/ihp-sg13g2:/foss/pdks/ihp-sg13g2 \
  hpretl/iic-osic-tools:latest -lc 'cd /work && <cmd>'
```

### Toolchain gotchas (learned the hard way)

- **ngspice version matters.** The SG13G2 MOS models are **PSP103 via OSDI**,
  and the PDK ships them as **OSDI v0.4**. Ubuntu `apt` ngspice-42 is OSDI v0.3
  → `Unknown model type psp103va`. Need **ngspice ≥ 46** (the container has it).
- The `github.com/ngspice/ngspice` mirror is **stale** (builds report "rev 26");
  the real git is on SourceForge. Don't build from that mirror.
- `apt install ngspice` conflicts with KiCad's `libngspice-kicad` over a shared
  `analog.cm` code-model — a container avoids this entirely.

## 1. Devices & model include (ngspice)

3.3 V I/O-class devices are `sg13_hv_nmos` / `sg13_hv_pmos` (subckt pins
`d g s b`, params `w`/`l`); 1.2 V core devices are `sg13_lv_*`. Include the
typical corner and load the OSDI model:

```text
* in a .spiceinit next to the deck (or $HOME):
osdi /foss/pdks/ihp-sg13g2/libs.tech/ngspice/osdi/psp103.osdi

* in the deck:
.lib /foss/pdks/ihp-sg13g2/libs.tech/ngspice/models/cornerMOShv.lib mos_tt
Xn drain gate source bulk sg13_hv_nmos w=4u l=0.5u
```

Corners in `cornerMOShv.lib`: `mos_tt` (typical), `mos_ss`, `mos_ff`, `mos_sf`,
`mos_fs`. Verified device: `sg13_hv` inverter — full 0→3.3 V swing, trip 1.465 V.

### ngspice ring-oscillator startup gotcha

A ring latches at its metastable DC point unless perturbed. `uic` + conflicting
`.ic` did **not** start it reliably here. What worked: **a brief current-pulse
kick** on one node (`Ikick n1 0 PULSE(0 500u 0 20p 20p 300p 0)`), no `uic`.
Measure frequency from two mid-rail rising crossings after startup
(`meas tran ... WHEN v(n1)=1.65 RISE=5/6`).

## 2. Full IP flow (per the openframe harness)

```text
schematic ── xschem ────────────────────► .sch / .sym
    │  simulate ── ngspice ──────────────► tuning / lock / jitter (this doc §1)
    ▼
layout ──── magic ──────────────────────► .mag  (analog, hand-drawn)
    │  digital wrapper ── LibreLane ─────► .pnl.v (LVS) / .nl.v (sim) + .mag
    ▼
extract ── magic ext2spice ─────────────► layout netlist
verify ─── netgen (LVS) · klayout (DRC) ─► sign-off
```

Notes from the harness README:

- Analog blocks live as **schematics**, not verilog; the wrapper instances an
  `openframe_user_project` cell (keep it a separate hierarchy level).
- Digital sub-blocks: run through LibreLane, pull `.pnl.v` (post-fill, powered)
  for LVS and the `.mag` from the stream-out step.
- `ext2spice short resistor` when extracting, to keep distinct port nets.

## 3. Vyges Loom — independent sign-off (trust-but-verify)

Alongside the PDK's magic/netgen/klayout, run [Vyges Loom](https://vyges.com/products/loom)
as a second, independent check. Each engine exits non-zero on a violation, so they run as
build gates rather than as reports someone has to read.
Install: <https://docs.vyges.com/installation.html>.

| Loom engine | Why we run it | Stage |
| --- | --- | --- |
| `vyges loom lvs` | Compares two netlists by graph isomorphism, independent of net names — catches a connectivity change that the drawing does not show. | schematic, and again vs layout |
| `vyges loom meas` | Extracts a scalar from a simulated sweep or capture: gain, bandwidth, phase margin, spectral SNR/THD. | once the AC and jitter benches exist |
| `vyges loom extract` | RC parasitics from layout (DEF/GDS → SPEF) to re-simulate against. | after layout |
| `vyges loom drc` | Geometric DRC (GDS + rule deck → JSON). | sign-off |
| `vyges loom sta-si` | Timing on the digital wrapper and divider. | once the wrapper exists |
| `vyges loom gds-view` | Layered render with violation overlay. | layout review |

Commands actually run against this block, with their results, are in
[`implementation.md`](implementation.md).

## 4. This IP's sims

- `sim/ringvco_feasibility.spice` — supply-starved sanity ring; **oscillates
  ~1.11–1.17 GHz** (tt/3.3 V/27 °C). Proves the process frequency capability.
- `sim/ringvco_current_starved.spice` — per-stage current-starved VCO topology
  for **wide tuning** (the production VCO). WIP: correct topology, needs the
  usual device-sizing / bias-point iteration to lock in the tuning range +
  corners. Run: `sim/run_tuning_sweep.sh`.
