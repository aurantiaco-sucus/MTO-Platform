function [idx, centers] = KMeansCompat(X, K, varargin)
%KMEANSCOMPAT  kmeans() with Octave's degenerate k-means++ start handled.
%
% Octave 11's statistics-package kmeans uses the 'plus' (k-means++) start by
% default. When the sample contains fewer than K distinct points -- a
% converged EMaTO-MKT population reaching 9 distinct decisions with K = 10 is
% the observed case -- every remaining distance is zero, find() returns empty,
% and the centroid assignment errors with "nonconformant arguments". MATLAB's
% kmeans tolerates that case, filling empty clusters with singleton points.
%
% Fall back to the 'sample' start only when the k-means++ precondition fails.
% 'sample' reaches Octave's empty-cluster handling, so the call still returns
% K populated clusters; for distinct data the default start is untouched.

if nargin < 2
    error('KMeansCompat:NotEnoughInputs', 'X and K are required.');
end
K = round(K);
distinct = size(unique(X, 'rows'), 1);
if distinct < K
    [idx, centers] = kmeans(X, K, varargin{:}, 'Start', 'sample');
else
    [idx, centers] = kmeans(X, K, varargin{:});
end
end
