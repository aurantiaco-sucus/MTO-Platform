function pop = AppendPop(pop, more)
%APPENDPOP  Horizontal concatenation that tolerates classdef empties.
%
% Octave 11.3 segfaults when two empty arrays of a classdef type are
% concatenated with `[a, b]` (numeric and cell empties are fine). The MToP
% algorithms accumulate per-task subsets into an `Individual_*` array, so a
% task that receives no offspring produces exactly that pair. The quadratic
% source assumed MATLAB, where `[Individual.empty(), Individual.empty()]`
% is simply empty.
%
% Appending an empty subset is a no-op, and an empty accumulator adopts the
% first non-empty subset. The result is identical to `[pop, more]`.

if isempty(more)
    return;
end
if isempty(pop)
    pop = more;
else
    pop = [pop, more];
end
end
