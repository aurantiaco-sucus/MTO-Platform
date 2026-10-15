# Problems — in-scope worklist

The problem suites to make run under Octave, and to carry into the Rust port. **419 of 435** problem classes.

Excluded suites and their reasons are in `prob.md`, which also holds the full catalogue.

Paths are relative to `MTO/Problems/` unless stated otherwise.

| Tier | Classes | Action |
| --- | --- | --- |
| Pure Octave | 337 | Nothing beyond the shared framework fixes in `AGENTS.md`. |
| MEX build | 82 | Build the CEC `.cpp` with `mkoctfile --mex`, then run Octave from the repo root. |

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

## Real-world Applications — 7 classes in 5 suites

| Suite | Classes | Name range | Data files | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `Real-world Applications/Multiobjective Sensor Coverage Problem` | 2 | `MOSCP` … `MOSCP2` | 1 .mat | IN | — |
| `Real-world Applications/Multiobjective Synchronous Optimal Pulse-width Modulation` | 2 | `SOPM_MTMO1` … `SOPM_MTMO2` | — | IN | — |
| `Real-world Applications/Parameter Extraction of Photovoltaic Models` | 1 | `PEPVM` | — | IN | — |
| `Real-world Applications/Planar Kinematic Arm Control Problem` | 1 | `PKACP` | — | IN | — |
| `Real-world Applications/Sensor Coverage Problem` | 1 | `SCP` | 1 .mat | IN | — |

## Data to carry into the port

Everything here is **problem-construction data** — shift vectors, rotation matrices, load
and line data used to build the objective functions. None of it is reference-optimum data:
all 80 `getOptimum` implementations are analytic (typically a reference set generated on
the unit simplex), so no Pareto front is read from disk anywhere in the tree.

| Format | Files | Read by | What it is |
| --- | --- | --- | --- |
| `.txt` | 1147 | `load(...,'-ascii')`; the CEC sources read theirs via `fscanf` | shift/rotation arrays and power-system data |
| `.mat` | 75 | `load()` | shift/rotation matrices and benchmark parameters |

`.txt` breakdown: 600 CEC19-MaTMO (`M/`, `SVector/`), 328 CEC17-SO `input_data`, 150
WCCI20-MTSO `Tasks`, 54 CEC22-SO `Data`, 15 CEC20-RWCO `Data`. `.mat` is the MATPOWER-format
subset plus the CEC17/19 rotation sets and benchmark parameters.

`.mat` is a MATLAB-proprietary container. Octave reads v6/v7 files; confirm each in-scope
`.mat` opens before depending on it, and prefer plain text or a portable binary format on
the Rust side. The CEC suites need no conversion — their C++ reads the `.txt` data directly.

