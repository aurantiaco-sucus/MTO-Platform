function counts = HistCount(values, centers)
%HISTCOUNT  hist() that keeps MATLAB's shape for an empty sample.
%
% Octave 11's hist(x, centers) returns numel(centers)-by-0 when x is empty,
% whereas MATLAB returns a 1-by-numel(centers) zero row. The MToP call sites
% add the result to a one-row strategy record, so the Octave shape errors:
%   CCEF_ECHT.m:199, CEDE_DRL.m:260, VMCH.m:229, LSHADE44.m:108,
%   MOMFEA_SADE.m:84/88, MFEA_AKT.m:95, NSGA_III.m:144.
% Those sites legitimately produce an empty sample when no individual was
% selected or no strategy succeeded; the count is then all zeros.
%
% The non-empty path is the built-in hist, so bin edges and counts are
% unchanged.

if isempty(values)
    counts = zeros(1, numel(centers));
else
    counts = hist(values, centers);
end
end
