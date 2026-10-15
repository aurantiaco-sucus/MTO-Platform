% Build and exercise the CEC 2017 single-objective MEX pilot without keeping binaries.
% Run from the repository root, or pass this file's absolute path to Octave.

repoRoot = fileparts(fileparts(mfilename('fullpath')));
cd(repoRoot);
addpath(genpath(fullfile(repoRoot, 'MTO')));
pkg load statistics;

buildDir = tempname();
mkdir(buildDir);
cleanup = onCleanup(@() rmdir(buildDir, 's'));
mexPath = fullfile(buildDir, 'cec17_func.mex');
cppPath = fullfile(repoRoot, 'MTO', 'Problems', 'Single-task', 'CEC17-SO', 'cec17_func.cpp');
command = sprintf('mkoctfile --mex -o "%s" "%s"', mexPath, cppPath);
[status, output] = system(command);
assert(status == 0, output);
addpath(buildDir);

% The C++ source opens input_data relative to the directory containing Problems/.
cd(fullfile(repoRoot, 'MTO'));
Prob = CEC17_SO1();
shift = load(fullfile('Problems', 'Single-task', 'CEC17-SO', ...
    'input_data', 'shift_data_1.txt'));
[optimum, constraints] = Prob.evaluate(shift(1:Prob.D), 1);
assert(optimum == 0);
assert(all(constraints == 0));

Prob.N = 4;
Prob.maxFE = 8;
Algo = GA();
rng(3);
Algo.run(Prob);
assert(Algo.FE == 8);

% The many-task suite combines 87 tasks with 10/30/50-D domains.
MaTProb = MaT_CEC17_SO();
MaTProb.N = 4;
MaTProb.maxFE = 696;
MaTProb.setTasks();
MaTAlgo = GA();
rng(41);
MaTAlgo.run(MaTProb);
assert(MaTAlgo.FE == 696);
assert(MaTProb.T == 87);
assert(isequal(MaTProb.D([1, 30, 59]), [10, 30, 50]));

fprintf('CEC17 MEX smokes passed: SO1 optimum=%.17g/FE=%d; MaT FE=%d.\n', ...
    optimum, Algo.FE, MaTAlgo.FE);
