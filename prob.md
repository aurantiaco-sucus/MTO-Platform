# Problems — full inventory

All **435** problem classes that inherit `Problem`, grouped by suite.

Classes within a suite are homogeneous — same generator, same data files, differing only in benchmark index — so each suite is listed once with the first and last class name rather than enumerating every class.

Decision rules are in `AGENTS.md`.

Paths are relative to `MTO/Problems/` unless stated otherwise.

| Status | Classes | Meaning |
| --- | --- | --- |
| IN | 336 | Runs on Octave as-is, plus the shared framework fixes. |
| IN — MEX build | 81 | Verified to build and run, but needs a MEX build step. |
| MIXED | 2 | Both branches differ; see the row. |
| OUT | 16 | Excluded — MATPOWER, Python, or foreign toolbox. |

## Multi-task — 144 classes in 12 suites

| Suite | Classes | Name range | Data files | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `Multi-task/CEC17-MTSO` | 9 | `CEC17_MTSO1_CI_HS` … `CEC17_MTSO9_NI_LS` | 9 .mat | IN | — |
| `Multi-task/CEC19-MaTSO` | 6 | `CEC19_MaTSO1` … `CEC19_MaTSO6` | 12 .mat | IN | — |
| `Multi-task/Competitive-C2TOP` | 36 | `C2TOP_Case1_P1` … `C2TOP_Case4_P9` | 9 .mat | IN | — |
| `Multi-task/Competitive-C4TOP` | 15 | `C4TOP1` … `C4TOP9` | 2 .mat | IN | — |
| `Multi-task/Competitive-CPLX` | 20 | `CCPLX_Case1_P1` … `CCPLX_Case2_P9` | — | IN — MEX build | Rebuild `.cpp` with `mkoctfile --mex`. |
| `Multi-task/Constrained-CMT` | 9 | `CMT1` … `CMT9` | — | IN | — |
| `Multi-task/LSMaTSO` | 5 | `LSMaTSO1` … `LSMaTSO5` | 5 .mat | IN | — |
| `Multi-task/Many-task CEC-SO` | 2 | `MaT_CEC17_SO` … `MaT_CEC20_RWCO` | — | MIXED | `MaT_CEC17_SO` needs the CEC17 MEX; `MaT_CEC20_RWCO` is pure Octave. |
| `Multi-task/STOP` | 12 | `STOP1` … `STOP9` | 14 .mat | IN | — |
| `Multi-task/WCCI20-MTSO` | 10 | `WCCI20_MTSO1` … `WCCI20_MTSO9` | 150 .txt | IN — MEX build | Rebuild `.cpp` with `mkoctfile --mex`. |
| `Multi-task/WCCI20-MTSO-ErrorValue` | 10 | `WCCI20_MTSO_EV1` … `WCCI20_MTSO_EV9` | — | IN — MEX build | Rebuild `.cpp` with `mkoctfile --mex`. |
| `Multi-task/WCCI20-MaTSO` | 10 | `WCCI20_MaTSO1` … `WCCI20_MaTSO9` | — | IN | — |

## Multi-objective Single-task — 9 classes in 1 suite

| Suite | Classes | Name range | Data files | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `Multi-objective Single-task/DTLZ` | 9 | `DTLZ1` … `DTLZ9` | — | IN | — |

## Multi-objective Multi-task — 59 classes in 7 suites

| Suite | Classes | Name range | Data files | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `Multi-objective Multi-task/CEC17-MTMO` | 9 | `CEC17_MTMO1_CI_HS` … `CEC17_MTMO9_NI_LS` | 9 .mat | IN | — |
| `Multi-objective Multi-task/CEC19-MTMO-CPLX` | 10 | `CEC19_MTMO_CPLX1` … `CEC19_MTMO_CPLX9` | — | IN | — |
| `Multi-objective Multi-task/CEC19-MaTMO` | 6 | `CEC19_MaTMO1` … `CEC19_MaTMO6` | 600 .txt | IN | — |
| `Multi-objective Multi-task/CEC21-MTMO-CPLX` | 10 | `CEC21_MTMO_CPLX1` … `CEC21_MTMO_CPLX9` | — | IN | — |
| `Multi-objective Multi-task/Competitive-CMOMT` | 12 | `CMOMT1` … `CMOMT9` | — | IN | — |
| `Multi-objective Multi-task/MTMO-Instance` | 2 | `MTMO_Instance1` … `MTMO_Instance2` | 1 .mat | IN | — |
| `Multi-objective Multi-task/WCCI20-MaTMO` | 10 | `WCCI20_MaTMO1` … `WCCI20_MaTMO9` | — | IN | — |

## Stream-task — 21 classes in 4 suites

| Suite | Classes | Name range | Data files | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `Stream-task/AMTSO-Case1` | 9 | `AMTSO_Case1_P1` … `AMTSO_Case1_P9` | — | IN | — |
| `Stream-task/AMTSO-Case2` | 9 | `AMTSO_Case2_P1` … `AMTSO_Case2_P9` | — | IN | — |
| `Stream-task/AMaTSO10` | 1 | `AMaTSO10` | — | IN | — |
| `Stream-task/APKACP` | 2 | `APKACP_10` … `APKACP_20` | — | IN | — |

## Single-task — 179 classes in 8 suites

| Suite | Classes | Name range | Data files | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `Single-task/ATF` | 2 | `ATF1` … `ATF2` | — | IN | — |
| `Single-task/CEC06-CSO` | 24 | `CEC06_CSO1` … `CEC06_CSO9` | — | IN | — |
| `Single-task/CEC10-CSO` | 18 | `CEC10_CSO1` … `CEC10_CSO9` | — | IN | — |
| `Single-task/CEC17-CSO` | 28 | `CEC17_CSO1` … `CEC17_CSO9` | 12 .mat | IN | — |
| `Single-task/CEC17-SO` | 29 | `CEC17_SO1` … `CEC17_SO9` | 328 .txt | IN — MEX build | Rebuild `.cpp` with `mkoctfile --mex`. |
| `Single-task/CEC20-RWCO` | 57 | `CEC20_RWCO1` … `CEC20_RWCO9` | 15 .txt | IN | — |
| `Single-task/CEC22-SO` | 12 | `CEC22_SO1` … `CEC22_SO9` | 54 .txt | IN — MEX build | Rebuild `.cpp` with `mkoctfile --mex`. |
| `Single-task/Classical Function` | 9 | `Func_Ackley` … `Func_Weierstrass` | — | IN | — |

## Real-world Applications — 22 classes in 9 suites

| Suite | Classes | Name range | Data files | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `Real-world Applications/Competitive Multiobjective Optimal Power Flow` | 4 | `OPF_CMTMO1` … `OPF_CMTMO4` | — | OUT | MATPOWER required (external install) |
| `Real-world Applications/Global Trajectory Optimization` | 2 | `MGA_DSM_GTOP` … `MGA_GTOP` | 8 .mat | OUT | ESA ACT Space Mechanics Toolbox (foreign vendored code); MGA-DSM variant is also incomplete |
| `Real-world Applications/Multiobjective Optimal Power Flow` | 4 | `OPF_MTMO1` … `OPF_MTMO4` | — | OUT | MATPOWER required (external install) |
| `Real-world Applications/Multiobjective Sensor Coverage Problem` | 2 | `MOSCP` … `MOSCP2` | 1 .mat | IN | — |
| `Real-world Applications/Multiobjective Synchronous Optimal Pulse-width Modulation` | 2 | `SOPM_MTMO1` … `SOPM_MTMO2` | — | IN | — |
| `Real-world Applications/Optimal Power Flow` | 5 | `OPF_MTSO1` … `OPF_MTSO5` | — | OUT | MATPOWER required (external install) |
| `Real-world Applications/Parameter Extraction of Photovoltaic Models` | 1 | `PEPVM` | — | IN | — |
| `Real-world Applications/Planar Kinematic Arm Control Problem` | 1 | `PKACP` | — | IN | — |
| `Real-world Applications/Sensor Coverage Problem` | 1 | `SCP` | 1 .mat | IN | — |

## Policy Search — 1 classes in 1 suite

| Suite | Classes | Name range | Data files | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `Policy Search/MaT-Gym` | 1 | `MaT_Gym` | 1 .txt | OUT | Python + gymnasium / MuJoCo / Box2D |

## Excluded suites

**`Real-world Applications/Optimal Power Flow`** — 5 classes — MATPOWER required (external install)

Classes: `OPF_MTSO1, OPF_MTSO2, OPF_MTSO3, OPF_MTSO4, OPF_MTSO5`

MATPOWER is called from inside the objective function (`runpf` once per candidate per generation), so it sits on the evaluation hot path rather than being a setup step.

**`Real-world Applications/Multiobjective Optimal Power Flow`** — 4 classes — MATPOWER required (external install)

Classes: `OPF_MTMO1, OPF_MTMO2, OPF_MTMO3, OPF_MTMO4`

MATPOWER is called from inside the objective function (`runpf` once per candidate per generation), so it sits on the evaluation hot path rather than being a setup step.

**`Real-world Applications/Competitive Multiobjective Optimal Power Flow`** — 4 classes — MATPOWER required (external install)

Classes: `OPF_CMTMO1, OPF_CMTMO2, OPF_CMTMO3, OPF_CMTMO4`

MATPOWER is called from inside the objective function (`runpf` once per candidate per generation), so it sits on the evaluation hot path rather than being a setup step.

**`Policy Search/MaT-Gym`** — 1 classes — Python + gymnasium / MuJoCo / Box2D

Classes: `MaT_Gym`

**`Real-world Applications/Global Trajectory Optimization`** — 2 classes — ESA ACT Space Mechanics Toolbox (foreign vendored code); MGA-DSM variant is also incomplete

Classes: `MGA_DSM_GTOP, MGA_GTOP`

## Suites needing a MEX build

All three CEC `.cpp` sources were verified to compile with Octave's `mkoctfile --mex`, and the resulting `.mex` was verified to load, read its data, return the expected shape, and reproduce the correct CEC optimum convention: `cec17_func` returns exactly `100` for F1 evaluated at the shift vector.

| Suite | Classes | Source | Data |
| --- | --- | --- | --- |
| `Multi-task/Competitive-CPLX` | 20 | `cec14_func.cpp` | — |
| `Multi-task/WCCI20-MTSO` | 10 | `cec14_func.cpp` | 150 .txt |
| `Multi-task/WCCI20-MTSO-ErrorValue` | 10 | `cec14_func.cpp` | — |
| `Single-task/CEC17-SO` | 29 | `cec17_func.cpp` | 328 .txt |
| `Single-task/CEC22-SO` | 12 | `cec22_test_func.cpp` | 54 .txt |
| `Multi-task/Many-task CEC-SO` | 1 of 2 | `cec17_func.cpp` | shared |

Two traps, both confirmed by testing:

1. The sources open their data through a path **relative to the repo root** (`./Problems/Single-task/CEC17-SO/input_data/M_%d_D%d.txt`), so Octave must run from the directory containing `Problems/`, not from the suite folder.
2. `fopen` failure is not handled — the code prints an error and then calls `fscanf` on a `NULL` handle, which **segfaults**. Expect a hard crash, not a MATLAB error, if the working directory is wrong.
