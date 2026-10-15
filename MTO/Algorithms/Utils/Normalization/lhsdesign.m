function X = lhsdesign(n, p)
%LHSDESIGN Targeted smooth maximin Latin-hypercube initializer for MToP.
% Supports the repository call form lhsdesign(n,p). It follows the documented
% default design logic (jittered strata and maximin selection) with a pinned
% Octave draw profile; it does not reproduce MATLAB's private implementation.

validateattributes(n, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
validateattributes(p, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});

% Use one initial design and five fixed improvement candidates. Always evaluate
% all six so draw consumption does not depend on candidate quality.
X = make_candidate(n, p);
best_score = min_squared_distance(X);
for candidate = 1:5
    trial = make_candidate(n, p);
    score = min_squared_distance(trial);
    if score > best_score
        X = trial;
        best_score = score;
    end
end
end

function X = make_candidate(n, p)
% For each dimension: permute the strata, then draw one uniform jitter per row.
X = zeros(n, p);
for j = 1:p
    stratum = randperm(n)';
    jitter = rand(n, 1);
    X(:, j) = (stratum - 1 + jitter) ./ n;
end
end

function score = min_squared_distance(X)
% Maximin criterion: maximize the smallest squared Euclidean point distance.
n = size(X, 1);
if n < 2
    score = inf;
    return;
end
score = inf;
for i = 1:n-1
    delta = bsxfun(@minus, X(i+1:n, :), X(i, :));
    distance_squared = sum(delta .* delta, 2);
    score = min(score, min(distance_squared));
end
end
