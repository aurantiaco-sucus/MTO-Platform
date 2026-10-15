# Problems — pilot set

An eleven-class subset chosen so that making these run under Octave exercises **every
problem-definition shape and every data dependency** the other 408 in-scope problem classes
can present.

Full inventory: `prob.md`. In-scope worklist: `prob_incl.md`. Contract: `interface.md`.

Paths are relative to `MTO/Problems/` unless stated otherwise.

## Selection principle

Problems differ from algorithms in one important way: **within a suite the classes are
near-identical.** `CEC17_SO1` and `CEC17_SO17` differ only in a benchmark index; the same
holds across all 29 classes of that suite. So the useful unit of coverage is the *shape* of
a definition, not the individual class, and the pilot set picks one class per shape.

Three rules, same as `alg_pilot.md`:

1. **One class per distinct definition shape.** A suite of 57 classes is covered by one
   member if its members are generated the same way.
2. **Cheapest member wins.** Where a suite wraps a shared generator, pick a class whose own
   file is the thinnest.
3. **Order by increasing dependency**, so the first few need nothing but Octave.

---

## Tier 1 — definition shapes (do these first)

### 1. `Func_Sphere` — the closed-form problem

`Single-task/Classical Function/Func_Sphere.m` · 48 lines (of a 9-class suite)

The minimum viable problem: one task, one objective, no data, no constraints. The
objective is a one-line call into the shared base-function library; `setTasks` fills in the
dimension default and the single function handle. The bounds are set in the constructor,
which is a useful contrast with the suites that set them in `setTasks`.

**Shape:** `T = 1`, `M = 1`, no data, function from a shared library.
**Covers:** the 9 `Classical Function` classes, 2 `ATF` classes, and the shape that every
other single-task suite is a data-backed elaboration of. Read this before anything else —
it is the whole `Problem` contract in 48 lines.

### 2. `DTLZ1` — multi-objective with a reference front

`Multi-objective Single-task/DTLZ/DTLZ1.m` · 80 lines (of a 9-class suite)

Adds `M > 1` (configurable objective count, so the same class serves multi- and
many-objective runs) and — the important part — an implementation of the **reference front**,
computed analytically on the unit simplex. It evaluates a whole population at once in
vector form, in the PlatEMO idiom (a matrix of normalized decisions in, matrices of
objectives and constraint violations out).

**Shape:** `T = 1`, `M > 1`, analytic reference front, vectorized evaluation.
**Covers:** the 9 `DTLZ` classes and, more importantly, the reference-front requirement
that every multi-objective metric and plot depends on. This is the pilot that pins down the
undeclared-optional-method problem in `interface.md` §9.1.

### 3. `CMT1` — multi-task with constraints, from a function library

`Multi-task/Constrained-CMT/CMT1.m` · 63 lines (of a 9-class suite)

Two tasks, each constrained, each built from a suite-local library of constrained base
functions (13 `C_*` files alongside the suite). The two tasks deliberately have different
bounds, which is what makes per-task bounds rather than a global bound the real contract. No
external data at all. Note this library is *not* the generic one used by pilots 1 and 11 —
`Constrained-CMT/Base/` is separate from `Problems/Base/`, and the two must not be conflated.

**Shape:** `T > 1`, constraints, per-task bounds and dimensions, suite-local function library.
**Covers:** the 9 `CMT` classes and the shape shared by every CEC multi-task suite. Also the
cheapest place to test the constraint path end-to-end, because nothing else is in the way.

### 4. `CEC17_MTSO1_CI_HS` — multi-task backed by data, via a suite generator

`Multi-task/CEC17-MTSO/CEC17_MTSO1_CI_HS.m` · 29 lines (of a 9-class suite)

The class file is a 29-line wrapper; the work sits in the suite's 149-line benchmark
generator, which loads rotation and shift matrices from `.mat` files and composes rotated
base functions from them. This indirection — thin class, fat generator, shared data — is
the dominant pattern in the tree and the reason a static dependency scan has to follow
function calls transitively rather than reading one file.

**Shape:** `T > 1`, external `.mat` data, per-suite benchmark generator, rotated/shifted
base functions.
**Covers:** the 9 `CEC17-MTSO` classes and the pattern for `CEC19-MaTSO` (6),
`CEC17-MTMO` (9), `CEC21-MTMO-CPLX` (10), `LSMaTSO` (5), `STOP` (12), `C4TOP` (15) and the
three `WCCI20-*` suites (30). Roughly 100 classes reduce to this shape.

### 5. `CEC17_SO1` — MEX-backed evaluation

`Single-task/CEC17-SO/CEC17_SO1.m` · 46 lines (of a 29-class suite)

The objective is a compiled function, and the class is a thin wrapper that applies the
benchmark's offset so the optimum lands at zero. The suite carries 328 data files that the
compiled code reads itself, by a path relative to the repository root.

**Shape:** `T = 1`, MEX-backed objective, repo-root-relative data, offset normalization.
**Covers:** the 29 `CEC17-SO`, 12 `CEC22-SO`, 10 `WCCI20-MTSO`, 10
`WCCI20-MTSO-ErrorValue` and 20 `Competitive-CPLX` classes — 81 classes, all of which
become runnable once the three CEC sources are built (see `AGENTS.md` for the verified
build recipe and the two traps). This pilot is also the one that motivates porting the C++
rather than shipping binaries.

---

## Tier 2 — scale, constraints and real-world evaluation

### 6. `CEC17_CSO1` — a suite with its own function library

`Single-task/CEC17-CSO/Class/CEC17_CSO1.m` · 53 lines (of a 28-class suite)

Constrained single-task, but unlike `CMT1` the constraint functions live in a suite-local
356-line file, with 12 `.mat` inputs. The evaluation budget scales with dimension rather
than being fixed, so the budget is a function of a parameter — worth checking, because it
means changing the dimension must re-derive the budget.

**Shape:** `T = 1`, constraints, large suite-local library, dimension-dependent budget.
**Covers:** the 28 `CEC17-CSO`, 24 `CEC06-CSO`, 18 `CEC10-CSO` and 57 `CEC20-RWCO`
classes — 127 classes, the largest single group in the tree, and the one where the bulk of
the problem code (rather than the wrapper) has to be ported.

### 7. `MaT_CEC17_SO` — many-task with non-uniform dimensions

`Multi-task/Many-task CEC-SO/MaT_CEC17_SO.m` · 45 lines

Takes the 29 single-objective CEC17 functions and replicates each at three dimension
settings, giving 87 tasks whose dimensions differ. Per-task dimension is already part of
the contract, but this is the case that makes it impossible to pretend otherwise, and it is
the cheapest stress test for population padding and per-task result layout.

**Shape:** many tasks, per-task dimensions in three distinct groups, shared MEX objective.
**Covers:** the many-task regime, and the `LSMaTSO` / `WCCI20-MaTSO` / `CEC19-MaTSO` family.
Its sibling `MaT_CEC20_RWCO` in the same suite is the same pattern over the constrained
functions, so between them they cover both objective types at scale.

### 8. `CEC19_MaTMO1` — multi-objective many-task with bulk text data

`Multi-objective Multi-task/CEC19_MaTMO/CEC19_MaTMO1.m` · 65 lines (of a 6-class suite)

Many tasks, each multi-objective, built from 600 plain-text shift vectors and rotation
matrices read through a suite-local loader. The reference front is generated analytically
rather than read from disk. Task count is a user parameter, so the suite scales from small
to large without changing code.

**Shape:** `T` large and user-set, `M > 1` per task, bulk `.txt` data, analytic reference
front.
**Covers:** the 6 `CEC19-MaTMO` classes and the multi-objective multi-task *problem* shape
— the counterpart of `alg_pilot.md` pilot 9, and the combination that stresses the result
layout hardest (task index, objective index and checkpoint index all in play).

### 9. `SOPM_MTMO1` — real-world evaluation, self-contained

`Real-world Applications/Multiobjective Synchronous Optimal Pulse-width Modulation/SOPM_MTMO1.m`
· 146 lines (of a 2-class suite)

Three tasks, two objectives each, constrained, and — the distinguishing property — **no
external dependency of any kind**: no data files, no toolbox calls, no generator. The whole
problem, including the domain mathematics for a pulse-width-modulated inverter, is in the
file. It is also among the largest problem class files in the in-scope set (146 lines; only
`PEPVM` is larger, at 164), so it is where evaluation cost and the readability of domain
code get tested together.

**Shape:** `T > 1`, `M > 1`, constraints, dense domain mathematics, zero dependencies.
**Covers:** the self-contained real-world family — `MOSCP` (2), `SOPM` (2), `PEPVM` (1),
`PKACP` (1), `SCP` (1). Small in class count, but it is the only shape where the port must
carry domain logic rather than benchmark scaffolding, and `PKACP` additionally pulls in a
statistics call, so the pair exercises both variants.

### 10. `AMTSO_Case1_P1` — the stream contract

`Stream-task/AMTSO-Case1/AMTSO_Case1_P1.m` · 40 lines (of a 9-class suite)

Declares the two properties the stream contract needs — task arrival times and per-task
evaluation budgets — which no other problem shape has. Tasks become available partway
through a run, so the budget is per task rather than only total, and the problem must define
what happens to a task that has not arrived yet.

**Shape:** `T` tasks arriving over time, per-task budgets, stream metadata.
**Covers:** the 9 `AMTSO-Case1`, 9 `AMTSO-Case2`, 1 `AMaTSO10` and 2 `APKACP` classes, and
the declared-capability requirement in `interface.md` §4.3. Pair it with `alg_pilot.md`
pilot 10; neither half of the stream contract is testable alone.

### 11. `C2TOP_Case1_P1` — competitive, via a suite generator

`Multi-task/Competitive-C2TOP/Case1/C2TOP_Case1_P1.m` · 21 lines (of 36 classes across 4 cases)

The thinnest class in the tree: it reads the task list out of a suite-level generator and
assigns each task's function handle. The distinguishing metadata is the *competitive*
character, meaning several tasks optimise the same underlying landscape with opposed
interests — a dimension the query layer must filter on but the evaluation contract does not
otherwise change.

**Shape:** competitive metadata, thin wrapper over a shared generator, tasks built from the
generic `Problems/Base/` function library (the same one pilot 1 uses), bounds coming from
the generator rather than the class.
**Covers:** the 36 `C2TOP` classes and the 12 `Competitive-CMOMT` classes, plus the
competitive label as a catalog dimension. It is the counter-example to the "fat generator,
thin class" pattern being a porting burden: here the generator is 9 `.mat` files and a
switch statement over the seven generic base functions, and the whole suite is cheap.

---

## Coverage summary

| # | Pilot | Own lines | Shape added | Suite classes covered |
| --- | --- | --- | --- | --- |
| 1 | `Func_Sphere` | 48 | `T=1`, closed form, no data | 9 (+2 `ATF`) |
| 2 | `DTLZ1` | 80 | `M > 1`, analytic reference front | 9 |
| 3 | `CMT1` | 63 | `T > 1`, constraints, suite-local function library | 9 |
| 4 | `CEC17_MTSO1_CI_HS` | 29 | `.mat` data, suite generator | ~100 |
| 5 | `CEC17_SO1` | 46 | MEX-backed objective | 81 |
| 6 | `CEC17_CSO1` | 53 | suite-local library, dimension-dependent budget | 127 |
| 7 | `MaT_CEC17_SO` | 45 | many tasks, non-uniform dimensions | many-task family |
| 8 | `CEC19_MaTMO1` | 65 | `T` large × `M > 1`, bulk `.txt` | 6 (+scale) |
| 9 | `SOPM_MTMO1` | 146 | self-contained real-world domain code | 7 |
| 10 | `AMTSO_Case1_P1` | 40 | arrival schedule, per-task budgets | 21 |
| 11 | `C2TOP_Case1_P1` | 21 | competitive metadata, thinnest wrapper | 48 |
| | **total** | **636** | | **~419** |

Deliberately not pilot-ed, with reasons:

- **`CEC17_SO2` … `CEC17_SO29`** and siblings inside every suite — index variants only.
- **`WCCI20-MTSO-ErrorValue`** — `CEC17_MTSO`'s shape with a different offset; covered by
  pilot 5, since it shares the same compiled source.
- **The three OPF suites and `Global Trajectory Optimization`** — excluded (MATPOWER,
  ESA toolbox); see `prob.md`.
- **`MaT-Gym`** — excluded (Python).
- **`APKACP`, `AMaTSO10`** — covered by pilot 10; they are stream shapes with different
  arrival schedules.

## Porting notes that apply to the whole set

- **Tier 1 needs nothing but Octave and the four base-class fixes.** Start there; the only
  optional external piece is the statistics package, and pilot 1 does not even need that.
- **Data loading is uniform.** Every suite uses the same two idioms: `load(...)` for
  `.mat`, `load(..., '-ascii')` for text. There is no third mechanism, so one data-access
  layer covers all 1219 files.
- **`setTasks` is called more than once.** Core calls it before every repetition and the
  parameter setters call it on change, so it must be idempotent. The suites that rebuild
  their whole task list from a generator each time (pilots 4, 6, 7, 8, 11) are where an
  accidental dependence on previous state would show up first.
- **Per-task, not global.** Bounds, dimensions and objectives are all per task. Pilots 3
  and 7 are the two that make this unavoidable — pilot 3 through differing bounds, pilot 7
  through differing dimensions.
- **No reference front is ever read from disk.** All 80 implementations compute it
  analytically, so the reference-front capability has no file dependency and can be tested
  without any data plumbing.
