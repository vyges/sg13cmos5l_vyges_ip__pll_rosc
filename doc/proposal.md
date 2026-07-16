# Chipalooza Challenge #2 (IHP SG13CMOS5L) — Proposal: Ring-Oscillator PLL

> Draft for the Chipalooza Challenge #2 (IHP SG13CMOS5L), proposals due 2026-07-27
> (grace to 2026-08-10 for this first IHP run). Status: internal working draft.
> Target repo (private until submission): `github.com/vyges/vyges-ring-oscillator-pll`.
> Per the rules, this document becomes part of the IP block's repository
> documentation — institutional/personal details and the designer CV are kept
> **out** of this main document and sent separately.

## 1. Summary

We propose a **self-biased ring-oscillator PLL with an integrated ÷N feedback
divider and digital lock detect** for the IHP **SG13CMOS5L** process — the one
block on the original Chipalooza list that *"no project team produced a
tapeout-ready layout"* for. It is a foundational clock-multiplier every
mixed-signal SoC needs, designed from the start to drop into an openframe analog
slot and interface cleanly to a digital control/status bus.

The design is **all-CMOS** (ring VCO, PFD, charge pump, ÷N divider, digital
wrapper), which maps directly onto SG13CMOS5L's standard-cell + MOS device set —
no SiGe HBT, MiM capacitor, deep-N-well, or Schottky device is required (none of
which SG13CMOS5L provides). This makes the block a clean fit for the simplified
5-level-metal CMOS-only process.

## 2. Why this block

- **Fills the stated gap.** The PLL was requested at Efabless Chipalooza #1 and
  never reached tapeout-ready layout. Delivering it is high-value and visible.
- **Universally reusable.** A clock multiplier is a core SoC primitive; the CMOS
  topology ports across PDKs (sky130 / GF180 / SG13 family).
- **Digital-friendly by design** (a challenge requirement): enable/disable, ÷N
  select and lock status over the harness control bus; bias taken from the
  harness's bandgap-referenced V/I references.
- **Right-sized for SG13CMOS5L.** All-CMOS, no exotic devices, ≤5 metals.

## 3. Architecture

A **self-biased, dual-control-path ring-VCO PLL** with an integrated **÷N
divider** and **digital lock detect**:

```
ref_clk ─► [ PFD ] ─► [ charge pump + loop filter ] ─► Vctrl ─► [ ring VCO ]─► clk_out
              ▲                                                        │
              └──────────────── [ ÷N feedback divider ] ◄─────────────┘
                                        ▲
              [ digital control/status: enable, N[..], lock ] ◄─ harness control bus
```

Sub-blocks: phase-frequency detector, charge pump + self-bias, per-stage
current-starved ring-VCO, ÷N divider, lock detector, and a thin digital wrapper
for the control/status interface (synthesized via LibreLane).

**SG13CMOS5L process notes that shape the design:**
- **No MiM capacitors.** The charge-pump **loop-filter capacitor is realized as
  MOM (metal-finger) and/or poly cap** within the 5-metal stack — sized in the
  proposal-window feasibility work. This is the single most process-specific
  design decision and is called out explicitly.
- **5-level metal (4 thin + 1 thick).** Layout, the loop-filter MOM cap, and slot
  routing are all planned within 5 metals.
- **All-CMOS devices** (`sg13_hv` 3.3 V for the analog core; `sg13_lv` 1.2 V for
  digital) — shared with SG13G2, so device models are common (see §7).

## 4. I/O and test ports

| Signal | Dir | Domain | Purpose |
|---|---|---|---|
| `ref_clk` | in | pad (digital-drive) | reference clock (~10–50 MHz) |
| `clk_out` | out | pad (digital-drive) | multiplied output clock |
| `enable` | in | control bus | PLL enable / power-gate handshake |
| `N[k-1:0]` | in | control bus | ÷N divider select |
| `lock` | out | status bus | digital lock indicator |
| `vbias_v` / `vbias_i` | in | analog (bias) | bandgap-referenced V/I bias from harness |
| `vctrl_test` | out | analog (mux'd) | **test port:** VCO control voltage (observability) |
| `clk_div_test` | out | control bus | **test port:** divided-down clock for lock/jitter capture |
| `VDD33` / `VDD12` / `VSS` | — | supply | 3.3 V analog / 1.2 V digital / ground |

Analog pins are shared through the harness analog mux; pad↔project series
resistance tolerance for `vctrl_test`/bias will be stated so mux switches can be
sized. No sole-pin access is requested.

## 5. Target specification

| Parameter | Min | Typ | Max | Absolute limit |
|---|---|---|---|---|
| Reference in | 10 MHz | 25 MHz | 50 MHz | — |
| Output range (÷N) | 100 MHz | — | 800 MHz | VCO f_max (see §7) |
| Supply (analog) | 3.0 V | 3.3 V | 3.6 V | 3.6 V |
| Supply (digital) | 1.08 V | 1.2 V | 1.32 V | 1.32 V |
| Lock time | — | < few µs | — | — |
| Period jitter (goal) | — | single-digit ps | — | — |
| Temperature (commercial) | −40 °C | 27 °C | 110 °C | 125 °C |

Targets are refined by the proposal-window feasibility sims (§7) and verified in
post-layout PVT. The spec is set to be attractive to an SoC integrator; changes
mid-design will be submitted for approval per the rules.

## 6. Harness integration (openframe slot)

Authored as an `openframe_user_project`-style analog cell fitting one of the 16
pallet slots:

- **Power:** 3.3 V from the pallet's pMOS power switch (enable-gated); 1.2 V for
  the digital wrapper.
- **Bias:** consumes the harness's **bandgap-referenced voltage + current** rails
  for charge-pump / VCO bias — no on-slot bandgap needed (per the resource list:
  1.2 V bandgap, up to 2 bias voltages + 2 current sources).
- **Digital bus:** `enable`, `N[..]`, `lock`, and the test taps over the harness
  control/status interface (≤16 digital control/test signals available).
- **Analog/clock I/O:** `ref_clk` / `clk_out` / `vctrl_test` via the configurable
  pads (per the harness `config.txt`).

*(Slot footprint/pinout is TBD upstream; the design is parameterized to target
the footprint once the template repo publishes it.)*

## 7. Feasibility — demonstrated, and valid for SG13CMOS5L

We stood up the full IHP open-analog flow (IIC-OSIC-TOOLS: ngspice-46 + PDK,
PSP103/OSDI) and simulated a ring VCO in-process:

- **A single 3.3 V `sg13_hv` inverter** characterizes cleanly — full 0→3.3 V
  swing, DC trip 1.465 V.
- **A 5-stage ring VCO oscillates at ~1.11–1.17 GHz** (tt, 27 °C, full-rail). The
  process comfortably covers the 100–800 MHz PLL target **with margin** — headroom
  for the ÷N range and corners.

**Validity for SG13CMOS5L:** the feasibility was run with the `sg13_hv`/`sg13_lv`
MOS device models, which SG13CMOS5L **shares with SG13G2** (the CMOS5L PDK
symlinks its device models from the SG13G2 tree). The ring VCO uses only these
MOS devices, so the result carries over directly. The only process-specific item
to finalize is the **MOM/poly loop-filter cap** (§3) — a layout/sizing task, not
a feasibility risk.

Remaining proposal-window work: finalize the current-starved VCO + PFD/CP device
plan, size the MOM/poly loop-filter cap, and submit early (grace exists but the
shuttle date is fixed — earlier = more downstream design time).

## 8. Staged milestones (aligned to the challenge review gates)

| Stage | Deliverable | Review gate |
|---|---|---|
| Proposal | this document + I/O + target spec + test plan | **wk of Jul 27** |
| Schematic | xschem schematic + ngspice: VCO tuning, PFD/CP, ÷N, lock; RNM golden model + TB | **wk of Aug 31** (schematic + pre-layout sim) |
| Layout | magic layout of analog sub-blocks + LibreLane digital wrapper; MOM loop-filter cap; DRC-clean | **wk of Sept 28** (layout + post-layout sim) |
| Final | top DRC/LVS, RC-extracted PVT re-sim, slot integration; sign-off summary | **wk of Oct 19** (final review) |
| Tapeout | shuttle submission | IHP tapeout (fixed) |
| Post-Si | dev-board characterization: measured freq/lock/jitter in repo | (post-shuttle) |

## 9. Test plan (validation by measurement)

- **Bench:** dev board with the shuttle die; supply the 3.3 V/1.2 V rails and
  bandgap-referenced bias; drive `ref_clk` from a signal generator across
  10–50 MHz; sweep `N[..]`.
- **Frequency/range:** measure `clk_out` (and `clk_div_test`) on a
  counter/scope across ÷N settings; verify 100–800 MHz coverage over the
  commercial temperature range.
- **Lock:** capture lock time and `lock` assertion vs `ref_clk` step; observe
  `vctrl_test` settling via the analog mux.
- **Jitter:** period/cycle-to-cycle jitter from `clk_out` on a real-time scope /
  jitter analyzer.
- **Corners:** repeat over available boards/temperature; correlate to post-layout
  PVT sim. Equipment list sent separately per the rules.

## 10. Deliverables (catalog-grade, self-contained, public repo)

Schematic + layout + extracted netlists, RNM model + testbenches, multi-corner
sim + jitter/lock results, DRC/LVS/STA sign-off summary (challenge signoff-summary
format), full docs to re-create and integrate, and — post-silicon —
characterization data. **Apache-2.0**, public git repo, reproducible/verifiable
with **open-source EDA** (the repo's sign-off scripts run from a clean clone). Any
AI used in design is **not required** for an end user to use, verify, or modify
the block — sign-off is fully deterministic.

## 11. Approach / differentiator

- **Golden-reference, trust-but-verify:** an RNM behavioral model + testbench as
  the functional golden the transistor design must match (frequency/lock/jitter).
- **Independent sign-off:** a second, independent DRC / LVS / RC-extract / STA
  check alongside magic/netgen/klayout.
- **Agentic closure:** a validated sky130 pilot drives the
  sim → layout → DRC/LVS → fix loop with model/engine verdicts in the loop — the
  mechanism for reaching *tapeout-ready* where prior attempts stalled. (Used to
  *build* the IP; **not** required to *use* it.)
- **OpenFrame + LibreLane fluency:** direct, current experience with this exact
  carrier (wrapper/PDN/assembly), including a fully generator-driven OpenFrame
  flow.

*(Designer identity, institution, and CV are provided separately per the rules
and are intentionally omitted here.)*

## 12. Honest risk assessment

- **New PDK (SG13CMOS5L)** and **early analog depth** (this is our first full
  custom analog IP). Mitigated by: an existing sky130 ring-VCO PLL design to port
  (not a blank sheet); the shared SG13G2 MOS models (feasibility already proven);
  the staged review structure (progress is reviewed/funded even if the full PLL
  slips); an independent-verification safety net; and the agentic loop that
  de-risks the layout→sign-off grind.
- **Process-specific unknown:** the MOM/poly loop-filter cap area/quality in
  5-metal — sized and de-risked during the schematic/layout window.
- **Fallback / breadth:** if the reviewer prefers a lower-risk first block, we can
  credibly commit to a **SAR ADC** (ADC prior art) or an **LDO** in the same
  slot/flow — but we recommend leading with the PLL for its gap-value.
