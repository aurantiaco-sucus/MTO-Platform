function [Y, PS] = mapminmax(varargin)
%MAPMINMAX Octave-compatible row-wise min/max scaling and stateful transforms.
% Supports the call forms used by MToP's Octave-pending algorithms:
%   [Y, PS] = mapminmax(X)
%   Y = mapminmax('apply', X, PS)
%   X = mapminmax('reverse', Y, PS)

if nargin < 1
    error('mapminmax:NotEnoughInputs', 'An input matrix is required.');
end

if ischar(varargin{1})
    operation = lower(varargin{1});
    if nargin ~= 3 || ~isstruct(varargin{3})
        error('mapminmax:InvalidCall', ...
            'Use mapminmax(''apply''|''reverse'', X, PS).');
    end
    X = varargin{2};
    PS = varargin{3};
    switch operation
        case 'apply'
            if size(X, 1) ~= PS.xrows
                error('mapminmax:RowMismatch', ...
                    'Input row count must match the saved settings.');
            end
            Y = bsxfun(@plus, bsxfun(@times, ...
                bsxfun(@minus, X, PS.xmin), PS.gain), PS.ymin);
            Y(PS.no_change, :) = X(PS.no_change, :);
        case 'reverse'
            if size(X, 1) ~= PS.xrows
                error('mapminmax:RowMismatch', ...
                    'Input row count must match the saved settings.');
            end
            Y = bsxfun(@plus, bsxfun(@rdivide, ...
                bsxfun(@minus, X, PS.ymin), PS.gain), PS.xmin);
            Y(PS.no_change, :) = X(PS.no_change, :);
        otherwise
            error('mapminmax:UnknownOperation', ...
                'Supported operations are ''apply'' and ''reverse''.');
    end
    return;
end

if nargin == 1
    ymin = -1;
    ymax = 1;
elseif nargin == 2 && isstruct(varargin{2})
    settings = varargin{2};
    if isfield(settings, 'ymin'), ymin = settings.ymin; else, ymin = -1; end
    if isfield(settings, 'ymax'), ymax = settings.ymax; else, ymax = 1; end
elseif nargin == 3
    ymin = varargin{2};
    ymax = varargin{3};
else
    error('mapminmax:InvalidCall', ...
        'Use mapminmax(X), mapminmax(X,YMIN,YMAX), or mapminmax(X,FP).');
end

if ~isnumeric(varargin{1}) || ~ismatrix(varargin{1})
    error('mapminmax:InvalidInput', 'X must be a numeric matrix.');
end
if ~isscalar(ymin) || ~isscalar(ymax) || ~isnumeric(ymin) || ~isnumeric(ymax)
    error('mapminmax:InvalidRange', 'YMIN and YMAX must be numeric scalars.');
end

X = varargin{1};
rowCount = size(X, 1);
PS = struct();
PS.name = 'mapminmax';
PS.xrows = rowCount;
PS.xmin = min(X, [], 2);
PS.xmax = max(X, [], 2);
PS.xrange = PS.xmax - PS.xmin;
PS.ymin = repmat(ymin, rowCount, 1);
PS.ymax = repmat(ymax, rowCount, 1);
PS.yrange = PS.ymax - PS.ymin;
PS.no_change = (PS.xrange == 0) | ~isfinite(PS.xmin) | ~isfinite(PS.xmax);
if ~isempty(X)
    PS.no_change = PS.no_change | ~all(isfinite(X), 2);
end
PS.gain = ones(rowCount, 1);
PS.gain(~PS.no_change) = PS.yrange(~PS.no_change) ./ PS.xrange(~PS.no_change);
PS.xoffset = PS.xmin;

Y = bsxfun(@plus, bsxfun(@times, ...
    bsxfun(@minus, X, PS.xmin), PS.gain), PS.ymin);
Y(PS.no_change, :) = X(PS.no_change, :);
end
