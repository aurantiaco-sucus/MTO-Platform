% Full Problem-catalog runtime smoke test.
% Run from the repository root, or pass this file's absolute path to Octave:
%   octave --norc -q tests/octave_problem_smoke.m

repoRoot = fileparts(fileparts(mfilename('fullpath')));
mtoRoot = fullfile(repoRoot, 'MTO');
cd(mtoRoot);
addpath(genpath(mtoRoot));
addpath(fileparts(mfilename('fullpath')));
pkg load statistics;

% Build all three in-scope Linux MEX modules into a temporary directory.
mexDir = tempname();
mkdir(mexDir);
mexCleanup = onCleanup(@() rmdir(mexDir, 's')); %#ok<NASGU>
compileProblemMex(fullfile(mtoRoot, 'Problems', 'Multi-task', 'WCCI20-MTSO', ...
    'cec14_func.cpp'), fullfile(mexDir, 'cec14_func.mex'));
compileProblemMex(fullfile(mtoRoot, 'Problems', 'Single-task', 'CEC17-SO', ...
    'cec17_func.cpp'), fullfile(mexDir, 'cec17_func.mex'));
compileProblemMex(fullfile(mtoRoot, 'Problems', 'Single-task', 'CEC22-SO', ...
    'cec22_test_func.cpp'), fullfile(mexDir, 'cec22_test_func.mex'));
addpath(mexDir, '-begin');

octave_problem_catalog_run(repoRoot);
