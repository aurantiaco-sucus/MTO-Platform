% Headless Octave smoke tests. Run from the repository root, or pass this file's
% absolute path to Octave:
%   octave --norc -q tests/octave_smoke.m

repoRoot = fileparts(fileparts(mfilename('fullpath')));
cd(repoRoot);
addpath(genpath(fullfile(repoRoot, 'MTO')));
pkg load statistics;
rng(1);

% Bulk accessors must aggregate every Individual in the array.
pop(1) = Individual();
pop(2) = Individual();
pop(1).Dec = [1, 2];
pop(2).Dec = [3, 4];
pop(1).Obj = 5;
pop(2).Obj = 6;
pop(1).Con = [0, 1];
pop(2).Con = [2, 0];
pop(1).CV = 1;
pop(2).CV = 2;
assert(isequal(Decs(pop), [1, 2; 3, 4]));
assert(isequal(Objs(pop), [5; 6]));
assert(isequal(Cons(pop), [0, 1; 2, 0]));
assert(isequal(CVs(pop), [1; 2]));

% Stateful mapminmax scaling, including constant rows and reverse transforms.
ScaleInput = [1, 2, 4; 1, 1, 1; 3, 2, 2; 0, 0, 0];
[ScaleOutput, ScaleSettings] = mapminmax(ScaleInput);
ScaleExpected = [-1, -1 / 3, 1; 1, 1, 1; 1, -1, -1; 0, 0, 0];
assert(max(abs(ScaleOutput(:) - ScaleExpected(:))) < 1e-12);
assert(isequal(mapminmax('apply', ScaleInput, ScaleSettings), ScaleOutput));
ScaleReverse = mapminmax('reverse', ScaleOutput, ScaleSettings);
assert(max(abs(ScaleReverse(:) - ScaleInput(:))) < 1e-12);
[CustomScale, CustomSettings] = mapminmax([2, 3, 6], struct('ymin', 0, 'ymax', 2));
assert(isequal(CustomScale, [0, 0.5, 2]));
assert(max(abs(mapminmax('reverse', CustomScale, CustomSettings) - [2, 3, 6])) < 1e-12);

% Smooth maximin LHS coverage and its pinned Octave draw profile.
rng(7);
LhsN = 13;
LhsP = 7;
Lhs = lhsdesign(LhsN, LhsP);
assert(all(Lhs(:) >= 0 & Lhs(:) < 1));
for j = 1:LhsP
    assert(isequal(sort(floor(LhsN * Lhs(:, j)) + 1), (1:LhsN)'));
end
rng(9);
lhsdesign(20, 8);
LhsAfter = rng();
rng(9);
for candidate = 1:6
    for j = 1:8
        randperm(20);
        rand(20, 1);
    end
end
assert(isequal(LhsAfter, rng()));

% Base-representation, per-individual DE state, and distribution-based loops.
Prob = Func_Sphere();
Prob.N = 10;
Prob.maxFE = 20;
Algo = GA();
Algo.run(Prob);
assert(Algo.FE == 20);

Prob = Func_Sphere();
Prob.N = 10;
Prob.maxFE = 20;
Algo = jDE();
Algo.run(Prob);
assert(Algo.FE == 20);

Prob = Func_Sphere();
Prob.N = 10;
Prob.maxFE = 20;
Algo = CMA_ES();
Algo.run(Prob);
assert(Algo.FE == 20);

% Additional evolution strategies exercise Octave-safe value-class preallocation.
Prob = Func_Sphere();
Prob.N = 10;
Prob.maxFE = 30;
Algo = IPOP_CMA_ES();
Algo.run(Prob);
assert(Algo.FE == 30);

Prob = Func_Sphere();
Prob.N = 10;
Prob.maxFE = 20;
Algo = OpenAI_ES();
Algo.run(Prob);
assert(Algo.FE == 20);

% Multi-objective sorting and multifactorial initialization/selection.
Prob = DTLZ1();
Prob.N = 10;
Prob.maxFE = 20;
Algo = NSGA_II();
Algo.run(Prob);
assert(Algo.FE == 20);

Prob = CMT1();
Prob.N = 10;
Prob.maxFE = 60;
Algo = MFEA();
Algo.run(Prob);
assert(Algo.FE == 60);

% Competitive problem metadata through its suite-level task generator.
rng(37);
Prob = C2TOP_Case1_P1();
Prob.N = 10;
Prob.maxFE = 40;
Prob.setTasks();
Algo = MFEA();
Algo.run(Prob);
assert(Algo.FE == 40);

% Constrained domain-adaptation path and the CEDA transfer helper.
rng(47);
Prob = CMT1();
Prob.N = 10;
Prob.maxFE = 60;
Algo = CEDA_MP();
Algo.run(Prob);
assert(Algo.FE == 60);

% MFEA-II's online RMP learner (including Forge statistics calls).
rng(17);
Prob = CMT1();
Prob.N = 10;
Prob.maxFE = 60;
Algo = MFEA_II();
Algo.run(Prob);
assert(Algo.FE == 60);

% Many-task archive initialization and shared evolutionary-strategy populations.
for AlgoClass = {@MaTDE, @SBCMAES, @sep_SBCMAES, @MFPSO}
    Prob = CMT1();
    Prob.N = 10;
    Prob.maxFE = 40;
    Algo = AlgoClass{1}();
    Algo.run(Prob);
    assert(Algo.FE >= 40);
end

% Many-task operator parsing uses the Octave-supported string splitter.
Prob = CMT1();
Prob.N = 10;
Prob.maxFE = 40;
Algo = KR_MTEA();
Algo.run(Prob);
assert(Algo.FE >= 40);

% The four-strategy constrained portfolios must tolerate an empty archive update.
for AlgoClass = {@CCEF_ECHT, @CEDE_DRL}
    Prob = Func_Sphere();
    Prob.N = 10;
    Prob.maxFE = 20;
    Algo = AlgoClass{1}();
    Algo.run(Prob);
    assert(Algo.FE == 20);
end

% CORCO's initial diversity state is defined even when its learning phase is skipped.
Prob = Func_Sphere();
Prob.N = 10;
Prob.maxFE = 20;
Algo = CORCO();
Algo.run(Prob);
assert(Algo.FE == 20);

% Many-task clustering and Forge k-means on a synthetic ten-task sphere suite.
rng(23);
Prob = Func_Sphere();
Prob.T = 10;
Prob.N = 10;
Prob.D = 10 * ones(1, 10);
Prob.M = ones(1, 10);
Prob.maxFE = 200;
Prob.Lb = repmat({-100 * ones(1, 10)}, 1, 10);
Prob.Ub = repmat({100 * ones(1, 10)}, 1, 10);
Prob.Fnc = repmat({@(x) Sphere(x, 1, 0, 0)}, 1, 10);
Algo = EMaTO_MKT();
Algo.run(Prob);
assert(Algo.FE == 200);

% LHS-initialized single- and multi-objective PAE algorithms.
rng(51);
Prob = CMT1();
Prob.N = 10;
Prob.maxFE = 200;
Algo = MTEA_PAE();
Algo.TGap = 100;
Algo.run(Prob);
assert(Algo.FE == 200);

rng(53);
Prob = CEC17_MTMO1_CI_HS();
Prob.N = 10;
Prob.maxFE = 200;
Algo = MO_MTEA_PAE();
Algo.TGap = 100;
Algo.run(Prob);
assert(Algo.FE == 200);

% Joint multi-objective / multifactorial selection and sorting.
rng(29);
Prob = CEC17_MTMO1_CI_HS();
Prob.N = 10;
Prob.maxFE = 40;
Algo = MO_MFEA();
Algo.run(Prob);
assert(Algo.FE == 40);

% Many-task archive initialization and cluster-model offspring preallocation.
rng(41);
Prob = CEC17_MTMO1_CI_HS();
Prob.N = 10;
Prob.maxFE = 40;
Algo = MO_MaTDE();
Algo.run(Prob);
assert(Algo.FE == 40);

rng(42);
Prob = CEC17_MTMO1_CI_HS();
Prob.N = 10;
Prob.maxFE = 40;
Algo = MO_EMaTO_MKT();
Algo.run(Prob);
assert(Algo.FE == 40);

% Bulk text data with non-uniform task domains in the CEC19 MaTMO suite.
rng(43);
Prob = CEC19_MaTMO1();
Prob.T = 3;
Prob.setTasks();
Prob.N = 10;
Prob.maxFE = 60;
Algo = MO_MFEA();
Algo.run(Prob);
assert(Algo.FE == 60);

% Self-contained real-world multi-objective constrained tasks.
rng(31);
Prob = SOPM_MTMO1();
Prob.N = 10;
Prob.maxFE = 60;
Algo = MO_MFEA();
Algo.run(Prob);
assert(Algo.FE == 60);

% Constraint handling with ECHT's 2-D individual-array population.
Prob = CEC17_CSO1();
Prob.N = 10;
Prob.maxFE = 90;
Algo = ECHT();
Algo.run(Prob);
assert(Algo.FE == 90);

% Stream lifecycle, staggered arrival, per-task budgets, and a transfer checkpoint.
rng(11);
StreamProb = AMTSO_Case1_P1();
StreamProb.N = 4;
StreamProb.maxFE = 24;
StreamProb.setTasks();
StreamAlgo = AEMEA();
StreamAlgo.TGap = 1;
StreamAlgo.SNum = 2;
StreamAlgo.run(StreamProb);
assert(StreamAlgo.FE == 24);
assert(isequal(StreamAlgo.TaskFE, [12, 12]));

% AMTEA-AD transfer candidates exercise safe extension of a value-class batch.
rng(123);
StreamProb = AMTSO_Case1_P1();
StreamProb.N = 4;
StreamProb.maxFE = 24;
StreamProb.setTasks();
StreamAlgo = AMTEA_AD();
StreamAlgo.TRP = 1;
StreamAlgo.run(StreamProb);
assert(StreamAlgo.FE == 24);
assert(isequal(StreamAlgo.TaskFE, [12, 12]));

% Data-backed multitask problem, from the repository root for relative data paths.
Prob = CEC17_MTSO1_CI_HS();
Prob.maxFE = 2000;
Prob.setTasks();
Algo = GA();
Algo.reset();
Algo.run(Prob);
assert(Algo.FE == 2000);

% Exercise the supported headless command-line runner and saved result schema.
CmdProb = Func_Sphere();
CmdProb.N = 10;
CmdProb.maxFE = 20;
SavePath = [tempname(), '.mat'];
CmdData = MTO_CMD({GA()}, {CmdProb}, 'Reps', 1, 'Par_Flag', false, ...
    'Results_Num', 3, 'Save_Name', SavePath, 'Global_Seed', 1);
assert(numel(CmdData.Results) == 1);
assert(isfield(CmdData.Results, 'Obj') && isfield(CmdData.Results, 'CV'));
assert(size(CmdData.Results.Obj, 2) == 3);
SavedData = load(SavePath, 'MTOData');
assert(isfield(SavedData, 'MTOData'));
delete(SavePath);

% Anonymous problem handles that capture Problem must not recurse during Octave save.
MOProb = DTLZ1();
MOProb.N = 10;
MOProb.maxFE = 20;
MOSavePath = [tempname(), '.mat'];
MOData = MTO_CMD({NSGA_II()}, {MOProb}, 'Reps', 1, 'Par_Flag', false, ...
    'Results_Num', 3, 'Save_Dec', true, 'Save_Name', MOSavePath, 'Global_Seed', 5);
assert(isa(MOData.Problems(1).Fnc{1}, 'function_handle'));
assert(isfield(MOData.Results, 'Dec') && iscell(MOData.Results.Obj));
SavedMOData = load(MOSavePath, 'MTOData');
assert(ischar(SavedMOData.MTOData.Problems(1).Fnc{1}));
assert(isfield(SavedMOData.MTOData.Results, 'Dec'));
delete(MOSavePath);

fprintf('Octave smoke tests passed.\n');
