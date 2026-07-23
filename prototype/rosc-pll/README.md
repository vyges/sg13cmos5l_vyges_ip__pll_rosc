# Ring-oscillator PLL — prototype netlists (sg13cmos5l)

Hands-on prototype exercising the analog/mixed-signal toolchain on `ihp-sg13cmos5l`
(ngspice inside the `iic-osic-tools` container). These netlists back the
feasibility section of the proposal ([`../../doc/proposal.md`](../../doc/proposal.md)),
and the analog flow they run in is documented in
[`../../doc/analog-flow.md`](../../doc/analog-flow.md).

| File | Block | What it shows |
|---|---|---|
| `rosc_vco.spice` | VCO | 7-stage current-starved ring osc; oscillates 155.7 MHz @ vctrl 0.6 V |
| `rosc_vco_sweep.spice` | VCO | tuning curve — freq vs vctrl (21 MHz → 957 MHz); Kvco ≈ 1.5–2 GHz/V |
| `pll_lock.spice` | full loop | behavioral type-II CP-PLL around the measured VCO; **locks in ~5.6 µs** at 160 MHz |
| `div16.spice` | ÷16 divider | 4 toggle FFs (stdcell `sg13cmos5l_dfrbp_1`); 160 MHz → 10 MHz |
| `pfd.spice` | PFD | tri-state phase-freq detector (2 DFFs + NAND reset + POR); UP tracks phase lag |
| `charge_pump.spice` | charge pump | current-steering CP off a 5 µA iDAC ref; ~6.2 µA up/down onto vctrl |

## Run (PDK + ngspice from the container)

```sh
docker run --rm -v $PWD:/work --entrypoint bash \
  hpretl/iic-osic-tools:latest -lc 'cd /work && ngspice -b rosc_vco.spice'
```

Models resolve via `.lib …/cornerMOSlv.lib mos_tt` (typ corner); the divider also
`.include`s `sg13cmos5l_stdcell.spice`. Paths inside the netlists assume the
container's `/foss/pdks/ihp-sg13cmos5l`.

**Status — all five blocks:** VCO ✅ (transistor) · ÷16 divider ✅ (cells) ·
PFD ✅ (cells) · charge pump ✅ (transistor) · loop filter (passive) ·
closed-loop lock ✅ (behavioral). Next: mixed-signal closed loop (real ring VCO) for
jitter/ripple, then layout → extract → LVS.
