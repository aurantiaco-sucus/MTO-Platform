# Algorithms — full inventory

All **140** algorithm classes that inherit `Algorithm` or `StreamAlgorithm`, with their
external dependencies and in-scope status for the Octave adaptation.

Paths are relative to `MTO/Algorithms/` unless stated otherwise.

Decision rules are in `AGENTS.md`. Summary:

| Status | Count | Meaning |
| --- | --- | --- |
| IN | 133 | Runs on Octave + Forge `statistics` plus the local `mapminmax` / `lhsdesign` shims. No external software. |
| PENDING | 0 | No missing helper remains; full runtime inventory is still unverified. |
| OUT | 7 | Excluded: MathWorks toolbox, Python, or foreign toolbox. |

Every in-scope algorithm additionally needs the shared Octave compatibility fixes listed in
`AGENTS.md` — those are framework-wide, not per-algorithm work.

`stats` and `kmeans` are **not** exclusions: Octave Forge `statistics` provides them,
verified against the call shapes used here.

## Single-task (SO) — 42 classes (38 in, 0 pending, 4 out)

| Class | Folder | Deps | Status |
| --- | --- | --- | --- |
| `C2oDE` | `Constraint Handling/C2oDE` | — | IN |
| `CAL_SHADE` | `Constraint Handling/CAL-SHADE` | stats | IN |
| `CCEF_ECHT` | `Constraint Handling/CCEF-ECHT` | — | IN |
| `CEDE_DRL` | `Constraint Handling/CEDE-DRL` | mapminmax shim | IN |
| `CORCO` | `Constraint Handling/CORCO` | — | IN |
| `DeCODE` | `Constraint Handling/DeCODE` | — | IN |
| `ECHT` | `Constraint Handling/ECHT` | — | IN |
| `FROFI` | `Constraint Handling/FROFI` | — | IN |
| `MTV_DE` | `Constraint Handling/MTV-DE` | — | IN |
| `VMCH` | `Constraint Handling/VMCH` | stats | IN |
| `DE` | `Differential Evolution/DE` | — | IN |
| `JADE` | `Differential Evolution/JADE` | stats | IN |
| `KLDE` | `Differential Evolution/KLDE` | DL Toolbox | OUT |
| `L_SHADE` | `Differential Evolution/L-SHADE` | stats | IN |
| `LSHADE44` | `Differential Evolution/LSHADE44` | stats | IN |
| `NL_SHADE_RSP` | `Differential Evolution/NL-SHADE-RSP` | stats | IN |
| `SHADE` | `Differential Evolution/SHADE` | stats | IN |
| `SaDE` | `Differential Evolution/SaDE` | — | IN |
| `jDE` | `Differential Evolution/jDE` | — | IN |
| `jSO` | `Differential Evolution/jSO` | stats | IN |
| `rank_DE` | `Differential Evolution/rank-DE` | — | IN |
| `rank_jDE` | `Differential Evolution/rank-DE` | — | IN |
| `EDAver` | `Estimation of Distribution/EDAver` | stats | IN |
| `CMA_ES` | `Evolution Strategy/CMA-ES` | — | IN |
| `DES` | `Evolution Strategy/DES` | — | IN |
| `IPOP_CMA_ES` | `Evolution Strategy/IPOP-CMA-ES` | — | IN |
| `LES` | `Evolution Strategy/LES` | Python | OUT |
| `OpenAI_ES` | `Evolution Strategy/OpenAI-ES` | — | IN |
| `R1_NES` | `Evolution Strategy/R1-NES` | — | IN |
| `SNES` | `Evolution Strategy/SNES` | — | IN |
| `sep_CMA_ES` | `Evolution Strategy/sep-CMA-ES` | — | IN |
| `xNES` | `Evolution Strategy/xNES` | — | IN |
| `xNES_as` | `Evolution Strategy/xNES-as` | stats | IN |
| `ABOM` | `Genetic Algorithm/ABOM` | Python | OUT |
| `GA` | `Genetic Algorithm/GA` | — | IN |
| `Global_GA` | `Genetic Algorithm/Global-GA` | — | IN |
| `AO` | `Swarm Intelligence/AO` | — | IN |
| `CSO` | `Swarm Intelligence/CSO` | — | IN |
| `EO` | `Swarm Intelligence/EO` | — | IN |
| `KLPSO` | `Swarm Intelligence/KLPSO` | DL Toolbox | OUT |
| `MPA` | `Swarm Intelligence/MPA` | — | IN |
| `PSO` | `Swarm Intelligence/PSO` | — | IN |

## Multi-task (MTSO) — 52 classes (51 in, 0 pending, 1 out)

| Class | Folder | Deps | Status |
| --- | --- | --- | --- |
| `DEORA` | `Competitive Multi-task/DEORA` | — | IN |
| `DEORA_MTDE` | `Competitive Multi-task/DEORA` | — | IN |
| `MTSRA` | `Competitive Multi-task/MTSRA` | stats | IN |
| `CEDA_MF` | `Constrained Multi-task/CEDA` | — | IN |
| `CEDA_MP` | `Constrained Multi-task/CEDA` | — | IN |
| `CMO_LKT` | `Constrained Multi-task/CMO-LKT` | stats | IN |
| `BoKTDE` | `Many-task/BoKT` | stats | IN |
| `BoKTGA` | `Many-task/BoKT` | stats | IN |
| `DTSKT` | `Many-task/DTSKT` | stats | IN |
| `EMaTO_MKT` | `Many-task/EMaTO-MKT` | kmeans, stats | IN |
| `KR_MTEA` | `Many-task/KR-MTEA` | — | IN |
| `MES_RET` | `Many-task/MES-RET` | — | IN |
| `sep_MES_RET` | `Many-task/MES-RET` | — | IN |
| `MaTDE` | `Many-task/MaTDE` | — | IN |
| `SBCMAES` | `Many-task/SBO` | — | IN |
| `SBGA` | `Many-task/SBO` | — | IN |
| `sep_SBCMAES` | `Many-task/SBO` | — | IN |
| `TNG_SNES` | `Many-task/TNG-NES` | — | IN |
| `TNG_SNES_EP` | `Many-task/TNG-NES` | — | IN |
| `TNG_xNES` | `Many-task/TNG-NES` | — | IN |
| `TRADE` | `Many-task/TRADE` | kmeans | IN |
| `ASCMFDE` | `Multi-factorial/ASCMFDE` | — | IN |
| `AT_MFEA` | `Multi-factorial/AT-MFEA` | — | IN |
| `EMTO_AI` | `Multi-factorial/EMTO-AI` | — | IN |
| `G_MFEA` | `Multi-factorial/G-MFEA` | — | IN |
| `LDA_MFEA` | `Multi-factorial/LDA-MFEA` | kmeans | IN |
| `MFDE` | `Multi-factorial/MFDE` | — | IN |
| `MFEA` | `Multi-factorial/MFEA` | — | IN |
| `MFEA_AKT` | `Multi-factorial/MFEA-AKT` | — | IN |
| `MFEA_DGD` | `Multi-factorial/MFEA-DGD` | — | IN |
| `MFEA_DV` | `Multi-factorial/MFEA-DV` | — | IN |
| `MFEA_GHS` | `Multi-factorial/MFEA-GHS` | — | IN |
| `MFEA_II` | `Multi-factorial/MFEA-II` | stats | IN |
| `MFEA_VC` | `Multi-factorial/MFEA-VC` | DL Toolbox, stats | OUT |
| `MFPSO` | `Multi-factorial/MFPSO` | — | IN |
| `SREMTO` | `Multi-factorial/SREMTO` | — | IN |
| `TLTLA` | `Multi-factorial/TLTLA` | — | IN |
| `BLKT_DE` | `Multi-population/BLKT-DE` | kmeans | IN |
| `EMEA` | `Multi-population/EMEA` | — | IN |
| `IMEA` | `Multi-population/IMEA` | — | IN |
| `MFMP` | `Multi-population/MFMP` | stats | IN |
| `MKTDE` | `Multi-population/MKTDE` | — | IN |
| `MTDE_ADKT` | `Multi-population/MTDE-ADKT` | stats | IN |
| `MTEA_AD` | `Multi-population/MTEA-AD` | stats | IN |
| `MTEA_HKTS` | `Multi-population/MTEA-HKTS` | — | IN |
| `MTEA_PAE` | `Multi-population/MTEA-PAE` | lhsdesign shim (pinned profile) | IN |
| `MTEA_SaO` | `Multi-population/MTEA-SaO` | — | IN |
| `MTES` | `Multi-population/MTES` | — | IN |
| `MTES_KG` | `Multi-population/MTES-KG` | — | IN |
| `sep_MTES_KG` | `Multi-population/MTES-KG` | — | IN |
| `SSLT_DE` | `Multi-population/SSLT` | mapminmax shim | IN |
| `SSLT_GA` | `Multi-population/SSLT` | mapminmax shim | IN |

## Multi-objective Single-task (MTSO) — 15 classes (15 in, 0 pending, 0 out)

| Class | Folder | Deps | Status |
| --- | --- | --- | --- |
| `CCMO` | `Constraint Handling/CCMO` | — | IN |
| `CMOCSO` | `Constraint Handling/CMOCSO` | — | IN |
| `AR_MOEA` | `Decomposition/AR-MOEA` | stats | IN |
| `MOEA_D` | `Decomposition/MOEA-D` | stats | IN |
| `MOEA_D_DE` | `Decomposition/MOEA-D-DE` | stats | IN |
| `RVEA` | `Decomposition/RVEA` | stats | IN |
| `SMS_EMOA` | `Metric Selection/SMS-EMOA` | — | IN |
| `LMOCSO` | `Non-dominated Sort/LMOCSO` | stats | IN |
| `MO_CMA_ES` | `Non-dominated Sort/MO-CMA-ES` | stats | IN |
| `MSEA` | `Non-dominated Sort/MSEA` | stats | IN |
| `NSGA_II` | `Non-dominated Sort/NSGA-II` | — | IN |
| `NSGA_II_DE` | `Non-dominated Sort/NSGA-II` | — | IN |
| `NSGA_III` | `Non-dominated Sort/NSGA-III` | stats | IN |
| `SPEA2` | `Non-dominated Sort/SPEA2` | — | IN |
| `SPEA2_DE` | `Non-dominated Sort/SPEA2` | — | IN |

## Multi-objective Multi-task (MTMO) — 22 classes (20 in, 0 pending, 2 out)

| Class | Folder | Deps | Status |
| --- | --- | --- | --- |
| `RVC_MTEA` | `Competitive Multi-task/RVC-MTEA` | stats | IN |
| `MO_EMaTO_MKT` | `Many-task/MO-EMaTO-MKT` | kmeans, stats | IN |
| `MO_MaTDE` | `Many-task/MO-MaTDE` | — | IN |
| `MO_SBO` | `Many-task/MO-SBO` | — | IN |
| `EMT_GS` | `Multi-factorial/EMT-GS` | DL Toolbox, stats | OUT |
| `EMT_PD` | `Multi-factorial/EMT-PD` | — | IN |
| `MO_MFEA` | `Multi-factorial/MO-MFEA` | — | IN |
| `MO_MFEA_II` | `Multi-factorial/MO-MFEA-II` | stats | IN |
| `AMT_NSGA_II` | `Multi-population/AMT-NSGA-II` | stats | IN |
| `EMT_ET` | `Multi-population/EMT-ET` | — | IN |
| `EMT_MSKT` | `Multi-population/EMT-MSKT` | stats | IN |
| `MM_DE` | `Multi-population/MM-DE` | stats | IN |
| `MMTO_ETA` | `Multi-population/MMTO-ETA` | stats | IN |
| `MMTO_TGT` | `Multi-population/MMTO-TGT` | SOM Toolbox, kmeans, stats | OUT |
| `MO_EMEA` | `Multi-population/MO-EMEA` | — | IN |
| `MO_MTEA_PAE` | `Multi-population/MO-MTEA-PAE` | lhsdesign shim (pinned profile) | IN |
| `MO_MTEA_SaO` | `Multi-population/MO-MTEA-SaO` | — | IN |
| `MOMFEA_SADE` | `Multi-population/MOMFEA-SADE` | — | IN |
| `MTDE_MKTA` | `Multi-population/MTDE-MKTA` | stats | IN |
| `MTEA_D_DN` | `Multi-population/MTEA-D-DN` | stats | IN |
| `MTEA_D_TSD` | `Multi-population/MTEA-D-TSD` | stats | IN |
| `MTEA_DCK` | `Multi-population/MTEA-DCK` | stats | IN |

## Stream-task (asynchronous) — 9 classes (9 in, 0 pending, 0 out)

| Class | Folder | Deps | Status |
| --- | --- | --- | --- |
| `AAEMTO` | `AAEMTO` | — | IN |
| `ABoKTDE` | `ABoKTDE` | — | IN |
| `AEMEA` | `AEMEA` | — | IN |
| `AMFEA` | `AMFEA` | — | IN |
| `AMTEA_AD` | `AMTEA-AD` | stats | IN |
| `AMTEA_SaO` | `AMTEA-SaO` | — | IN |
| `AMaTDE` | `AMaTDE` | — | IN |
| `ATNG_SNES` | `ATNG-SNES` | — | IN |
| `KR_AMTEA` | `KR-AMTEA` | stats | IN |

## Excluded — reasons

- **ABOM** (`Single-task/Genetic Algorithm/ABOM`) — Python (PyTorch, via MATLAB pyenv)
- **EMT_GS** (`Multi-objective Multi-task/Multi-factorial/EMT-GS`) — Deep Learning Toolbox (dlarray/dlgradient/dlfeval/adamupdate/batchnorm)
- **KLDE** (`Single-task/Differential Evolution/KLDE`) — Deep Learning Toolbox, legacy API (newff/minmax/train/sim/traingdx)
- **KLPSO** (`Single-task/Swarm Intelligence/KLPSO`) — Deep Learning Toolbox, legacy API (newff/minmax/train/sim/traingdx)
- **LES** (`Single-task/Evolution Strategy/LES`) — Python (evosax + JAX, via MATLAB pyenv)
- **MFEA_VC** (`Multi-task/Multi-factorial/MFEA-VC`) — Deep Learning Toolbox (dlnetwork/dlarray + nnet.layer.Layer subclasses)
- **MMTO_TGT** (`Multi-objective Multi-task/Multi-population/MMTO-TGT`) — SOM Toolbox (vendored 128-file third-party library)

## Runtime validation notes

The former `mapminmax` and `lhsdesign` shim dependencies are now covered locally. The two
PAE algorithms complete smoke runs with the pinned Octave LHS profile; exact MATLAB internal
LHS draw-count parity is unverified. `SSLT_DE`, `SSLT_GA`, and `CEDE_DRL` have completed
low-budget runs, but their long model-training branches are not yet smoke-run.

The maintained `tests/octave_algorithm_smoke.m` runner exercises all **133 IN classes** at
least once with representative low-budget fixtures. This is runtime smoke coverage, not
exhaustive parameter/branch or result-parity coverage. Constructors for all 140 catalog
classes were also checked; the seven OUT classes remain excluded from runtime support
regardless of constructor success.
