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
- **No MiM capacitors + a small slot.** The charge-pump loop-filter cap is
  **MOM (metal-finger) and/or poly** in the 5-metal stack. With the harness slot
  at **~520 × 250 µm** (per the organizer), a large loop cap will not fit, so the
  loop is designed around a **small cap**: a higher-impedance loop filter and, if
  needed, a **digital-assisted / dual-path lock** (coarse digital acquisition +
  fine analog trim) to keep the MOM cap tiny while preserving lock time and
  jitter. This is the central schematic decision, sized in the schematic window.
- **5-level metal (4 thin + 1 thick).** Layout, the MOM cap, and slot routing are
  all planned within 5 metals and the small-slot footprint.
- **All-CMOS devices** (`sg13_hv` 3.3 V for the analog core; `sg13_lv` 1.2 V for
  digital) — shared with SG13G2, so device models are common (see §7).

## 4. I/O and test ports

Per the organizer, the proposal must list I/O and mark **dedicated vs muxable**
so pins can be allotted around the padframe (budget: ~2 dedicated **or** ~4
shared pins per project). Our request: **2 dedicated** (clean clocks) + the rest
on the shared control bus / muxable analog.

| Signal | Dir | Domain | Pad allocation | Purpose |
|---|---|---|---|---|
| `ref_clk` | in | digital-drive pad | **dedicated** | reference clock (~10–50 MHz) — clean edge required |
| `clk_out` | out | digital-drive pad | **dedicated** | multiplied output — up to ~800 MHz; **cannot go through a mux** |
| `enable` | in | control bus | per-project (power-up/enable) | PLL enable / power-gate handshake |
| `N[k-1:0]` | in | control bus | shared bus | ÷N divider select |
| `lock` | out | status bus | shared bus | digital lock indicator |
| `ibias` / `vbias` | in | analog (bias) | shared (harness refs) | iDAC current + vref voltage bias (see §6) |
| `vctrl_test` | out | analog | **muxable** (shared analog) | test port: VCO control voltage (observability) |
| `clk_div_test` | out | control bus | shared bus | test port: divided-down clock for freq/lock/jitter capture |
| `VDD33` / `VDD12` / `VSS` | — | supply | harness | 3.3 V analog / 1.2 V digital / ground |

`vctrl_test`/bias tolerate the analog-mux series resistance (value TBD from the
organizer); `ref_clk`/`clk_out` are the only pins we ask to be **dedicated**. No
sole-pin analog access is requested.

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

Authored as an `openframe_user_project`-style analog cell fitting a **~520 × 250 µm**
slot:

- **Power:** 3.3 V from the slot's auto-drawn (waffle) pMOS power switch
  (enable-gated); 1.2 V for the digital wrapper. Our VCO + charge-pump current
  draw will be stated so the switch is sized (organizer: it can be made as large
  as needed).
- **Bias — mapped to the harness references:** the charge-pump current is drawn
  from the harness **5-bit current-reference iDAC (50 nA–10.32 µA, 32 values / 4
  scales)**; VCO/CP operating points are set from the **voltage reference** (low
  0.3–2.4 V / 0.3 V steps; high 0.4–3.2 V / 0.4 V steps). **No on-slot bandgap
  needed** — the design programs directly off these.
- **Digital control/status:** over the harness **SPI bus** (currently 128-bit
  control + 128-bit status; ~16 bits/project going forward). We use a small
  field: `enable`, `N[..]` (÷N), `lock`, plus the divided test-clock tap (§4/§9).
- **Analog/clock I/O:** `ref_clk` / `clk_out` on **dedicated** pads;
  `vctrl_test`/bias on shared/muxable pads (§4).

*(Exact slot footprint/pinout finalizes with the template repo; the design is
parameterized to the ~520 × 250 µm budget.)*

### Proposed control/status contract (the organizer invited interface ideas)

Our block needs a small, self-describing field on the shared bus; we propose a
minimal per-project **register map** that any project can adopt:

| Field | Bits | Dir | Meaning |
|---|---|---|---|
| `EN` | 1 | ctrl | enable / power-up handshake |
| `NDIV` | 6 | ctrl | ÷N select (1–64) |
| `IBIAS_SEL` | 5 | ctrl | iDAC current-scale select (maps to the harness 5-bit iDAC) |
| `TEST_SEL` | 2 | ctrl | route `clk_div_test` / `vctrl_test` observability |
| `LOCK` | 1 | status | lock detect |
| `ALIVE` / `FCODE` | 8 | status | VCO alive + coarse frequency code (for capture) |

Two design principles we'd advocate for the harness contract generally: **(1) a
tiny machine-readable `key: value` register description per project** (so
top-level integration + the sequencer are auto-generated, not hand-wired), and
**(2) a divided/observable clock tap per project** so lock/jitter are measurable
through a low-bandwidth path. Both are cheap and make the whole pallet
self-documenting — an area where Vyges can contribute tooling.

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

- **Bench:** QFN-64 packaged part (organizer's preferred path) on a dev board
  (Caravel-dev-board-like, USB-to-SPI); supply the 3.3 V/1.2 V rails, program the
  iDAC/vref bias over SPI; drive `ref_clk` from a signal generator across
  10–50 MHz; sweep `N[..]`.
- **Frequency/range:** the **divided `clk_div_test`** is the primary, reliable
  measurement path — QFN package bandwidth makes a clean ~800 MHz `clk_out`
  capture unreliable, so we observe the divided clock on a counter/scope across
  ÷N and reconstruct the output frequency; the dedicated `clk_out` pad is a
  best-effort direct check. Verify 100–800 MHz coverage over temperature.
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
