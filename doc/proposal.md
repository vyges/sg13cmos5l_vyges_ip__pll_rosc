# Chipalooza Challenge #2 (IHP SG13CMOS5L) — Proposal: Ring-Oscillator PLL

> **Proposal submission — Chipalooza Challenge #2 (IHP SG13CMOS5L), 2026-07-22.**
> Block type: **PLL / clock multiplier** (analog-mixed-signal). Licence:
> **Apache-2.0**. Public repository: `github.com/vyges/vyges-ring-oscillator-pll`.
> Per the rules, this document is written to become part of the IP block's
> repository documentation, so personal and institutional details, designer CVs,
> and the test-equipment list are **omitted here and sent separately**.

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
- **Pulled by a real integration need, not a demo.** This block is on the
  critical path of the designer's own SoC work — a programmable on-chip clock
  multiplier is a hard dependency for the systems being built around it, which is
  why it is worth taking all the way to silicon and maintaining as catalog-grade
  IP rather than a one-off. That gives the block an owner with a stake in its
  correctness well past tapeout.
- **Universally reusable.** A clock multiplier is a core SoC primitive; the CMOS
  topology ports across PDKs (sky130 / GF180 / SG13 family).
- **Programmable clock source for other blocks.** With a register-set ÷N and an
  output post-divider, the same block serves many f_out targets — generic SoC
  clocking *and* the bit / ½-rate bit clock for **high-speed serial transmitters
  (LVDS / SerDes)**. That makes it a natural component for *other* slot projects to
  build a system around — the kind of composability the challenge is designed to reward.
- **Digital-friendly by design** (a challenge requirement): enable/disable, ÷N
  select and lock status over the harness control bus; bias taken from the
  harness's bandgap-referenced V/I references.
- **Right-sized for SG13CMOS5L.** All-CMOS, no exotic devices, ≤5 metals.

## 3. Architecture

A **self-biased, dual-control-path ring-VCO PLL** with an integrated **÷N
divider** and **digital lock detect**:

```
ref_clk ─►[ PFD ]─►[ CP + filter ]─►[ ring VCO ]─► clk_out
             ▲                                  │
             └──────────[ ÷N divider ]──────────┘
                              ▲
                   [ enable, N[..], lock ] ◄── control bus
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
| `clk_out` | out | digital-drive pad | **dedicated** | multiplied output — up to 800 MHz; **cannot go through a mux** |
| `enable` | in | control bus | per-project (power-up/enable) | PLL enable / power-gate handshake |
| `N[k-1:0]` | in | control bus | shared bus | ÷N divider select |
| `lock` | out | status bus | shared bus | digital lock indicator |
| `ibias` / `vbias` | in | analog (bias) | shared (harness refs) | iDAC current + vref voltage bias (see §6) |
| `vctrl_test` | out | analog | **muxable** (shared analog) | test port: VCO control voltage (observability) |
| `clk_div_test` | out | control bus | shared bus | test port: divided-down clock for freq/lock/jitter capture |
| `VDD33` / `VDD12` / `VSS` | — | supply | harness | 3.3 V analog / 1.2 V digital / ground |

**Series-resistance note (per the rules).** `vctrl_test` and the bias inputs are
high-impedance or low-current, so analog-mux series resistance is not critical for
them — any switch resistance the harness finds convenient is acceptable, since no
appreciable current flows and no IR drop develops. `ref_clk` and `clk_out` are the
only pins we ask to be **dedicated**: `clk_out` reaches several hundred MHz and
cannot tolerate the capacitance and resistance of a mux path, and `ref_clk`
requires a clean edge. No sole-pin analog access is requested.

## 5. Target specification

| Parameter | Min | Typ | Max | Absolute limit |
|---|---|---|---|---|
| Reference in | 10 MHz | 25 MHz | 50 MHz | — |
| Output range (programmable ÷N) | 100 MHz | — | 800 MHz | ≈950 MHz (measured VCO f_max, §7) |
| Feedback divider N (register-set) | 4 | — | 64 | integer |
| Output post-divider (÷1/2/4/8) | ÷1 | — | ÷8 | — |
| VCO gain Kvco | 1.0 GHz/V | 1.5 GHz/V | 2.1 GHz/V | — |
| Supply (analog) | 3.0 V | 3.3 V | 3.6 V | 3.6 V |
| Supply (digital) | 1.08 V | 1.2 V | 1.32 V | 1.32 V |
| Lock time (cold, worst corner) | — | 6 µs | 20 µs | — |
| Period jitter (pk-pk) | — | 6 ps | 12 ps | — |
| RMS jitter (integrated) | — | 3 ps | 5 ps | — |
| Phase noise @ 1 MHz offset | — | −95 dBc/Hz | −88 dBc/Hz | — |
| Reference spur | — | −45 dBc | −40 dBc | — |
| Output duty cycle (÷2 stage) | 45 % | 50 % | 55 % | — |
| Power @ f_out (scales w/ freq) | — | 5 mW | 8 mW | — |
| Temperature (commercial) | −40 °C | 27 °C | 110 °C | 125 °C |

Numbers are honest targets for a **ring-oscillator** PLL on 130 nm (a ring VCO is
intentionally more conservative than an LC oscillator) and are grounded in the
proposal-window simulations of §7 — the output range, Kvco and lock time are set
*inside* what we have already measured rather than beyond it. Jitter, phase noise
and spur figures are design targets to be characterized during schematic design
and **verified in post-layout PVT**; the spec is set to be attractive to an SoC
integrator, and any mid-design change is submitted for approval per the rules.

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

## 7. Feasibility — every sub-block prototyped in-process

This is not a paper proposal. We stood up the full IHP open-analog flow
(IIC-OSIC-TOOLS: ngspice-46 + SG13CMOS5L PDK, PSP103/OSDI) and have **simulated
all five sub-blocks of the PLL in-process**, plus closed the loop behaviourally.

| Sub-block | Level | Result |
|---|---|---|
| **Ring VCO** | transistor | 7-stage current-starved, `sg13_lv` (1.2 V): tunes **21 MHz → 957 MHz** over vctrl 0.45–1.2 V; **Kvco ≈ 1.5–2 GHz/V** in the 0.6–0.9 V linear band; rail-to-rail |
| **÷16 divider** | standard cell | 4 toggle FFs (`sg13cmos5l_dfrbp_1`): 160 MHz in → exact **80 / 40 / 20 / 10 MHz** |
| **PFD** | standard cell | 2 DFF + NAND reset + POR: ref leading div by 20 ns → UP ≈ 18 %, DOWN ≈ 0.3 % (correct "pump up") |
| **Charge pump** | transistor | current-steering off a 5 µA iDAC reference: UP ≈ 6.26 µA, DOWN ≈ 6.06 µA, stable hold (≈ 3 % mismatch — a known spur source, §12) |
| **Closed loop** | behavioural | type-II CP-PLL around the *measured* VCO, f_ref = 10 MHz, N = 16: **locks in ≈ 5.6 µs**, vctrl → 0.589 V, f_out → **160.00 MHz**, phase error → 0 |

An earlier fixed-frequency check on the 3.3 V `sg13_hv` devices (single inverter,
DC trip 1.465 V; 5-stage ring at ≈ 1.11–1.17 GHz) corroborates the headroom.

**What this establishes.** The VCO covers the proposed 100–800 MHz output range
with margin at both ends; the divider, PFD and charge pump each behave correctly
against their reference; and the loop acquires and locks within the 5 µs typical
lock-time target. The remaining work is engineering — sizing, corners, layout —
rather than answering whether the architecture closes on this process.

**Known limitation, stated plainly.** The **all-transistor** closed loop was
attempted and hits an ngspice convergence wall: both runs acquire correctly
(vctrl → 0.589 V, divider → 10 MHz) but the simulator aborts before lock, because
GHz VCO edges, charge-pump switching and a microsecond settling time in one
transient is too stiff. Loop-level verification is therefore done behaviourally
(above) with transistor-level verification per sub-block; full-fidelity mixed
simulation uses a **Verilog-A VCO** in the schematic window. This is a
verification-methodology constraint, not a circuit risk.

**Validity for SG13CMOS5L:** the work above runs on the SG13CMOS5L PDK, using the
`sg13_lv`/`sg13_hv` MOS models and the `sg13cmos5l` standard-cell library and its
SPICE views. The device models are shared with SG13G2, so earlier SG13G2
characterization carries over directly. The one process-specific item still open
is the **loop-filter capacitor** (§3, §12).

Netlists for all of the above are in the repository under `prototype/rosc-pll/`,
runnable from a clean clone.

**Why this process suits this block.** SG13CMOS5L is a **true 130 nm** front end
with a 1.2 V core, rather than a 130/180 nm hybrid. Shorter channel and lower
supply mean lower stage delay and better gm/I — i.e. **higher oscillation
frequency for less current, and better jitter per unit power**, which is exactly
the figure of merit for a ring-oscillator PLL. Our measured tuning range on this
PDK (21 MHz → 957 MHz, Kvco ≈ 1.5–2 GHz/V in the 0.6–0.9 V band) bears that out
and covers the 100–800 MHz target with headroom for ÷N and corners. The variant's
trimmed devices cost this block little: it is **all-CMOS**, so the absent SiGe
bipolars are irrelevant, and the harness supplies bandgap and bias externally.
The two that do carry design cost — **no MiM cap** and **no deep nwell** — are
addressed in §12.

First work after acceptance: consolidate the sub-blocks into a single sized
schematic, bring up the Verilog-A VCO mixed-signal loop, and settle the
loop-filter capacitor realization (§12) — all inside the schematic gate.

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

**Sign-off basis.** The specification is met and signed off in **post-layout PVT
simulation** using open-source tools — this is what the challenge review gates
score, and it is fully in-house. Silicon measurement below is post-shuttle
characterization.

**In-house, with the equipment available** (open-source-EDA workstation, a Xilinx
FPGA board, and a USB-to-SPI adapter — full list sent separately):

- The FPGA generates `ref_clk` and drives the harness SPI bus (sweep `N`, enable,
  program iDAC/vref bias); it reads `lock` and the frequency code back over SPI.
- **Frequency / range** — an FPGA-fabric **frequency counter** gates the divided
  `clk_div_test` tap over a known interval to measure f_out/N across the ÷N range
  and reconstruct the output frequency. This is the primary in-house measurement
  and needs no analog instrument; it also sidesteps the QFN package bandwidth that
  makes a clean 800 MHz `clk_out` capture unreliable.
- **Lock** — coarse time-to-lock by timestamping the `lock` flag over SPI relative
  to an FPGA-driven enable/`ref_clk` step.

**Requires analog instrumentation not available in-house** (established in
post-layout simulation and published; measured on silicon only if
organizer-coordinated or collaborator lab equipment is available):

- Period / RMS **jitter** and **phase noise** (real-time scope / phase-noise
  analyser).
- **Reference spur** and output spectrum (spectrum analyser).
- `vctrl` analog settling and precise duty cycle (scope).

All four are reported from post-layout PVT simulation in the repository, with
measured silicon results added if and when the equipment is arranged.

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
- **Loop-filter cap area (no MiM, 4 thin metals).** The type-II loop wants a large
  C1, and MOM density is limited by the M1–M4 stack (TopMetal1 at 2 µm is too
  coarse for fingers). This is the block's principal area risk. Mitigation, in
  order: reduce Icp toward the 50 nA floor, raise R, narrow the loop bandwidth,
  and evaluate a **MOS capacitor biased in accumulation** as a higher-density C1
  — characterizing its C(V) and leakage across the vctrl range rather than
  assuming it. Sized and de-risked in the schematic/layout window.
- **Substrate noise with no deep nwell.** SG13CMOS5L has no isolated NMOS, so the
  VCO cannot sit in an isolated p-well — on a 16-slot shared die with a digital
  control bus, substrate coupling appears directly as reference spurs and a raised
  phase-noise skirt. We treat this as a **layout-discipline problem from day one**,
  not a late fix: concentric p+/n-well guard rings on clean bias, maximum distance
  from the digital bus and noisy neighbours, heavy on-slot decoupling, isolated
  clean routing for vctrl, and a charge-pump layout that does not compound the
  ~3 % up/down mismatch we already measured. Phase noise and spur levels are
  explicit deliverables in our test plan (§9), measured rather than asserted.
- **Fallback / breadth:** if the reviewer prefers a lower-risk first block, we can
  credibly commit to a **SAR ADC** (ADC prior art) or an **LDO** in the same
  slot/flow — but we recommend leading with the PLL for its gap-value.
