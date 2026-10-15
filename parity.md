# Parity policy

**Status: settled decision. Do not reopen.**

## The decision

**Do not pursue bit-exact reproduction of Octave's or MATLAB's random number sequences in
the Rust port.** Not as a goal, not as an interim step, not behind a compatibility flag, not
"just for the pilot set".

What the port must preserve instead is **logical equivariance**: the same algorithm, the same
control flow, the same sequence of stochastic *decisions*, and the same deterministic state
transitions — while the actual random values differ freely.

If you are an agent reading this because you found that the port's `rand` does not match
Octave's: that is expected and correct. It is not a bug, and fixing it is not the task.

---

## Why this is settled

Three independent reasons, each sufficient on its own.

### 1. MATLAB parity is unattainable in principle

MATLAB draws `rand` and `randn` from **one shared generator stream**, so the interleaving of
those calls affects both. Octave draws them from **two independent streams** (verified — see
the facts table below). Therefore Octave and MATLAB already produce different sequences for
any algorithm that mixes the two, which is most of this codebase.

The consequence is the decisive one: **an implementation written to match MATLAB could not be
validated here at all.** There is no MATLAB on this machine and no way to check the work. You
would be porting an algorithm from a specification you cannot test against, into a codebase
whose only oracle disagrees with that specification by construction.

Chasing parity to Octave instead is achievable for `rand` — but Octave is not the thing the
platform's published results were produced with, so it buys comparability with the wrong
target.

### 2. The published results cannot be reproduced regardless

The platform's reference datasets were generated under MATLAB with its shared stream, across
fixed seeds. No Octave run reproduces them, and no Rust run will either. Bit-exactness was
never going to buy traceability to the paper's numbers.

### 3. Parity was only ever a means, and there is a better means

The real value of bit-exactness was as a **testing device**: run the same seed through both
implementations and diff the output to catch logic bugs by exact comparison. That device is
available more cheaply and more sharply through **RNG injection** (see "What to do instead"),
and injection additionally makes the RNG *adversarial*, which replication never can.

So: parity is not merely expensive, it is dominated. Drop it.

---

## What to do instead

### Four invariants

This is the operational definition of "logical equivariance". In decreasing order of how much
they catch:

**1. Deterministic-state parity — exact, no tolerance.**
Everything not involving RNG must match the reference exactly:

- function evaluations consumed per generation and in total
- generation count at termination, and termination at exactly the budget
- per-task evaluation counts and budgets (stream algorithms)
- population sizes, including short batches from budget truncation
- result array shape, per-task padding, constraint-violation aggregation
- the number and order of objective-function calls

No RNG is involved, so there is no excuse for a tolerance here. This is likely the majority of
the porting bug surface.

**2. Draw-count parity — exact. This is the keystone.**

For a given algorithm, problem and generation, the same number of random draws must be
consumed, for the same logical purposes, in the same order. Values may differ; counts and
ordering may not.

This is what actually defines logical equivalence for stochastic code. It catches reordered,
added, removed, duplicated and substituted draws — the dominant class of stochastic porting
bug — without requiring the values to agree. It is also cheap to assert, because Octave
exposes the counters (see below).

**3. Distributional parity — statistical.**

Each stochastic primitive must have the reference distribution, checked on large samples
(KS test for normals; mean, variance and tail quantiles otherwise). This is what makes the
port's *outputs* comparable in the aggregate, and it is the property the platform's own
methodology depends on.

**4. Value-independence — a code property, not a test.**

No assertion, branch, tuned constant or termination condition anywhere in the port may depend
on a specific random value. Enforced by review, and in practice by (2) and (3) together.

"Best-effort" becomes falsifiable once stated this way: invariants 1 and 2 hold exactly over
the pilot set, invariant 3 holds to the platform's own statistical standard, and any exception
is documented with a reason.

### RNG injection: the testing mechanism

Make the RNG an **injected dependency**, not a global. Then:

- **Fixture streams for exact logic tests.** Supply a scripted sequence of known values in
  *both* the Octave harness and the Rust harness. Any divergence is a logic bug, exactly
  detectable, with the real generator never executing. This is the exact-comparison oracle,
  obtained without replicating anything.
- **Adversarial fixtures.** A zero stream catches `log(0)`. A value at exactly `1.0` catches
  off-by-one in `floor(imax*r)+1`. A constant stream catches non-terminating rejection loops.
  Alternating extremes catch clamping and boundary-repair asymmetries. Replicating Octave's
  generator would never produce these on demand; injection produces them for free. **This is
  why injection is a sharper oracle than parity, not merely a cheaper one.**
- **Production generator behind the same interface.** PCG64 or xoshiro256++, explicitly
  seeded, documented as not portable to Octave or MATLAB.

### Draw-count instrumentation

Draw counts are observable in Octave **without patching it**. The 625th element of the
generator state is a position counter:

```
consumed_int32 = (1 - state(625)) mod 624        % rand: 2 int32 per double
```

Verified against `rand(1,k)` for k = 1, 2, 5, 17. `randn` maintains its **own** independent
counter on the same formula, so both profiles can be read separately.

One caveat: the modulus is ambiguous past 624 int32 (312 doubles) between reads. Count in
chunks smaller than that, or diff the whole 625-element state array rather than the single
counter.

The Rust side instruments its RNG wrapper to record `(generation, count, purpose)`. Assert the
two profiles are equal. This localises a divergence to a single generation, which is then
pinned down exactly with a fixture stream — a two-step bisect instead of one, which is an
acceptable cost.

### LHS-design shim profile

`MTEA_PAE` and `MO_MTEA_PAE` call only `lhsdesign(n,p)`. MathWorks documents smooth
Latin-hypercube output by default, a maximin criterion, and five criterion-improvement
iterations. The Octave shim follows that design intent by generating one initial candidate
plus five fixed candidates and selecting the candidate with the largest minimum Euclidean
pairwise distance. Each candidate is smooth: for every dimension, generate `randperm(n)` and
then `rand(n,1)` jitter within the permuted strata.

That order is the **pinned Octave/Rust profile**. Given Octave's verified `randperm(n)` uses
`n-1` uniform draws, the shim consumes `6 * p * (2*n - 1)` `rand` values. Its smoke tests
check stratum coverage and the final RNG state against that profile. The count/order used
inside MATLAB's implementation is not exposed in its documentation and cannot be checked
here; this is a documented Octave-specific reference, not a claim of MATLAB draw-profile
parity. Do not replace it with a one-shot LHS or stop early based on candidate quality.


### Why this fits this codebase specifically

The repository already treats draw order as semantic. `MTO/Algorithms/Utils/Boundary/README.md`
states that the randomized helpers "deliberately preserve the random-number consumption and
ordering of the code they replace". The maintainers already believe consumption order is part
of correctness — they enforce it by convention. Invariant 2 promotes that existing informal
rule to an executable assertion, which is strictly better than what is there now.

---

## Verified facts

Measured against GNU Octave 11.3.0 on this machine. Recorded so nobody re-derives them.

| Fact | Detail |
| --- | --- |
| Octave's `rand` generator | MT19937AR, seeded via `init_by_array([seed])`, doubles via `genrand_res53` (2 × uint32 → 53 bits) |
| Verification | Matched **bit-exactly** against an independent implementation for seeds 1, 5489, 42 |
| `rng(k,'twister')` | Identical to `rand('state', k)` |
| `rand('seed', k)` | A **different, legacy** generator — not the twister. Do not use, do not replicate |
| `randi(imax)` | Exactly `floor(imax*rand)+1`. Verified for imax = 10 and 1000 |
| `randperm(n)` | Exactly forward Fisher–Yates over `floor(i*rand)+1` |
| `randperm(n,k)` | Same method, first k steps. Verified exact for (10,4) |
| `rand` vs `randn` | **Two independent MT states**, both seeded identically by `rng(seed)`, advancing separately. 5000 draws of one do not perturb the other; results are order-independent |
| `randn` algorithm | Not polar, not Box–Muller (four candidates tested, all differ). Consumes one double per deviate in the sampled draws → ziggurat-class |
| `randn` seeding | `randn('state', k)` is accepted; `rng(k)` resets both streams |
| Forge `normrnd` / `mvnrnd` | Thin wrappers over `randn` (plus `cholcov` for covariance) |
| Forge statistics licence | **GPL-3.0** |

### Call-site arithmetic

1060 stochastic call sites across `MTO/`, of which 10 are seeding (`rng`) and 5 are the
deterministic `mvnpdf` density evaluation, leaving **1045 actual draws**:

| Family | Sites | Share |
| --- | --- | --- |
| `rand` / `randi` / `randperm` / `cauchyrnd` | 937 | ~90% |
| `randn` / `normrnd` / `mvnrnd` | 100 | ~10% |
| `datasample` / `randsample` / `lhsdesign` | 6 | <1% |
| `MgaussRandom` (in excluded code) | 2 | — |

`randi` alone accounts for 492 sites — the single largest primitive. `cauchyrnd` is
`a + b*tan(pi*(rand-0.5))`, so it reduces to `rand`.

This arithmetic is why the decision is cheap to act on: no single primitive dominates the
risk, and the whole `randn` family — the only fiddly part — is a tenth of the surface.

---

## The trap: primitive choice is constrained

Invariant 2 constrains the **derivation methods**, not the raw bit generator. Any generator
is acceptable — PCG64, xoshiro, ChaCha — but the algorithms that turn its output into
`normal`, `integer` and `permutation` must match the reference in **draw count and method**,
or profile parity breaks.

Two concrete cases in this tree:

- **`randi`.** The reference is `floor(imax*rand)+1`, which has negligible bias because the
  uniform is 53-bit. Replacing it with `next_u64() % imax` introduces *more* bias than the
  reference, silently shifting the algorithm's behaviour distribution. Replicate the method.
- **`randn`.** The reference consumes one double per deviate *normally* but a ziggurat
  rejects occasionally, so the count is not a constant. A polar method consumes pairs and
  rejects, which changes the profile — and note that distributional parity (invariant 3)
  would **pass** while profile parity (invariant 2) fails. Only invariant 2 tells you that the
  algorithm is now drawing a different number of times than the reference.

So choose the normal generator deliberately rather than accepting whatever the RNG crate
ships. Getting this wrong produces a port that is distributionally plausible and
semantically different, which is the hardest kind of bug to notice.

---

## Rejected alternatives

Recorded so the question is not reopened.

**Replicating MT19937AR (`rand`, and the derived `randi` / `randperm`).**
Technically easy — roughly 40 lines, and verified bit-exact in a few minutes. Rejected because
it buys only the ability to compare *values*, which injection already provides more sharply,
and because the derived primitives must then also be replicated to keep the profile
meaningful, at which point the work stops being trivial for no gain in bug-finding power.

**An `octave_compat` RNG mode selectable at run time.**
Considered and rejected. It creates a second code path that must be maintained and tested
indefinitely, invites results to be produced in one mode and interpreted in the other, and
reintroduces the exact confusion this document exists to prevent.

**Replicating the ziggurat for `randn`.**
Deferred twice, now rejected. A tenth of the draw sites, a nontrivial table-driven
implementation, and the stream it would match is one that MATLAB does not use anyway.

**Matching MATLAB's shared `rand`/`randn` stream.**
Impossible to validate here (no MATLAB), and unnecessary (see reason 2).

---

## What is accepted as lost

State these plainly rather than discovering them later.

- **No value-level bisecting.** You cannot diff "at draw #4,871 they diverge". You keep
  *localisation* — the draw profile names the generation where the counts first diverge, and a
  fixture stream then pins the operation. Two-step bisect rather than one.
- **No cross-platform seed portability.** A seed does not mean the same thing in the port and
  in Octave or MATLAB. Document this wherever seeds are described, or someone will report
  "seed 42 does not reproduce the paper" as a bug.
- **No bit-comparison against the published dataset.** Distributional comparison only.
  This is consistent with the platform's own methodology — 30 independent runs, medians,
  Friedman and Wilcoxon tests — so it is not a downgrade in how results are reported.
- **Correctness strategy is layered.** Non-RNG logic: exact comparison (invariant 1).
  Draw structure: exact comparison (invariant 2). Stochastic outputs: statistical
  comparison (invariant 3). Anything weaker than that needs a documented reason.

---

## Checklist

When touching anything stochastic:

- [ ] No new global RNG use — all randomness goes through the injected interface.
- [ ] Draw counts unchanged for the affected code path (invariant 2).
- [ ] Any new primitive uses the reference method, not a "better" one.
- [ ] Exact assertions only on deterministic state; never on random values.
- [ ] Any deviation from these four invariants recorded here with a reason.

## See also

- `AGENTS.md` — scope, the blockers, and the editing conventions (notably: preserve RNG
  consumption order, preserve evaluation accounting).
- `interface.md` — where the RNG services sit in the plugin contract.
- `alg_pilot.md`, `prob_pilot.md` — the pilot scope over which invariants 1–3 should hold.
