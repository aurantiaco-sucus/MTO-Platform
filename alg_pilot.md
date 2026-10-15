# Algorithms — pilot set

A ten-algorithm subset chosen so that making these run under Octave exercises **every
interface surface and every porting obstacle** the other 123 in-scope algorithms can
present. The intent is that after these ten, the remainder is mechanical repetition.

Full inventory: `alg.md`. In-scope worklist: `alg_incl.md`. Contract: `interface.md`.

Paths are relative to `MTO/Algorithms/` unless stated otherwise.


## Verified progress (2026-10-15)

All ten algorithm pilots now pass the headless smoke suite in `tests/octave_smoke.m`:
`GA`, `jDE`, `CMA_ES`, `NSGA_II`, `MFEA`, `ECHT`, `MFEA_II`, `EMaTO_MKT`, `MO_MFEA`, and
`AEMEA`. The suite covers online RMP learning and Forge statistics, many-task clustering,
joint multi-objective/multifactorial sorting, and the stream transfer checkpoint, with exact
FE and per-task budget assertions. Other algorithms and stream implementations remain
untested.

## Selection principle

Representatives are picked by **mechanism, not by popularity or recency**, under three
rules:

1. **Each pilot adds exactly one new mechanism** over the ones before it. If two
   candidates add the same thing, keep the smaller.
2. **Cheapest member of its family wins.** Where a family has 15 members that differ only
   in parameters (15 multi-factorial variants, 11 DE variants), the pilot is the one with
   the fewest lines and no incidental extras.
3. **Prefer families with many members.** Ordering the pilots by family size means the
   first few unlock the most.

Each pilot states what it unlocks, using measured counts across the 133 in-scope
algorithms.

---

## Tier 1 — the core loop (do these first)

### 1. `GA` — the minimal algorithm

`Single-task/Genetic Algorithm/GA/GA.m` · 1 file, 66 lines

The smallest complete algorithm in the tree, and the reference for the whole lifecycle:
construct → `Initialization` → `while notTerminated(...)` → `Evaluation` → selection.
Also the reference for the parameter surface (`getParameter`/`setParameter` as ordered
label/value string pairs).

Uses the **base representation**, fixed hyperparameters on the algorithm, one population
per task, elitist selection.

**Adds:** the core loop, the parameter protocol, the base `Individual`.
**Unlocks:** the 74 in-scope algorithms that build populations with the cell-per-task
initializer and the base representation — the single largest group, and structurally
identical from here.

### 2. `jDE` — per-individual adaptive state

`Single-task/Differential Evolution/jDE/jDE.m` · 1 file, 89 lines

Same skeleton as `GA`, but each individual carries its own control parameters (`F`, `CR`)
that are **inherited by offspring and randomly re-drawn**, then read back by the operator.
That makes the representation — not the algorithm — the owner of part of the search state,
which is exactly the hook `interface.md` §6 formalises.

`DE` (58 lines) is the same skeleton with fixed `F`/`CR` on the algorithm and the base
representation; read it first if the adaptive part is unclear. It is covered by this
entry and is not a separate pilot.

**Adds:** a representation subclass as a plugin (`Individual_DE`), per-individual mutable
state, the DE operator family, two-argument `randperm`.
**Unlocks:** the 22 in-scope algorithm classes using `Individual_DE`, plus every algorithm
that goes through the DE operators. In total 29 files reference `Individual_DE` and 66
reference the DE operator set, so this one pilot's representation hook is exercised by
roughly half the tree. It is also the cheapest place to hit the `randperm(n, k)` and
comma-list-on-object-array compatibility questions, since the operators are two lines each.

### 3. `CMA-ES` — distribution-based lifecycle

`Single-task/Evolution Strategy/CMA-ES/CMA_ES.m` · 1 file, 146 lines

Breaks the "keep a population" assumption. There is no persistent population: each
generation samples fresh points around a mean, evaluates them, and updates the mean,
covariance and step size. The algorithm's durable state lives in `Algo.Mean{t}`, which the
core evaluation service also reads when a problem asks for best-solution re-evaluation.

**Adds:** `Algo.Mean` as a first-class contract; per-generation sampling instead of
population replacement; covariance/step-size state.
**Unlocks:** the 19 in-scope algorithms that use `Algo.Mean` — the whole evolution-strategy
group (`xNES`, `SNES`, `R1-NES`, `sep-CMA-ES`, `IPOP-CMA-ES`, `DES`, `TNG-SNES`, …), which
otherwise looks nothing like the population algorithms. Also the entry point for the
optional per-task initial-mean / initial-scale capabilities.

### 4. `NSGA-II` — multi-objective, single-task

`Multi-objective Single-task/Non-dominated Sort/NSGA-II/` · 2 files, 185 lines

The smallest multi-objective algorithm. Introduces `M > 1`, non-dominated sorting,
crowding distance, binary tournament on rank, and — crucially — a dependency on the
**reference front** that the problem may or may not declare. Its logic is transcribed from
PlatEMO, so it also carries the provenance and licensing note (see `AGENTS.md`).

**Adds:** `M > 1` throughout the evaluation/selection path; the non-dominated sorting and
crowding-distance services; the conditional reference-front requirement (the undeclared
contract hole in `interface.md` §9.1).
**Unlocks:** the 15 in-scope multi-objective single-task algorithms, and the multi-objective
half of the multi-task ones. `NSGA_II_DE` in the same folder is the DE-operator variant.

### 5. `MFEA` — multifactorial, one population with skill factors

`Multi-task/Multi-factorial/MFEA/MFEA.m` · 1 file, 105 lines

Replaces the cell-per-task population with a **single flat population** in which each
individual carries a skill factor saying which task it belongs to. Crossover happens
between individuals of different tasks with probability RMP, and offspring are grouped back
by skill factor for evaluation. Selection is the multi-factorial variant.

**Adds:** the flat-population shape; the skill-factor representation (`Individual_MF`);
multifactorial initialization and selection; grouping by a per-individual field.
**Unlocks:** the 15 in-scope algorithms using the multifactorial initializer and the 16
using `Individual_MF`. The multi-factorial family is the largest single group in the tree,
so this pilot has the highest ratio of algorithms-unlocked to lines-read.

---

## Tier 2 — the remaining mechanisms

### 6. `ECHT` — constraint handling

`Single-task/Constraint Handling/ECHT/ECHT.m` · 1 file, 144 lines

Adds feasibility to the picture: candidates are compared by constraint violation before
objective, and the population is carried as a **2-D individual array** whose columns play
different roles (candidates in one column, auxiliary/archive individuals in another).

**Adds:** the constraint-comparison services; the third population shape (2-D array);
constraint-driven replacement.
**Unlocks:** the 7 in-scope algorithms using the constraint helpers, spanning single-task,
multi-task and multi-objective constrained algorithms — the comparison operators are shared
across all three.

### 7. `MFEA-II` — an embedded learner

`Multi-task/Multi-factorial/MFEA-II/` · 2 files, 273 lines

`MFEA` with the RMP matrix *learned* online instead of fixed: the algorithm fits a
per-task probabilistic model to each task's subpopulation and derives the mating
probabilities from it. The learner lives in its own file and is where the randomness for
the model-fitting enters.

**Adds:** an algorithm-private numerical component; a second file per algorithm; model
fitting with statistics-toolbox calls.
**Unlocks:** the 8 in-scope algorithms that own or borrow a numerical model (`LDA-MFEA`,
`BoKT`, `DTSKT`, `MO-MFEA-II`, `AMT-NSGA-II`'s mixture model, …). This family is where
"the algorithm needs a library" first appears, and where the statistics dependency is
concentrated.

### 8. `EMaTO-MKT` — many-task with clustering

`Multi-task/Many-task/EMaTO-MKT/` · 2 files, 206 lines

Many-task: `T` is large, so the algorithm clusters tasks to decide who transfers to whom,
and defines a distribution-distance measure to compare clusters. It calls `kmeans` and
carries custom helper methods (an RBF-kernel dot product, a maximum-mean-discrepancy
measure) as methods on the algorithm itself.

**Adds:** task clustering at scale; a `kmeans` dependency (Octave-covered, verified);
substantial algorithm-private helper methods; the many-task regime.
**Unlocks:** the 15 in-scope many-task algorithms and the 4 in-scope algorithms calling
`kmeans` (`TRADE`, `LDA-MFEA`, `BLKT-DE`). Also the cheapest place to validate the
statistics-package substitution end-to-end.

### 9. `MO_MFEA` — multi-objective and multi-task combined

`Multi-objective Multi-task/Multi-factorial/MO-MFEA/MO_MFEA.m` · 1 file, 105 lines

`MFEA` where every task is also multi-objective, so population size, mating-pool indices
and selection all scale with both `T` and `M`.

**Adds:** the interaction of `M > 1` with per-task populations; selection that must rank
across a joint population.
**Unlocks:** the 20 in-scope multi-objective multi-task algorithms — the platform's
headline category, and the combination that most often breaks naive indexing (task index
vs. objective index vs. individual index). Structurally it is a small delta on `MFEA`, so
it is cheap once pilots 4 and 5 are done.

### 10. `AEMEA` — stream lifecycle

`Stream-task/AEMEA/` · 2 files, 220 lines

The only pilot with a genuinely different contract: it does not implement `run` at all.
Core owns the loop, and the algorithm implements `step(Prob, active)` plus an optional
`onEvent(Prob, event, tasks)`. Tasks arrive at scheduled evaluation times with their own
budgets, so batches can be truncated and work must be resumable across arrival events.

**Adds:** the stream contract (`step`/`onEvent`); per-task evaluation budgets; task
arrival; an algorithm that must persist partial state between calls; the requirement that
a step perform at least one evaluation.
**Unlocks:** the 9 in-scope stream algorithms. Because this is the one place where core
owns the control flow, it is also the model the rest of the architecture should converge
on (`interface.md` §5.4, §9.8).

---

## Coverage summary

| # | Pilot | Files | Lines | New mechanism | Unlocks |
| --- | --- | --- | --- | --- | --- |
| 1 | `GA` | 1 | 66 | core loop, parameter protocol, base representation | 74 |
| 2 | `jDE` | 1 | 89 | `Individual_DE`, per-individual state, DE operators | 22 classes (29 files) |
| 3 | `CMA-ES` | 1 | 146 | `Algo.Mean`, distribution lifecycle | 19 |
| 4 | `NSGA-II` | 2 | 185 | `M > 1`, non-dominated sort, reference front | 15 |
| 5 | `MFEA` | 1 | 105 | flat population + skill factor | 15 + 16 |
| 6 | `ECHT` | 1 | 144 | constraint comparison, 2-D population | 7 |
| 7 | `MFEA-II` | 2 | 273 | embedded learner, second file | 8 |
| 8 | `EMaTO-MKT` | 2 | 206 | task clustering, `kmeans`, helpers | 15 (+4 kmeans) |
| 9 | `MO_MFEA` | 1 | 105 | `M > 1` × per-task populations | 20 |
| 10 | `AEMEA` | 2 | 220 | stream `step`/`onEvent`, per-task budgets | 9 |
| | **total** | **14** | **1539** | | **~133** |

Not covered by a dedicated pilot, and why:

- **`DE`** — same skeleton as `GA` with fixed control parameters; covered by pilot 2.
- **`PSO`** — the `Individual_PSO` velocity representation (4 algorithms) is a distinct
  capability group in `interface.md` §6, but mechanically it is pilot 2's pattern with a
  velocity field. Add it if the particle family is a priority.
- **`CAL-SHADE`, `JADE`, `SHADE`, `L-SHADE`, `NL-SHADE-RSP`, `jSO`** — the successful-history
  adaptive DE family. Distinct in detail, identical in interface; pilots 1 and 2 cover the
  machinery.
- **`TLTLA`, `G-MFEA`, `SREMTO` and the other multi-factorial variants** — parameter
  variations on pilot 5.
- **The 8 algorithms under `MO single-task/Non-dominated Sort`** — variations on pilot 4.
- **Excluded algorithms** (`EMT_GS`, `MFEA_VC`, `KLDE`, `KLPSO`, `LES`, `ABOM`,
  `MMTO_TGT`) — out of scope; see `alg.md`.

## Porting notes that apply to all ten

These are shared, not per-pilot, and all are described in `AGENTS.md`:

- All ten need the four base-class fixes before anything loads. The `jDE`/`GA`/`DE` group
  is the fastest way to confirm those fixes, because their error will be a parse failure
  rather than a wrong number.
- All ten rely on **dot-notation bulk accessors** on object arrays (`pop.Decs`, `pop.Objs`,
  `pop.CVs`). Under Octave these silently return the first element only. Pilot 1 is where
  this must be settled, since it is the smallest surface on which the wrong answer is
  visible.
- All ten depend on `rand`-consumption order for reproducibility. When fixing compatibility,
  do not reorder or replace random draws, even with equivalent-looking ones.
- Pilots 2, 5 and 9 pass a representation class into the initializer, so they are the ones
  that pin down the `Individual` contract and the population-shape question.
