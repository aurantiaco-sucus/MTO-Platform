# Plugin interface

What a Problem or Algorithm plugin must expose, and what the core must provide in
return, for an architecture that separates **infrastructure** (core: plugin loading,
scheduling, CLI, GUI) from **plugins** (Problems, Algorithms).

This is a design document, not a description of the code as it stands. Where the current
implementation differs from the target, that is called out in §9. No target language is
assumed.

---

## 1. The seam

```
        ┌───────────────┐        ┌───────────────┐
        │      CLI      │        │      GUI      │
        └───────┬───────┘        └───────┬───────┘
                │      depends on        │
                └───────────┬────────────┘
                            ▼
                 ┌─────────────────────┐
                 │        CORE         │
                 │  registry, runner,  │
                 │  result schema,     │
                 │  metrics, services  │
                 └──────────┬──────────┘
                            │  loads / drives
                            ▼
     ┌──────────────────────────────────────────────┐
     │                  PLUGINS                     │
     │  Problem │ Algorithm │ Individual │ Metric   │
     └──────────────────────────────────────────────┘
```

Two rules define the whole design:

1. **Core never names a plugin.** No `if name == "NSGA-II"`, no `if isa(…, 'MaT_Gym')`,
   no problem-specific or algorithm-specific field access outside the declared contract.
   Everything core needs is either in the contract or probed as an optional capability.
2. **Plugins depend on core, never on each other.** An algorithm must not `import`, call,
   or special-case a specific Problem. The only Problem surface it may touch is the
   contract in §4.

Corollary: the front-ends (CLI, GUI) depend on core only. They must be able to enumerate,
describe, configure, run and display *any* plugin without knowing what it is — which is
what makes the parameter-marshalling design in §4.4 and §5.5 load-bearing rather than an
implementation detail.

### The interface is bidirectional

"Plugin interface" is usually read as core→plugin. It is equally plugin→core: an
Algorithm is *written against* a library of services that core provides (evaluation,
termination, initialization, operators, selection, sorting). Those services are the
larger half of what a plugin author actually touches, so they are part of the published
interface and must be versioned alongside it. See §7.

---

## 2. Plugin kinds

| Kind | Purpose | Cardinality |
| --- | --- | --- |
| **Problem** | Defines tasks, bounds, objective/constraint functions, evaluation budget | Many; several per run |
| **Algorithm** | Search procedure driving a Problem | Many; several per run |
| **Individual** | Representation + per-candidate state; *supplied by* an Algorithm, consumed by core services | Several; one per algorithm |
| **Metric** | Post-hoc scoring of recorded results | Many; selected by the front-end |

`Individual` is the one that surprises people: it is a plugin, but it is not loaded by
core directly. An Algorithm declares which representation it needs by passing the class
to the initialization service (§6). This is what lets one core support real-coded DE,
particle swarms with velocities, and multifactorial individuals with skill factors
without knowing any of them.

---

## 3. Discovery, identity and catalog metadata

### 3.1 Identity

Every plugin has a stable identity: its type name (`MFEA`, `DTLZ1`), and a display name
derived from it by `_` → `-`. Core may construct a plugin from either its type name or an
already-constructed instance.

### 3.2 Catalog metadata

Plugins self-describe along a small, fixed set of dimensions used for filtering and for
GUI grouping:

| Dimension | Values |
| --- | --- |
| Task cardinality | `Single-task`, `Multi-task`, `Many-task` |
| Objective cardinality | `Single-objective`, `Multi-objective`, `Many-objective` |
| Constraint character | `None`, `Constrained` |
| Competitive character | `Competitive`, `NonCompetitive` |
| Arrival character | `Stream` (present only for stream problems) |
| Year (algorithms) | `Year: YYYY`, or absent |

A dimension may declare several acceptable alternatives (`None/Constrained`), which means
*this plugin supports either mode*, not *either is fine for a query*: a query requires
**all** selected tokens and **none** of the excluded ones.

### 3.3 The metadata must become introspectable

Today this metadata lives in a comment line in the plugin's source file and is extracted
by regex over the file text. That forces any loader to read source text off disk, which
makes plugin distribution, precompiled or bundled plugins, and caching all awkward.

**Target:** metadata is returned by the plugin itself, from a declaration method, in the
same shape as §3.2. Comment headers may stay as the human-readable form, but must not be
the machine-readable source of truth. A plugin that cannot be introspected without
reading its source is not loadable.

---

## 4. Problem contract

### 4.1 Declared members

| Member | Kind | Meaning |
| --- | --- | --- |
| `Name` | property | Display name |
| `T` | property | Task count |
| `N` | property | Per-task population size (advisory; algorithms may override) |
| `M` | property, 1×T | Objectives per task. `M(t) > 1` means task *t* is multi-objective |
| `D` | property, 1×T | Dimension per task |
| `maxFE` | property | Total evaluation budget across all tasks |
| `Fnc` | property, 1×T cell | Per-task evaluator: `[Obj, Con] = Fnc{t}(X)`, `X` is N×D(t) in **real** coordinates |
| `Lb`, `Ub` | property, 1×T cell | Per-task bounds, row vectors 1×D(t) |
| `Bounded` | property | If false, core must not clamp to bounds |
| `ReEvalBest` | property | If true, core appends the current best to each evaluation batch |
| `setTasks()` | method | (Re)build `T/M/D/Fnc/Lb/Ub/maxFE`. **Must be idempotent** |
| `evaluate(X, t)` | method | Bounds-clamp then call `Fnc{t}(X)`. Returns `[Objs, Cons]`, N×M(t) and N×C |

### 4.2 Conditionally required: the reference front

Multi-objective metrics and plots need a reference set or point. This is **not** part of
the single-objective contract, so it is a separate optional capability (§4.3), not a
required method. Core must degrade gracefully when it is absent: metrics that need a
reference become unavailable rather than erroring.

### 4.3 Optional capabilities

Optional features are declared by the plugin and **probed by core**, never assumed. The
probing mechanism must be a declaration (a declared capability/attribute set or an
explicit `supports()` query), not a trial call that throws.

| Capability | Meaning | Consumers |
| --- | --- | --- |
| Reference front / point | Accessor returning the true Pareto front or a reference point, per task | MO metrics, MO plots |
| Task arrival schedule | `Arrival` — 1×T evaluation-time offsets at which each task becomes available | `StreamAlgorithm` |
| Task budget | `TaskBudget` — 1×T per-task evaluation budgets | `StreamAlgorithm` |
| Initial mean | Optional per-task starting mean for distribution-based algorithms | ES-family algorithms |
| Initial sigma scale | Optional per-task starting step scale | ES-family algorithms |

A plugin that does not declare `Arrival`/`TaskBudget` must not be paired with a stream
algorithm; core should reject the pairing at scheduling time with a clear message, not
fail midway through a run.

### 4.4 Parameter surface

A Problem exposes its tunables as a **flat ordered list of label/value string pairs**, and
consumes them back as a flat ordered list of value strings:

```
getParameter()      -> [label1, value1, label2, value2, ...]
setParameter(values)-> values = [value1, value2, ...]
```

This is the mechanism that lets a front-end build a parameter editor for a plugin it has
never heard of, and it should be kept. Two properties are essential:

- **Positional contract.** `setParameter` receives values in the order `getParameter`
  returned them. Labels are for display only. Core must round-trip without reordering.
- **Composability.** A subclass that adds parameters must splice its own onto the
  inherited set rather than replacing it, so a partially-typed value list still lands in
  the right slots. Getting this wrong silently mis-assigns parameters, since everything
  is a string.

**Target improvement:** carry a type and a default per parameter so the front-end can
validate and reset without plugin-specific knowledge. A typed entry
(`label, type, value, default`) keeps the flat structure while removing the guesswork;
today a malformed value becomes `NaN` somewhere downstream with no diagnostic.

### 4.5 Lifecycle and invariants

```
construct(name?)        -> setTasks() runs inside construction
  ↺ setTasks()          -> core calls before EVERY repetition (must be idempotent)
      evaluate(X, t)    -> called only via the algorithm's evaluation service
```

Invariants a Problem must hold:

- Constructible with zero arguments, and with an optional display name.
- `setTasks()` may be called repeatedly and by both core and the plugin itself; it must
  leave the problem in the same state each time for a given parameter set.
- Changing a parameter that affects `T/M/D/Fnc/Lb/Ub/maxFE` must go through
  `setTasks()` before the next run.
- `Fnc{t}` takes and returns **real** coordinates. Normalization to the unit box is the
  evaluation service's job, not the Problem's.
- `Fnc{t}` must be pure with respect to the problem's own state: no caching across calls
  that would make results order-dependent. If a Problem is stochastic, that must be
  declared, because reproducibility depends on it.
- `evaluate` must not count evaluations. Budget accounting belongs to core (§5.2).

---

## 5. Algorithm contract

### 5.1 Declared members

| Member | Kind | Meaning |
| --- | --- | --- |
| `Name` | property | Display name |
| `FE` | property | Evaluations consumed. **Owned by core** |
| `Gen` | property | Generation counter. **Advanced by core** |
| `Best` | property, 1×T cell | Best-so-far per task (single-objective); maintained by core |
| `Mean` | property, 1×T cell | Current mean per task, for distribution-based algorithms |
| `reset()` | method | Return to a pre-run state. Subclasses extend it, then delegate to it |
| `run(Prob)` | method | **The only abstract method.** The search procedure |
| `getResult(Prob)` | method | Produce the fixed result layout (§8) |
| `getParameter` / `setParameter` | methods | Same shape and rules as §4.4 |
| `drawInit(Prob)` | method | One-time setup of any live visualization |

### 5.2 Services the algorithm must use, not reimplement

These are core's half of the contract. An algorithm that bypasses them breaks evaluation
accounting, termination, and result recording simultaneously — usually silently.

| Service | Contract |
| --- | --- |
| `Evaluation(Pop, Prob, t)` | Decodes normalized → real coordinates, clamps, calls the Problem, **increments `FE` by the number of points actually evaluated**, writes `Obj`/`Con`/`CV` back onto the individuals, updates `Best{t}` for single-objective tasks. Returns the (possibly truncated) population. |
| `notTerminated(Prob, Pop)` | The loop predicate **and** the per-generation bookkeeping step: records the generation's result, advances `Gen`, updates visualization, invokes the status callback. Returns whether the run should continue. |
| `Initialization*` | Population construction, per representation (§6) |
| Operators | Crossover/mutation/boundary handling |
| Selection & sorting | Elitist and multi-objective selection, non-dominated sorting, crowding distance, comparison operators respecting feasibility |

Invariants:

- **Every objective call goes through `Evaluation`.** The evaluation count is derived
  from the batch size, so any evaluation the algorithm performs directly makes `FE`
  under-count and the run over-run its budget.
- **`notTerminated` is called exactly once per generation**, as the `while` condition.
  It carries side effects, so calling it an extra time — even just to "check" — records a
  spurious generation and advances the counter.
- **`Evaluation` may return fewer individuals than requested.** Stream algorithms
  truncate to respect task budgets. Algorithms must handle a short batch.
- `FE` and `Gen` are core-owned. An algorithm may read them; it must not assign them.

### 5.3 Optional overrides

An algorithm may override `reset`, `getResult`, `drawInit`, `getParameter`,
`setParameter`. It must not need to override `Evaluation` or `notTerminated` — the stream
algorithm overrides `Evaluation` only to add budget accounting around the core one,
delegating to it rather than reimplementing it. An override that duplicates core logic is
a signal the contract is missing something; fix the contract instead.

### 5.4 Stream algorithms

A stream algorithm has a different lifecycle because tasks arrive over time and each has
its own budget, so it **implements** the run loop in core and lets the plugin fill in the
per-step behaviour:

| Member | Kind | Contract |
| --- | --- | --- |
| `step(Prob, active)` | abstract method | Do work for the currently-active tasks. **Must perform at least one evaluation**, otherwise the loop cannot make progress |
| `onEvent(Prob, event, tasks)` | optional method | React to lifecycle events: task start, arrival, completion, idle-end, finish. Update state here — not evaluations |
| `Clock`, `TaskFE`, `Population`, `State`, `Shared`, `TaskHistory` | properties | Per-task and cross-task state, owned and maintained by core |

Note: because core owns the loop, the stream contract is the *template method* pattern —
core fixes the sequence (arrival → step → completion → idle) and the plugin supplies only
`step` and `onEvent`. This is the shape the non-stream contract should converge on too:
today a non-stream algorithm reimplements its own `while` loop, which is how lifecycle
drift between algorithms happens.

### 5.5 Parameter surface

Identical to §4.4, and it must remain identical. Any divergence between the Problem and
Algorithm parameter protocols forces every front-end to special-case them.

### 5.6 Lifecycle order

Core drives plugins in this order, and the order is part of the contract:

```
per run:
  for each (problem, algorithm, repetition):
      seed the RNG                          # reproducibility is core's responsibility
      problem.setTasks()
      algorithm.reset()
      algorithm.run(problem)                # generates FE via the evaluation service
                                              # and terminates via notTerminated
      algorithm.getResult(problem)

once per run, before repetitions:
  algorithm.drawInit(problem)               # visualization setup only
  algorithm.Result_Num  = <front-end value> # output resolution
  algorithm.Save_Dec    = <front-end flag>  # whether decision vectors are retained
```

Two consequences worth stating: `reset()` must fully clear per-run state (an algorithm
that leaks state across repetitions invalidates every repetition after the first), and
the front-end-configured output flags must be honoured by `getResult` without the
algorithm needing to know who set them.

---

## 6. Individual (representation) contract

An Algorithm supplies a representation class to the initialization service; core and the
platform utilities then operate on it generically.

**Required fields**

| Field | Meaning |
| --- | --- |
| `Dec` | Decision vector, **normalized to `[0,1]^D`** |
| `Obj` | Objective vector, 1×M |
| `Con` | Constraint vector |
| `CV` | Scalar constraint violation (aggregate) |
| bulk accessors | Matrix/vector views over a population without looping |

**Capability groups.** A representation may add fields; a service that needs them declares
the requirement, and the pairing must be validated at load time.

| Group | Fields | Required by |
| --- | --- | --- |
| Base | `Dec`, `Obj`, `Con`, `CV` | everything |
| Evolution-strategy state | per-individual parameters and step state | DE/ES-family algorithms |
| Particle state | velocity | PSO-family algorithms |
| Multifactorial state | skill factor, per-task objective/violation/rank vectors | the multi-factorial family — the largest single group |

**Population shape is not uniform.** Three forms exist and a representation/algorithm
pair must agree on which one it uses:

1. **Per-task cell** — one population per task. The common multi-population case.
2. **Single flat array with a skill factor per individual** — the multifactorial case.
3. **2-D individual array** — used by some constrained algorithms, where columns carry
   different roles.

This should be an explicit, declared property of the initialization service rather than
something inferred from which variant the algorithm happened to call.

---

## 7. Core services to be published and versioned

Core's service library is part of the interface. It should be grouped, documented, and
carry a compatibility version, because plugins call it directly:

| Group | Examples |
| --- | --- |
| Population | initialization variants per representation and population shape |
| Operators | GA crossover/mutation, DE crossover variants |
| Boundary handling | clip, midpoint, reflect, resample, random-reset, violation measure |
| Comparison & sorting | feasibility rules, single-objective comparison, non-dominated sort, crowding distance, uniform reference points |
| Selection | elitist, tournament, roulette, multi-factorial, secondary-selection |
| Stream | batch evaluation, warm-start initialization, checkpointing, asynchronous model updates |
| Output & recording | result recording at evaluation checkpoints, result finalization and sampling |

Two obligations come with this:

- **Services must not assume a representation** beyond its declared capability group.
  A boundary handler that reaches for `Dec` is fine; one that assumes a skill factor is
  not.
- **Services are the extension point for shared behaviour.** When two plugins need the
  same logic, it goes here, not into one plugin imported by the other. That is the rule
  that keeps plugins independent of each other.

---

## 8. Result schema

`getResult` must return the layout core records and the front-ends consume, unchanged
across all plugins, so that metrics and exporters are plugin-agnostic:

- A task-count × checkpoint-count array.
- Per entry: objective values, constraint violation, and optionally the decision vector.
- Tasks with different dimensions are padded to a common width.
- Decision vectors are returned in **real** coordinates.
- Multi-objective results carry per-task objective cells; single-objective results carry
  scalars. This branch must be a documented part of the schema, not an ad-hoc `if`.

The saved experimental record is a separate, also-fixed schema: the problem set (with
task/objective/dimension metadata, bounds, and the reference front where declared), the
algorithm set (with the parameter list captured at run time), the result array, and run
times. Because the parameter list is captured as strings, the record is self-describing —
a run can be reproduced from the saved file alone. Preserve that property.

---

## 9. Where the current implementation violates this design

Ordered by how much they obstruct the separation.

1. **The reference front is an undeclared, conditional requirement.** Multi-objective
   metrics, multi-objective plots and the CLI all call the accessor; it is defined by many
   problem classes but declared by none. Core has no way to know whether a given problem
   provides it, so a missing definition surfaces as an error deep inside a metric.
   *Fix:* declare it as an optional capability (§4.3) and gate its consumers on the
   declaration.

2. **Stream properties are undeclared.** `Arrival` and `TaskBudget` are defined per
   problem class and read directly by the stream run loop. Pairing a stream algorithm with
   a problem that lacks them fails at run time, mid-loop. *Fix:* declare them as a
   capability and validate the pairing before the run starts.

3. **A shared helper branches on plugin identity.** The policy-search result handler
   decides whether to act by testing whether the problem's type name contains a particular
   substring. This is exactly the coupling the architecture is supposed to prevent: the
   helper is core code that names plugins, and adding another policy-search problem means
   editing core. *Fix:* an optional lifecycle hook that policy-search problems implement,
   or a declared capability that the helper checks.

4. **Plugins are constructed by name via dynamic evaluation.** Passing a plugin name
   evaluates an expression against the path. This requires plugins to be present as
   source on the path and makes construction order- and path-dependent. *Fix:* a registry
   that maps identity → constructor, populated at load time.

5. **Catalog metadata is parsed out of source text** (§3.3). *Fix:* introspection
   (§3.3).

6. **No capability or version declaration.** Plugins cannot state what they support, and
   core cannot state what it requires, so incompatible pairings are discovered by
   crashing. *Fix:* a per-plugin manifest — kind, metadata, required capabilities,
   interface version — checked at load.

7. **Population shape is implicit.** Which of the three shapes (§6) an algorithm uses is
   encoded in which initialization function it calls. *Fix:* make it a declared property
   of the request.

8. **Non-stream algorithms own their run loop.** Each reimplements initialization,
   the generation loop, and termination. This is the source of lifecycle drift; the stream
   contract already shows the better shape (core owns the loop, plugin fills `step`).
   *Fix:* converge non-stream algorithms onto the same template.

9. **Errors have no defined surface.** A plugin has no stated obligation about what it may
   throw, what core will catch, or how a partial run is reported. *Fix:* define a small
   error taxonomy — configuration error (report and refuse to start), evaluation error
   (record and continue or abort per policy), internal error (abort the run) — and require
   plugins to use it.

---

## 10. Target interface, summarised

**Core requires of a plugin**

- Constructible with zero arguments, and with an optional display name.
- Self-describing: kind, catalog metadata, required capabilities, interface version.
- Parameter surface: ordered label/value pairs out, ordered values in.
- The kind-specific contract: §4 for Problems, §5 for Algorithms.
- Use of core's evaluation and termination services rather than parallel implementations.

**Core guarantees to a plugin**

- A versioned service library (§7) that will not change incompatibly within a version.
- Deterministic setup: RNG seeding, `setTasks()` before each repetition, `reset()` before
  each run, and the lifecycle order in §5.6.
- Evaluation accounting, termination, result recording and output resolution handled
  centrally — the plugin never counts evaluations or decides when to stop on its own.
- No plugin ever needs to know about another plugin.

**Front-ends (CLI, GUI) require of core**

- Enumerate plugins with their metadata, without reading source.
- Build a configuration editor for any plugin from its parameter surface alone.
- Run any (problem, algorithm) pairing, and receive the declared incompatibility instead
  of a crash.
- Read results through one fixed schema, independent of which plugins produced them.

The test of the design is a single question: **can a new Problem and a new Algorithm be
added, as new files with no edits to existing files, and be discoverable, configurable and
runnable from both front-ends?** If any part of that needs a change to core or to another
plugin, the seam has leaked.
