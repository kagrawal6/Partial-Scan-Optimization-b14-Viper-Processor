# Partial-Scan Optimization of ITC'99 b14 (Viper Processor)

ECE 553 project: insert a **partial scan chain** into the ITC'99 `b14` Viper processor so that a composite testability metric **M** is maximized. M trades off stuck-at test coverage (TC), area (A), pattern count (N), and max scan-chain length (L), with pin cost **P = 3** for a single chain.

Full-scan is not the target. The goal is to leave some flip-flops out of scan, keep TC above 40%, and raise M by cutting area and especially pattern count.

## Approach

1. Synthesize `b14` in full-scan mode and dump SCOAP controllability/observability (`CC0`, `CC1`, `CO`) from TetraMAX (`report_primitives -all`). Rank flip-flops by `D = CC0 + CC1 + CO` (easiest to hardest).
2. Build candidate **K-sets** from both ends of that list (low-SCOAP and high-SCOAP) rather than only the hardest flops.
3. Always keep coverage-critical flops in scan. Removing `state_reg` or `IR_reg[23]` dropped TC to ~30%.
4. Do not dump an entire wide register in or out of the chain; sample bits across registers when exploring K.
5. Sweep K, chain count, `compile_ultra -scan` vs `compile -scan`, and TetraMAX `set_atpg -coverage` until M peaks.

One scan chain always beat two: a second chain raised P more than it reduced N. The largest M gains came from a coverage **cap** in ATPG (fewer patterns) rather than from K alone.

Exploration notes and the 8 design points are in [`Agrawal.pdf`](Agrawal.pdf).

## Winning configuration (Partial 7)

| Parameter | Value |
|---|---|
| Non-scan FFs (K) | 20 highest-SCOAP flops |
| Scan style | Multiplexed flip-flop, **1 chain** |
| Scan FFs / chain length L | 195 |
| Synthesis | `compile_ultra -scan` then `compile -scan` |
| ATPG coverage goal | `set_atpg -coverage 75` |
| TC / A / N / P | 75.1% / ~8565 / 32 / 3 |
| **M** | **~2064** (best of the explored points) |

Non-scan cells (plain `DFFARX2_LVT` in the netlist):

- `reg1_reg[3]`–`reg1_reg[19]`
- `B_reg`
- `d_reg[0]`, `d_reg[1]`

`state_reg`, `IR_reg[23]`, `wr_reg`, and `rd_reg` remain in the scan chain.

DFT ports: `SERIAL_IN`, `SCAN_EN`, `SERIAL_OUT`. Scan clock is `clock` (100 ns period, 45/55 ns pulse). Reset is active-high on `reset`.

## Repository contents

| File | Description |
|---|---|
| `synthesis_pscan.tcl` | Design Compiler / DFT Compiler script: compile, exclude K flops, insert 1 scan chain, write netlist + STIL + reports |
| `tmax_pscan.tcl` | TetraMAX ATPG script: DRC, stuck-at ATPG with coverage 75, write patterns |
| `b14_pscan.vg` | Synthesized SAED32 LVT partial-scan netlist |
| `b14_pscan.stil` | Test protocol (scan chain, timing, load/unload) |
| `b14_pattern_pscan.v` | Binary internal-scan ATPG patterns |
| `Agrawal.pdf` | Selection rationale and exploration table |

RTL is not in this repo. Synthesis reads `../rtl/b14.vhd` from the CAE working directory below. The SAED32 LVT library path is hardcoded in `tmax_pscan.tcl`.

## How to run

Scripts expect to be sourced on the CAE machines from `/filespace/k/kagrawal24/ece553/do_synth` (RTL at `../rtl/b14.vhd`, reports/results written under that directory). Copy or sync this repo’s `.tcl` files there before running.

### 1. Synthesis (`synthesis_pscan.tcl`)

```bash
cd /filespace/k/kagrawal24/ece553/do_synth
/cae/apps/bin/design_vision
```

In Design Vision:

```tcl
source synthesis_pscan.tcl
```

This writes:

- `results/b14_pscan.vg`, `results/b14_pscan.ddc`, `results/b14_scan_pscan.def`, `results/b14_pscan.stil`
- `reports/p2/area_b14_pscan.rpt`, `timing_b14_pscan.rpt`, `power_b14_pscan.rpt`, `chain_b14_pscan.rep`, `cell_b14_pscan.rep`

### 2. ATPG (`tmax_pscan.tcl`)

After synthesis finishes:

```bash
cd /filespace/k/kagrawal24/ece553/do_synth
/cae/apps/bin/oldver/tmax
```

In TetraMAX:

```tcl
source tmax_pscan.tcl
```

This prints the **Uncollapsed Stuck Fault Summary** and **Pattern Summary** in TetraMAX and writes the binary pattern file `b14_pattern_pscan.v`.
