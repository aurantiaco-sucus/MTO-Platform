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

- **`mapminmax` and `lhsdesign` are shims, not exclusions.** The targeted local `mapminmax`
  shim covers the used default/`apply`/`reverse` forms; its affected training branches still
  need runtime validation. A local smooth/maximin `lhsdesign` shim now covers the only call
  form used by MToP; its explicit RNG profile is recorded in `parity.md` as an Octave/Rust
  reference, not claimed as MATLAB-internal parity.
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

## Current state (verified 2026-10-16)

The first Octave end-to-end smoke runs now pass. This supersedes the earlier checkpoint
history below, which described the repository before the compatibility changes were applied.

Run the maintained regression smoke suite and the full in-scope algorithm sweep from the
repository root (or by their absolute paths):

```bash
octave --norc -q tests/octave_smoke.m
octave --norc -q tests/octave_algorithm_smoke.m
octave --norc -q tests/octave_problem_smoke.m
```

Verified with GNU Octave 11.3.0 and Forge `statistics` 2.0.0:

- The base classes load; all ten algorithm pilots (`GA`, `jDE`, `CMA_ES`, `NSGA_II`, `MFEA`, `ECHT`, `MFEA_II`, `EMaTO_MKT`, `MO_MFEA`, `AEMEA`) have construction and runtime smoke coverage.
- Static Octave parsing loaded 616 of 620 unique class names. The four failures are the two out-of-scope GUI classes and two classes requiring `nnet.layer.Layer`; the three duplicated class names were each selected by directory and parsed separately. Seventeen modified top-level functions passed the parse audit; the two new numerical shims are exercised by the smoke tests.
- `GA` and `jDE` complete `Func_Sphere` runs at exactly 20 evaluations.
- `CMA_ES` completes `Func_Sphere` at exactly 20 evaluations after a value-class array preallocation fix.
- `NSGA_II` completes a `DTLZ1` run at exactly 20 evaluations.
- `MFEA` completes `CMT1` at exactly 60 evaluations, exercising the multifactorial initializer and selector.
- `MFEA_II` completes `CMT1` at exactly 60 evaluations, exercising the online RMP learner and Forge statistics calls.
- `EMaTO_MKT` completes a ten-task synthetic Sphere run at exactly 200 evaluations, exercising Forge `kmeans` and the many-task selection loop.
- `MO_MFEA` completes `CEC17_MTMO1_CI_HS` at exactly 40 evaluations, exercising joint multi-objective/multifactorial selection.
- `MO_MFEA` completes `CEC19_MaTMO1` (three tasks) and `SOPM_MTMO1` at exactly 60 evaluations each.
- `MFEA` completes `C2TOP_Case1_P1` at exactly 40 evaluations, exercising the competitive suite generator.
- `CEDA_MP` completes `CMT1` at exactly 60 evaluations and exercises the corrected `CEDA_trans` entry point.
- `ECHT` completes `CEC17_CSO1` at exactly 90 evaluations, exercising the constrained 2-D population shape.
- `GA` completes `CEC17_MTSO1_CI_HS` at exactly 2000 evaluations from the repository root.
- `AEMEA` completes the `AMTSO_Case1_P1` stream run with a transfer checkpoint at total `FE=24`, per-task `TaskFE=[12, 12]`.
- `MTO_CMD` completes and saves both single- and multi-objective headless runs; the smoke test checks the returned and saved result schema. For Octave saves, `Problems.Fnc` entries are descriptive source strings (not callable) to avoid serializing anonymous handles that capture the `Problem` object; the in-memory return retains callable handles. Reconstruct the Problem object to rerun from an Octave MAT-file.
- `CEC17_SO1` builds its Linux MEX into a temporary directory, evaluates the shifted optimum to exactly zero, and completes a GA run at exactly 8 evaluations.
- `MaT_CEC17_SO` completes a GA run over all 87 tasks at exactly 696 evaluations, covering its 10/30/50-D task groups through the same MEX.
- `lhsdesign` passes stratum and fixed-draw-profile checks; `MTEA_PAE` and `MO_MTEA_PAE` each complete 200-FE smoke runs with it.
- `mapminmax` passes row-wise scaling, stateful apply/reverse, constant-row, and round-trip checks; its neural-training callers are not yet end-to-end run.
- The CEC19-MaTMO data loader preserves shift-vector and rotation-matrix shapes with Octave ASCII loading; a three-task MO_MFEA run passes.
- The bulk `Individual` accessors return all rows when invoked in function form.
- `tests/octave_algorithm_smoke.m` executes **all 133 in-scope algorithm classes** with family-appropriate low-budget fixtures (single-task Sphere, multi-task CMT1/synthetic Sphere, multi-objective DTLZ1/CEC17 MTMO, and the AMTSO stream suite). Some algorithms require larger populations or budgets than the pilot's `N=10` fixture; the runner records those cases explicitly. On 2026-10-15 it passed 133/133. This is runtime smoke coverage, not result-parity validation or coverage of every parameter/optional branch.
- `tests/octave_problem_smoke.m` enumerates all 435 Problem classes, builds the three required Linux MEX modules in a temporary directory, evaluates one in-bounds candidate on every task of all 419 in-scope classes, and attempts constructors for the 16 excluded classes. On 2026-10-16 it passed 419/419 in-scope classes with 0 failures.
- The same pass found and repaired additional Octave issues: preallocating value-class samples before indexed writes; avoiding empty value-class archive concatenation; replacing four unsupported `split` calls with `strsplit`; representing `Individual_MFPSO` without Octave-incompatible diamond inheritance; preallocating MO-EMaTO-MKT offspring; and creating AMTEA-AD transfer candidates from the current batch's value-class representation. `CORCO` also now initializes its current-diversity state so a short run that skips the learning phase does not read an undefined value. Focused regression cases for these paths are in `tests/octave_smoke.m`.
- The full Problem sweep also repaired Octave-only catalog blockers: string-object paths in the CEC21, WCCI20-MaTSO, and WCCI20-MaTMO data loaders; four constructors that referenced an undefined `name` argument; and stream arrival generation that used the unavailable `RandStream` class. The arrival helper now saves/restores the global RNG state while generating its private sequence.

The full 435-problem catalog now has maintained runtime coverage: all 419 in-scope classes pass one candidate evaluation per task, while the 16 excluded classes are constructor-accounted. Every algorithm parameter/branch has not been exercised. `octave_smoke.m` is the focused regression suite; `octave_algorithm_smoke.m` and `octave_problem_smoke.m` are the maintained catalog sweeps.

### A tooling gotcha

Four `.m` files are **not UTF-8** (they carry Chinese comments in a legacy encoding):
`Algorithms/Multi-task/Constrained Multi-task/CMO-LKT/Generation{1,2}_tasks_all_best.m`,
`Problems/Multi-objective Multi-task/CEC19-MTMO-CPLX/Base/LZ09.m`, and
`Problems/Real-world Applications/Global Trajectory Optimization/utils/tandem.m`. Any script
that reads the tree as UTF-8 will crash on them; read with a permissive encoding
(`latin-1`) or handle the decode error explicitly.

## Octave compatibility status — critical path

The initial audit found four blockers that prevented any class from loading or any normal
population-based run from completing. Those blockers are now repaired in the working tree.
A later parse audit also surfaced abstract-stub syntax in the shared stream bases; that is fixed
too. Compatibility edits to existing algorithms preserve random-number call order and
function-evaluation accounting; no RNG algorithm or existing numerical operator was changed.
The newly added `mapminmax` shim implements the documented deterministic scaling interface.

| # | Initial blocker | Scope | Current status |
| --- | --- | --- | --- |
| 1 | MATLAB property type declarations were rejected by Octave | 3 base classes, 20 declarations | **Fixed** — removed annotations while preserving defaults and access. |
| 2 | Stub-form abstract declarations were rejected | 2 base-class methods | **Fixed** — expressed as empty `function ... end` declarations. |
| 3 | Comma-list writes such as `[population.Dec] = deal(...)` failed | 13 assignments in 5 initialization utilities | **Fixed** — replaced with element-wise assignments in the same order; no random calls added. |
| 4 | Dot-notation calls such as `population.Decs` silently dispatched only on the first object | 609 call sites (`Decs`, `Objs`, `CVs`, `Cons`) | **Fixed** — converted to standard function form (`Decs(population)`, etc.), the form most explicit for the future Rust interface. |
| 5 | Stub-form abstract signatures in shared stream classes were rejected by Octave | `StreamAlgorithm.m:160`; `Utils/Stream/AsyncCMAStream.m:164–168` | **Fixed** — expressed as empty abstract `function ... end` declarations; all changed stream class definitions now parse. |
| 6 | MATLAB's built-in `Class.empty(...)` was unavailable for value-class individuals | 54 sites across 40 algorithm files | **Fixed** — replaced with `repmat(Class(), dims)`, verified for base and derived `Individual` classes and by the stream smoke run. |

Issue 4 was selected over duplicated/synchronized properties because the accessors already
encapsulate the population aggregation and explicit calls make array dispatch unambiguous. The
conversion was tested on two-element `Individual` arrays and through single-objective,
multi-objective, and multifactorial runs. Search for function-form calls when adding new code;
do not reintroduce `population.Decs`-style syntax.

Two additional Octave compatibility findings were fixed while advancing the pilots:

- `CMA_ES`'s `sample{t}(1, lambda{t}) = Individual()` failed with `subsasgn: invalid object`
  because it grows an object array directly inside empty cell content. The same operation
  succeeds when the object array is first created in a local variable and then assigned into
  the cell. This is now done without changing the array shape or consuming randomness.
- `Algorithm.notTerminated` called `drawnow('limitrate')` unconditionally. That graphics
  refresh is skipped on Octave for headless runs; MATLAB retains the existing throttled call.
- Stream initialization and several algorithms used MATLAB's `IndividualClass.empty(...)`.
  Octave reports no such method for these value classes. Calls were replaced with `repmat`
  using the same requested empty dimensions. AEMEA's staggered-arrival and transfer-checkpoint
  smoke run now passes.
- Octave `textread` flattened the CEC19-MaTMO shift vectors and rotation matrices into columns,
  unlike the shapes assumed by the objective function. `readData_CEC19_MaTMO` now uses
  `load(..., '-ascii')`, preserving the row/matrix layout; the three-task MO_MFEA run passes.
- The same stub-form abstract syntax also occurred in `StreamAlgorithm` and
  `AsyncCMAStream`. Octave now parses those bases and their derived classes.

During accessor conversion, same-named output temporaries in the multi-factorial
initialization/selection paths were renamed (`ObjMatrix`, `CVVector`) to avoid masking the
accessor function on a later task iteration. The `MFEA`/`CMT1` smoke test exercises both tasks
and the selector.

Confirmed **working** in Octave 11.3 (no action needed): `classdef (Abstract)`, superclass
constructor calls (`o@Super(args)`), `properties (Constant)`, `(SetAccess = private)`,
`(Access = protected)`, `(Hidden)`, `methods (Static)`, and inheriting from `handle`.

Also note `Individual` is a **value class** (`classdef Individual`, no `< handle`) while
`Algorithm` and `Problem` are handle classes. Array growth, copy-on-write, and sharing
semantics differ accordingly — this matters for the Rust data model.

## Missing functions and local shims

`lhsdesign` and `mapminmax` are absent from Octave core and Forge `statistics`, so MToP now
provides targeted local shims for the call shapes used here. Neither shim claims to be a full
replacement for its originating toolbox function.
`tiledlayout` / `nexttile` remain absent but belong only to the out-of-scope plotting path.

| Function | Used by | Current status |
| --- | --- | --- |
| `lhsdesign(n, p)` | `MTEA_PAE`, `MO_MTEA_PAE` | Implemented at `MTO/Algorithms/Utils/Normalization/lhsdesign.m` as a smooth maximin LHS with one initial design plus five fixed candidates. Its explicit Octave draw profile is recorded in `parity.md`; MATLAB internal draw-count parity is unverified. Both call sites pass 200-FE smoke runs. |
| `mapminmax` | `SSLT_DE`, `SSLT_GA`, `CEDE_DRL`, and their `Dropout/Estimate.m` | Implemented at `MTO/Algorithms/Utils/Normalization/mapminmax.m` for default scaling and stateful `'apply'` / `'reverse'`. Unit-smoke-tested; affected training branches remain unverified. |
| `tiledlayout` / `nexttile` | `DrawPopDec`, `DrawPopObj` | Intentionally unimplemented; only reached when drawing flags are enabled. |

Forge `statistics` supplies `pdist2`, `pdist`, `kmeans`, `mvnpdf`, `mvnrnd`, `normrnd`,
`ranksum`, `tiedrank`, `datasample`, `randsample`, `mahal`, `friedman` and `histcounts`, and
they were verified against the call shapes used here. Two divergences are not currently hit:
Forge `kmeans` rejects `K` greater than the observation count, and `normrnd(vec, vec, m, n)`
is rejected. Re-grep for both after any upstream sync.

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
repo's `- g` normalisation then puts the optimum at 0. The repeatable pilot build/run is
`octave --norc -q tests/octave_mex_smoke.m`; it builds in a temporary directory and keeps no
platform-specific binary in the repository.

Two traps, both confirmed by testing:

1. **The `.cpp` files open their data through a path relative to `MTO/`, the directory that
   contains `Problems/`** (`./Problems/Single-task/CEC17-SO/input_data/M_%d_D%d.txt`). The
   smoke script changes into `MTO/` before evaluating; running from the project root would
   point at a nonexistent `./Problems/` path.
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
| Algorithms | 140 | 133 | 0 | 7 |
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
