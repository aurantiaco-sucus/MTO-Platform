# AGENTS.md

Guidance for anyone — human or agent — working on this fork.

## What this fork is for

This is a fork of **MToP** (Multitask Optimization Platform), a MATLAB benchmarking
platform for evolutionary multitasking. The purpose of the fork is narrow:

> **Adapt the Problems and Algorithms so they execute under GNU Octave, as a
> stepping stone to a port to Rust.**

The Octave stage is not the end goal. It is how we pin down behaviour, run the
existing baselines, and generate reference values the Rust implementation can be
tested against. Two consequences follow:

- **Reproducible numbers matter more than platform parity.** If Octave and MATLAB
  disagree, that is a finding to record, not something to paper over.
- **Keep numerical behaviour identical to MATLAB.** Where a fix would change
  results, stop and document it rather than making the code "nicer".

## Scope

**In scope**

- `MTO/Problems/**` — problem definitions and benchmark generators
- `MTO/Algorithms/**` — algorithms, individual classes, operators, initialization, shared utilities
- The minimum framework changes needed for the two above to load and run

**Out of scope** unless it directly unblocks the above

- `MTO/GUI/**`, and any plotting or visualisation path
- `MTO/Metrics/**` and result-export tooling
- Anything requiring a MathWorks toolbox with no Octave equivalent
- Anything requiring Python

### Exclusion rules

A problem or algorithm is **excluded** when it needs any of the following.

| # | Rule | Example |
| --- | --- | --- |
| 1 | **Deep Learning Toolbox** — real autodiff or an NN trainer | `EMT_GS`, `MFEA_VC` (`dlarray`, `dlgradient`, `dlnetwork`); `KLDE`, `KLPSO` (`newff`/`train`/`sim`) |
| 2 | **An external MATLAB-based library that must be installed** | MATPOWER, used by all three OPF suites |
| 3 | **A foreign toolbox vendored as a blob** — code dropped into a subdirectory untouched, keeping its own conventions and licence | SOM Toolbox (128 files); ESA ACT Space Mechanics Toolbox |
| 4 | **Python** — `py.*` / `pyenv` bridges with no Octave equivalent | `LES`, `ABOM`, `MaT-Gym` |
| 5 | **Incompleteness** — calls a source file that is not present | `MGA_DSM_GTOP` |

Two clarifications that matter in practice:

- **`mapminmax` is a shim, not an exclusion.** It is Deep Learning Toolbox, but it is
  only min-max scaling to `[-1,1]`, so the three affected algorithms are marked
  *pending* rather than excluded. Same for `lhsdesign` (Statistics Toolbox).
- **Compiled MEX is in scope.** The CEC `.cpp` sources are self-contained, Octave ships
  the MEX API, and all three were verified to build and run — see "MEX build" below.

Rule 3 draws a line that is worth stating explicitly, because the same word "vendored"
covers two different things. **PlatEMO-derived code is in scope**: it was rewritten onto
MToP's own `Algorithm`/`Individual` classes with array-in/array-out kernels, so it is now
MToP source. **The SOM Toolbox is out of scope**: it is a foreign 128-file codebase with
its own struct conventions, its own MATLAB GUIs, and calls out to the SOM_PAK binary.

### Why the GUI is out of scope

`MTO/GUI/MTO_GUI.m` is 3408 lines of MATLAB **App Designer** output:
`classdef MTO_GUI < matlab.apps.AppBase`, with properties typed as
`matlab.ui.container.GridLayout`, `matlab.ui.control.Button`, `.DropDown`, `.UIAxes`,
`.Tree` and so on, plus 35 `uibutton` and 32 `uigridlayout` calls. Octave 11.3 provides
only `uifigure`, `uitable`, `uipanel`, `uimenu`, `uicontrol` and the classic dialog
functions. There is no `matlab.apps.AppBase`, no `uibutton`, `uigridlayout`,
`uidropdown`, `uieditfield`, `uilabel`, `uilistbox`, `uitab`, `uitabgroup`, `uiaxes`,
`uiconfirm`, `uialert` or `uiprogressdlg`. The GUI is a rewrite, not a port, and it
teaches the Rust port nothing. Drive experiments through `MTO_CMD` / `mto()` instead.

**Two caveats, because the directory layout will mislead you.** `MTO/GUI/` contains exactly
two files, and only one of them is out of scope:

| File | Status |
| --- | --- |
| `MTO/GUI/MTO_GUI.m` | Out of scope — the 3408-line App Designer GUI |
| `MTO/GUI/MTO_CMD.m` | **In scope** — the headless command-line runner, and the only way to drive a run without the GUI |

So "the GUI is out of scope" must not be read as "ignore `MTO/GUI/`". The plotting and
parameter-editing utilities under `MTO/GUI/Utils/` and `MTO/GUI/PlotFunctions/` *are* out of
scope, with one exception: `Utils/Par.m`, which `MTO_CMD` reaches only when `Par_Flag` is
true. `Par` uses `spmd` and `getCurrentTask`, so the parallel path cannot work under Octave —
but leaving `Par_Flag` false avoids it entirely, and `Par.m` is MathWorks-derived code (see
the licensing note) that is not worth porting.

## Environment

- **GNU Octave 11.3.0** (x86_64-pc-linux-gnu)
- **Forge `statistics` 2.0.0** — `pkg load statistics` is required, not optional

There is no local MATLAB, so MATLAB parity cannot be checked directly here. Treat
MATLAB behaviour as the specification and flag anything you cannot confirm.

## Current state

**No complete Octave run has been achieved yet.** As of the last session the repository does
not load at all, and the furthest reached was instantiating algorithm objects after patching
three files by hand in a scratch copy.

One command tells you where things stand. **Run it from the repository root** — the `MTO`
path is relative:

```bash
octave --norc -q --eval "addpath(genpath('MTO')); pkg load statistics; \
  try, o = Algorithm(); printf('LOADS OK\n'); catch e, printf('FAILS: %s\n', e.message); end"
```

Expected output today: `FAILS: syntax error near line 14, column 13 in file …/Algorithm.m`.

Useful checkpoints, in the order they were observed to break:

| Checkpoint | How to test | Last observed result |
| --- | --- | --- |
| Tree loads | the command above | **fails** — `syntax error near line 14, column 13 in Algorithm.m` |
| After fixing blockers 1–2 | `GA()`, `NSGA_II()`, `MFEA()`, `DE()`, `MTEA_AD()` | constructed successfully in a patched scratch copy |
| A problem constructs | `CEC17_MTSO1_CI_HS()` | constructed successfully |
| A run completes | `p = CEC17_MTSO1_CI_HS(); p.maxFE = 2000; a = GA(); a.reset(); p.setTasks(); a.run(p);` | **fails** at `Initialization.m:26` (blocker 3) |
| …and after fixing blocker 3 | same | **fails** inside `Evaluation` with `Objs(100,_): out of bound 1` — the symptom of blocker 4 |

That last row is the important one: blocker 4 does not announce itself. It surfaces as a
dimension mismatch somewhere downstream of `Pop.Decs`, because the method is applied to the
first element only. Expect to lose time to this unless you settle blocker 4 first.

**Work in a scratch copy outside the repository** (`cp -r MTO /tmp/scratch`) while
experimenting with the parse-level fixes, so the upstream tree stays diffable. That is how
the checkpoints above were established.

### A tooling gotcha

Four `.m` files are **not UTF-8** (they carry Chinese comments in a legacy encoding):
`Algorithms/Multi-task/Constrained Multi-task/CMO-LKT/Generation{1,2}_tasks_all_best.m`,
`Problems/Multi-objective Multi-task/CEC19-MTMO-CPLX/Base/LZ09.m`, and
`Problems/Real-world Applications/Global Trajectory Optimization/utils/tandem.m`. Any script
that reads the tree as UTF-8 will crash on them; read with a permissive encoding
(`latin-1`) or handle the decode error explicitly.

## Known blockers — the critical path

Nothing in the repository loads in Octave today. The reason is narrower than it looks:
**only three files fail to parse, but they are the base classes of 599 of the 622
`classdef` files** — all 435 problem classes, 131 algorithm classes, 9 stream-algorithm
classes and 24 individual classes — so the failure is total.

| # | Blocking issue | Where | Scope |
| --- | --- | --- | --- |
| 1 | Property **type declarations** are a syntax error in Octave (`Name char`, `FE double = 0`, `Result struct % …`) | `Algorithms/Algorithm.m` lines 13–27; `Problems/Problem.m` lines 19–34; `Algorithms/Utils/Individual/Individual.m` lines 13–18 | 3 files, 20 declarations |
| 2 | `methods (Abstract)` in **stub form** (`run(Algo, Prob)` with no `function` keyword) is rejected: *"external methods are only allowed in @-folders"* | `Algorithms/Algorithm.m:189`, `Problems/Problem.m:36` | 2 sites |
| 3 | Comma-list assignment to object properties — `[CurrentPop.Dec] = deal(DecCell{:})` — fails with *"can't perform indexing operation on array of … objects"*. Reading `[p.Dec]` works; only the **assignment** form fails. | `Algorithms/Utils/Initialization/` — `Initialization.m:26`, `Initialization_One.m:23`, `Initialization_MF.m:21,25,26,62,80`, `Initialization_MF_One.m:23,24,34,40`, `Initialization_MF_MO.m:29,35` | 13 sites, 5 files |
| 4 | **Dot-notation method calls on object arrays silently return the wrong thing.** `Individual` defines `Decs`, `Objs`, `Cons`, `CVs` as methods; Octave evaluates `Pop.Decs` as "call it on the **first element only**" and returns that. Measured: `p.Decs` → `1×3` where `Decs(p)` → `5×3`. No error is raised. | `.Objs` (272 sites), `.Decs` (186), `.CVs` (147), `.Cons` (4) | ~605 sites |

**Issue 4 is the one to plan around.** Issues 1–3 are mechanical and bounded to 3 + 2 + 13
locations. Issue 4 is a semantics decision that touches roughly 605 call sites and fails
*silently* — it returns plausible-looking numbers of the wrong size, so a naive fix will
appear to work. Decide the approach before starting: either give `Individual` real
properties that are kept in sync, or convert every call site to function form
(`Decs(pop)`, `Objs(pop)`). The second is closer to what a Rust port wants anyway, since
Rust has no implicit method-on-array dispatch to reproduce.

Confirmed **working** in Octave 11.3 (no action needed): `classdef (Abstract)`,
superclass constructor calls (`o@Super(args)`), `properties (Constant)`,
`(SetAccess = private)`, `(Access = protected)`, `(Hidden)`, `methods (Static)`, and
inheriting from `handle`.

Also note `Individual` is a **value class** (`classdef Individual`, no `< handle`) while
`Algorithm` and `Problem` are handle classes. Array growth, copy-on-write, and sharing
semantics differ accordingly — this matters for the Rust data model.

## Missing functions to write

Three functions used by in-scope code are absent from Octave core plus Forge `statistics`.
Only the first two need writing for headless work; the third belongs to the out-of-scope
plotting path.

| Function | Used by | Notes |
| --- | --- | --- |
| `lhsdesign(n, p)` | `MTEA_PAE`, `MO_MTEA_PAE` | Latin hypercube: `n` points in `[0,1]^p`, one per stratum per dimension, strata randomly permuted. |
| `mapminmax` | `SSLT_DE`, `SSLT_GA`, `CEDE_DRL`, and their `Dropout/Estimate.m` | Min-max scaling to `[-1,1]`. Must support the stateful `'apply'` / `'reverse'` forms and carry the `ps` / `qs` settings struct. |
| `tiledlayout` / `nexttile` | `DrawPopDec`, `DrawPopObj` | Only reached when `Draw_Dec` / `Draw_Obj` are on. Out of scope — leave unimplemented for headless runs. |

Statistics Toolbox functions are **not** a problem: Forge `statistics` supplies `pdist2`,
`pdist`, `kmeans`, `mvnpdf`, `mvnrnd`, `normrnd`, `ranksum`, `tiedrank`, `datasample`,
`randsample`, `mahal`, `friedman` and `histcounts`, and they were verified against the call
shapes actually used here — including `kmeans(X,K,'Distance','cityblock','MaxIter',30)` and
all 41 `normrnd` call sites. Two divergences exist but are not currently hit: Forge `kmeans`
rejects `K` greater than the observation count, and `normrnd(vec, vec, m, n)` is rejected.
Re-grep for both after any upstream sync.

## MEX build

Verified on this machine: all three CEC sources compile with Octave's MEX API, and the
resulting binaries load and compute correct values.

```bash
mkoctfile --mex cec17_func.cpp          # -> cec17_func.mex
mkoctfile --mex cec22_test_func.cpp
mkoctfile --mex cec14_func.cpp
```

Compilation succeeds with warnings only (unchecked `fscanf` return values). Confirmation
that the result is correct and not merely plausible: `cec17_func` returns exactly `100`
for F1 evaluated at the shift vector, which is the CEC 2017 optimum convention — the
repo's `- g` normalisation then puts the optimum at 0.

Two traps, both confirmed by testing:

1. **The `.cpp` files open their data through a path relative to the repo root**
   (`./Problems/Single-task/CEC17-SO/input_data/M_%d_D%d.txt`). Octave must be launched
   from the directory containing `Problems/`, not from the suite folder.
2. **Missing data does not raise a MATLAB error — it segfaults.** The code prints an error
   after `fopen` returns `NULL`, then calls `fscanf` on the null handle anyway.

The repo ships `.mexw64` / `.mexmac*` binaries only; there is no Linux build. For Octave
you need the `.mex` produced above, so add a build step rather than committing binaries.

## Conventions when editing

- **Preserve random-number consumption order, not random values.** The platform relies on
  fixed seeds for reproducibility, and several utilities were written specifically to keep the
  sequence of draws unchanged (`Algorithms/Utils/Boundary/README.md` is explicit about this).
  Do not "clean up" a random call into an equivalent-looking one. Note that the draws
  themselves are *not* required to match Octave or MATLAB — see `parity.md`, which settles
  this. Read it before changing anything stochastic; in particular, do not start porting
  Octave's generators.
- **Preserve function-evaluation accounting.** `Algo.FE` and the stream-task per-task
  budgets are load-bearing for both termination and metrics; a fix that changes how many
  evaluations a generation costs will change results.
- **Fix syntax without touching numerics.** The parse-level repairs (issues 1–3 above) are
  pure transcription. Keep them separate from any behavioural change so they stay auditable.
- **Record divergences rather than absorbing them.** If Octave and MATLAB disagree, note it
  in the file or in the relevant inventory instead of writing code that hides it.

## Inventories

| File | Contents |
| --- | --- |
| `alg.md` | Full catalogue of all 140 algorithm classes — dependencies, status, exclusion reasons |
| `alg_incl.md` | The 133 in-scope algorithms, grouped, with the fix needed per class |
| `prob.md` | Full catalogue of all 435 problem classes, by suite, with data footprints |
| `prob_incl.md` | The 419 in-scope problem classes, and the data to carry into the Rust port |
| `alg_pilot.md` | 10 algorithms that between them exercise every interface surface — the porting order |
| `prob_pilot.md` | 11 problem classes, one per definition shape — the porting order |
| `interface.md` | The plugin contract: what Problems and Algorithms must expose, what core owes them, and where the current code leaks the separation |
| `parity.md` | **RNG policy — read before touching anything stochastic.** Why bit-exact parity is not a goal, and the four invariants that replace it |

**If you are here to start work, read `alg_pilot.md` and `prob_pilot.md` first, then
`interface.md`, then the inventories.** The pilot files are ordered by increasing
dependency, so the first few items need nothing but Octave.

Summary of the classification:

| | Total | In scope | Pending / build | Excluded |
| --- | --- | --- | --- | --- |
| Algorithms | 140 | 128 | 5 | 7 |
| Problems | 435 | 337 | 82 (MEX) | 16 |

Excluded algorithms: `EMT_GS`, `MFEA_VC` (Deep Learning), `KLDE`, `KLPSO` (legacy NN API),
`LES`, `ABOM` (Python), `MMTO_TGT` (SOM Toolbox).

Excluded problem suites: `Optimal Power Flow` (5), `Multiobjective Optimal Power Flow` (4),
`Competitive Multiobjective Optimal Power Flow` (4) — all MATPOWER; `Policy Search/MaT-Gym` (1)
— Python; `Global Trajectory Optimization` (2) — ESA toolbox, and the MGA-DSM variant is
incomplete. Note that MATPOWER is called from inside the objective function
(`runpf` once per candidate per generation), so it is on the evaluation hot path, not a
setup step — worth remembering if these are ever revisited.

## Regenerating the inventories

The four inventory files were produced by, and can be reproduced with, a static audit
rather than by hand:

1. Enumerate `classdef … < Algorithm` / `< StreamAlgorithm` / `< Problem`.
2. For each, resolve dependencies **transitively** over repo-local function calls, plus the
   files in its own directory. Transitive resolution is necessary: the OPF classes reach
   MATPOWER through `Prob.Fnc{i} = @(x)IEEE_30_SO(x, 1)`, and the Competitive-CPLX classes
   reach the CEC MEX through a `benchmark_*` file one directory up.
3. Flag on symbol names, not on comments — MATPOWER and the MEX functions are called as bare
   identifiers with no attribution header anywhere in the calling files.
4. Confirm availability claims against Octave itself (`exist(name)`) rather than against a
   written-down list of toolbox functions.

That last point is the one that matters: grepping for a hand-written list of toolbox function
names, and grepping for attribution headers, both miss external dependencies that are called
by bare name. If in doubt, invert the search — collect every identifier used in call
position, subtract what the repo defines, then subtract what Octave knows, and triage the
residue.

## Inaccuracies in the existing docs

`Doc/User-Guide.md` (and its `-CN` translation) is the upstream contributor guide, and its
"Add Your …" sections do not match the code. Do not follow them literally, and do not treat
them as a description of the current contract — `interface.md` is the accurate description of
what plugins must expose.

Three errors, all verified against the tree:

| Guide says | Reality |
| --- | --- |
| `function Tasks = setTasks()` | `function setTasks(Prob)` — no output argument; it mutates the object. All 435 problem classes agree |
| "Inherit the `Metric.m` class in the `Metric` folder" | No `Metric.m` base class exists. Metrics are plain functions of the form `result = MetricName(MTOData, varargin)` with a catalog label on line 2 |
| Labels are `<task> <objectives> <constraints>` | Incomplete. The vocabulary actually in use is `Single-task`/`Multi-task`/`Many-task`, `Single-objective`/`Multi-objective`/`Many-objective`, `None`/`Constrained`/`Competitive`, plus `Stream` and `Year: <yyyy>` |

The guide's "Run MTO Platform" section is accurate: the entry point is `mto` (GUI) or
`MTO_CMD` / `mto({Algo}, {Prob}, …)` for the command line.

Worth checking `tables.pdf` in the same folder against the inventories before relying on it;
it was not examined in the last session.

## Licensing note

The repository has no top-level `LICENSE` file, and two vendored components reference licence
terms that are not present:

- The SOM Toolbox says "see `License.txt` in the program package" — that file is absent.
- `Case_IEEE_30.m` / `Case_IEEE_57.m` are verbatim MATPOWER case files (BSD-3-Clause); MATPOWER
  is not vendored otherwise.

PlatEMO-derived code carries an in-file notice: free for research purposes, with a mandatory
citation of the PlatEMO paper. PlatEMO is **not** GPL-3.0 — it is a custom research-use
licence, which is more restrictive than permissive. A Rust port is a new distribution, so
either reimplement the affected algorithms from their original papers (NSGA-II, SPEA2,
MOEA/D, RVEA and the rest are all independently published) or confirm the terms before
carrying that logic across.

## Reporting status

When summarising work on this fork, distinguish clearly between what was **verified by
running something** and what was **inferred from reading code**. Most of this document is in
the first category; where a claim could not be tested (MATLAB parity, in particular), say so.
