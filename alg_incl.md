# Algorithms — in-scope worklist

The algorithms to make run under Octave, and to port to Rust. **133 of 140** algorithm classes.

Companion: `alg.md` has the full inventory, including the 7 excluded classes and why they are excluded.

Paths are relative to `MTO/Algorithms/` unless stated otherwise.

> Every class here also depends on the shared Octave compatibility fixes in `AGENTS.md`.
> Apply and validate those framework-wide fixes once; do not duplicate them per algorithm.

| Tier | Count | Action |
| --- | --- | --- |
| Ready | 133 | Nothing beyond shared framework fixes and the local `mapminmax` / `lhsdesign` shims. |
| Needs a shim | 0 | No missing helper remains; full runtime inventory is still unverified. |

`stats` / `kmeans` columns mean the algorithm calls Statistics Toolbox functions; Octave Forge `statistics` supplies them (verified — see `AGENTS.md`). They are not exclusions. The `Needs` column flags only what Octave genuinely lacks. Both local shims exist; `mapminmax` training branches remain unverified, and the `lhsdesign` draw-profile divergence is recorded in `parity.md`.

## Single-task — 38 classes (38 ready, 0 need a shim)

| Class | Folder | Uses | Fix needed |
| --- | --- | --- | --- |
| `C2oDE` | `Constraint Handling/C2oDE` | — | — |
| `CAL_SHADE` | `Constraint Handling/CAL-SHADE` | stats | — |
| `CCEF_ECHT` | `Constraint Handling/CCEF-ECHT` | — | — |
| `CEDE_DRL` | `Constraint Handling/CEDE-DRL` | `mapminmax` (local shim) | — (runtime smoke pending) |
| `CORCO` | `Constraint Handling/CORCO` | — | — |
| `DeCODE` | `Constraint Handling/DeCODE` | — | — |
| `ECHT` | `Constraint Handling/ECHT` | — | — |
| `FROFI` | `Constraint Handling/FROFI` | — | — |
| `MTV_DE` | `Constraint Handling/MTV-DE` | — | — |
| `VMCH` | `Constraint Handling/VMCH` | stats | — |
| `DE` | `Differential Evolution/DE` | — | — |
| `JADE` | `Differential Evolution/JADE` | stats | — |
| `L_SHADE` | `Differential Evolution/L-SHADE` | stats | — |
| `LSHADE44` | `Differential Evolution/LSHADE44` | stats | — |
| `NL_SHADE_RSP` | `Differential Evolution/NL-SHADE-RSP` | stats | — |
| `SHADE` | `Differential Evolution/SHADE` | stats | — |
| `SaDE` | `Differential Evolution/SaDE` | — | — |
| `jDE` | `Differential Evolution/jDE` | — | — |
| `jSO` | `Differential Evolution/jSO` | stats | — |
| `rank_DE` | `Differential Evolution/rank-DE` | — | — |
| `rank_jDE` | `Differential Evolution/rank-DE` | — | — |
| `EDAver` | `Estimation of Distribution/EDAver` | stats | — |
| `CMA_ES` | `Evolution Strategy/CMA-ES` | — | — |
| `DES` | `Evolution Strategy/DES` | — | — |
| `IPOP_CMA_ES` | `Evolution Strategy/IPOP-CMA-ES` | — | — |
| `OpenAI_ES` | `Evolution Strategy/OpenAI-ES` | — | — |
| `R1_NES` | `Evolution Strategy/R1-NES` | — | — |
| `SNES` | `Evolution Strategy/SNES` | — | — |
| `sep_CMA_ES` | `Evolution Strategy/sep-CMA-ES` | — | — |
| `xNES` | `Evolution Strategy/xNES` | — | — |
| `xNES_as` | `Evolution Strategy/xNES-as` | stats | — |
| `GA` | `Genetic Algorithm/GA` | — | — |
| `Global_GA` | `Genetic Algorithm/Global-GA` | — | — |
| `AO` | `Swarm Intelligence/AO` | — | — |
| `CSO` | `Swarm Intelligence/CSO` | — | — |
| `EO` | `Swarm Intelligence/EO` | — | — |
| `MPA` | `Swarm Intelligence/MPA` | — | — |
| `PSO` | `Swarm Intelligence/PSO` | — | — |

## Multi-task — 51 classes (51 ready, 0 need a shim)

| Class | Folder | Uses | Fix needed |
| --- | --- | --- | --- |
| `DEORA` | `Competitive Multi-task/DEORA` | — | — |
| `DEORA_MTDE` | `Competitive Multi-task/DEORA` | — | — |
| `MTSRA` | `Competitive Multi-task/MTSRA` | stats | — |
| `CEDA_MF` | `Constrained Multi-task/CEDA` | — | — |
| `CEDA_MP` | `Constrained Multi-task/CEDA` | — | — |
| `CMO_LKT` | `Constrained Multi-task/CMO-LKT` | stats | — |
| `BoKTDE` | `Many-task/BoKT` | stats | — |
| `BoKTGA` | `Many-task/BoKT` | stats | — |
| `DTSKT` | `Many-task/DTSKT` | stats | — |
| `EMaTO_MKT` | `Many-task/EMaTO-MKT` | stats, kmeans | — |
| `KR_MTEA` | `Many-task/KR-MTEA` | — | — |
| `MES_RET` | `Many-task/MES-RET` | — | — |
| `sep_MES_RET` | `Many-task/MES-RET` | — | — |
| `MaTDE` | `Many-task/MaTDE` | — | — |
| `SBCMAES` | `Many-task/SBO` | — | — |
| `SBGA` | `Many-task/SBO` | — | — |
| `sep_SBCMAES` | `Many-task/SBO` | — | — |
| `TNG_SNES` | `Many-task/TNG-NES` | — | — |
| `TNG_SNES_EP` | `Many-task/TNG-NES` | — | — |
| `TNG_xNES` | `Many-task/TNG-NES` | — | — |
| `TRADE` | `Many-task/TRADE` | kmeans | — |
| `ASCMFDE` | `Multi-factorial/ASCMFDE` | — | — |
| `AT_MFEA` | `Multi-factorial/AT-MFEA` | — | — |
| `EMTO_AI` | `Multi-factorial/EMTO-AI` | — | — |
| `G_MFEA` | `Multi-factorial/G-MFEA` | — | — |
| `LDA_MFEA` | `Multi-factorial/LDA-MFEA` | kmeans | — |
| `MFDE` | `Multi-factorial/MFDE` | — | — |
| `MFEA` | `Multi-factorial/MFEA` | — | — |
| `MFEA_AKT` | `Multi-factorial/MFEA-AKT` | — | — |
| `MFEA_DGD` | `Multi-factorial/MFEA-DGD` | — | — |
| `MFEA_DV` | `Multi-factorial/MFEA-DV` | — | — |
| `MFEA_GHS` | `Multi-factorial/MFEA-GHS` | — | — |
| `MFEA_II` | `Multi-factorial/MFEA-II` | stats | — |
| `MFPSO` | `Multi-factorial/MFPSO` | — | — |
| `SREMTO` | `Multi-factorial/SREMTO` | — | — |
| `TLTLA` | `Multi-factorial/TLTLA` | — | — |
| `BLKT_DE` | `Multi-population/BLKT-DE` | kmeans | — |
| `EMEA` | `Multi-population/EMEA` | — | — |
| `IMEA` | `Multi-population/IMEA` | — | — |
| `MFMP` | `Multi-population/MFMP` | stats | — |
| `MKTDE` | `Multi-population/MKTDE` | — | — |
| `MTDE_ADKT` | `Multi-population/MTDE-ADKT` | stats | — |
| `MTEA_AD` | `Multi-population/MTEA-AD` | stats | — |
| `MTEA_HKTS` | `Multi-population/MTEA-HKTS` | — | — |
| `MTEA_PAE` | `Multi-population/MTEA-PAE` | `lhsdesign` (local pinned profile) | — |
| `MTEA_SaO` | `Multi-population/MTEA-SaO` | — | — |
| `MTES` | `Multi-population/MTES` | — | — |
| `MTES_KG` | `Multi-population/MTES-KG` | — | — |
| `sep_MTES_KG` | `Multi-population/MTES-KG` | — | — |
| `SSLT_DE` | `Multi-population/SSLT` | `mapminmax` (local shim) | — (runtime smoke pending) |
| `SSLT_GA` | `Multi-population/SSLT` | `mapminmax` (local shim) | — (runtime smoke pending) |

## Multi-objective Single-task — 15 classes (15 ready, 0 need a shim)

| Class | Folder | Uses | Fix needed |
| --- | --- | --- | --- |
| `CCMO` | `Constraint Handling/CCMO` | — | — |
| `CMOCSO` | `Constraint Handling/CMOCSO` | — | — |
| `AR_MOEA` | `Decomposition/AR-MOEA` | stats | — |
| `MOEA_D` | `Decomposition/MOEA-D` | stats | — |
| `MOEA_D_DE` | `Decomposition/MOEA-D-DE` | stats | — |
| `RVEA` | `Decomposition/RVEA` | stats | — |
| `SMS_EMOA` | `Metric Selection/SMS-EMOA` | — | — |
| `LMOCSO` | `Non-dominated Sort/LMOCSO` | stats | — |
| `MO_CMA_ES` | `Non-dominated Sort/MO-CMA-ES` | stats | — |
| `MSEA` | `Non-dominated Sort/MSEA` | stats | — |
| `NSGA_II` | `Non-dominated Sort/NSGA-II` | — | — |
| `NSGA_II_DE` | `Non-dominated Sort/NSGA-II` | — | — |
| `NSGA_III` | `Non-dominated Sort/NSGA-III` | stats | — |
| `SPEA2` | `Non-dominated Sort/SPEA2` | — | — |
| `SPEA2_DE` | `Non-dominated Sort/SPEA2` | — | — |

## Multi-objective Multi-task — 20 classes (20 ready, 0 need a shim)

| Class | Folder | Uses | Fix needed |
| --- | --- | --- | --- |
| `RVC_MTEA` | `Competitive Multi-task/RVC-MTEA` | stats | — |
| `MO_EMaTO_MKT` | `Many-task/MO-EMaTO-MKT` | stats, kmeans | — |
| `MO_MaTDE` | `Many-task/MO-MaTDE` | — | — |
| `MO_SBO` | `Many-task/MO-SBO` | — | — |
| `EMT_PD` | `Multi-factorial/EMT-PD` | — | — |
| `MO_MFEA` | `Multi-factorial/MO-MFEA` | — | — |
| `MO_MFEA_II` | `Multi-factorial/MO-MFEA-II` | stats | — |
| `AMT_NSGA_II` | `Multi-population/AMT-NSGA-II` | stats | — |
| `EMT_ET` | `Multi-population/EMT-ET` | — | — |
| `EMT_MSKT` | `Multi-population/EMT-MSKT` | stats | — |
| `MM_DE` | `Multi-population/MM-DE` | stats | — |
| `MMTO_ETA` | `Multi-population/MMTO-ETA` | stats | — |
| `MO_EMEA` | `Multi-population/MO-EMEA` | — | — |
| `MO_MTEA_PAE` | `Multi-population/MO-MTEA-PAE` | `lhsdesign` (local pinned profile) | — |
| `MO_MTEA_SaO` | `Multi-population/MO-MTEA-SaO` | — | — |
| `MOMFEA_SADE` | `Multi-population/MOMFEA-SADE` | — | — |
| `MTDE_MKTA` | `Multi-population/MTDE-MKTA` | stats | — |
| `MTEA_D_DN` | `Multi-population/MTEA-D-DN` | stats | — |
| `MTEA_D_TSD` | `Multi-population/MTEA-D-TSD` | stats | — |
| `MTEA_DCK` | `Multi-population/MTEA-DCK` | stats | — |

## Stream-task — 9 classes (9 ready, 0 need a shim)

| Class | Folder | Uses | Fix needed |
| --- | --- | --- | --- |
| `AAEMTO` | `AAEMTO` | — | — |
| `ABoKTDE` | `ABoKTDE` | — | — |
| `AEMEA` | `AEMEA` | — | — |
| `AMFEA` | `AMFEA` | — | — |
| `AMTEA_AD` | `AMTEA-AD` | stats | — |
| `AMTEA_SaO` | `AMTEA-SaO` | — | — |
| `AMaTDE` | `AMaTDE` | — | — |
| `ATNG_SNES` | `ATNG-SNES` | — | — |
| `KR_AMTEA` | `KR-AMTEA` | stats | — |

## Local shims and runtime gaps

The two formerly missing helpers now exist locally. `lhsdesign` is a documented smooth/maximin
profile for the call shape used here; its primitive draw order is pinned for Rust but not
verified against MATLAB internals. `mapminmax` implements the used forms, while its training
branches remain unverified.

| Function | Used by | What it must do |
| --- | --- | --- |
| `lhsdesign(n, p)` | `MTEA_PAE`, `MO_MTEA_PAE` | Implemented as smooth maximin LHS; the explicit Octave/Rust RNG profile and MATLAB-parity caveat are in `parity.md`. |
| `mapminmax` | `SSLT_DE`, `SSLT_GA`, `CEDE_DRL`, and their `Dropout/Estimate.m` | Implemented in `MTO/Algorithms/Utils/Normalization/mapminmax.m` for row-wise `[-1,1]` scaling and stateful `'apply'` / `'reverse'`; runtime training branches remain pending. |

`tiledlayout` / `nexttile` are also missing, but are reached only from `DrawPopDec` / `DrawPopObj` when `Draw_Dec` / `Draw_Obj` are enabled. The GUI and plotting path is out of scope — for headless runs nothing needs to be written.

## Statistics functions relied on

Provided by Octave Forge `statistics` (tested at 2.0.0). Verified compatible with the call shapes used here, including `kmeans(X,K,'Distance','cityblock','MaxIter',30)` and all 41 `normrnd` call sites:

`pdist2`, `pdist`, `kmeans`, `mvnpdf`, `mvnrnd`, `normrnd`, `ranksum`, `tiedrank`, `datasample`, `randsample`, `mahal`, `friedman`, `histcounts`.

Two known divergences, neither currently hit: Forge `kmeans` rejects `K` larger than the observation count, and `normrnd(vec, vec, m, n)` (vector parameters with explicit dimensions) is rejected. Re-grep for both after any upstream sync.
