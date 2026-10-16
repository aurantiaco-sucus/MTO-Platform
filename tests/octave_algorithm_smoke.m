% Runtime smoke sweep of every in-scope algorithm class.
% Run from the repository root, or pass this file's absolute path to Octave:
%   octave --norc -q tests/octave_algorithm_smoke.m

repoRoot = fileparts(fileparts(mfilename('fullpath')));
cd(repoRoot);
addpath(genpath(fullfile(repoRoot, 'MTO')));
addpath(fullfile(repoRoot, 'tests'), '-begin');
pkg load statistics;

% Keep these lists aligned with the IN rows in alg.md. Fixture dimensions and
% budgets are selected for a short representative run, not benchmark parity.
SO = {'C2oDE', 'CAL_SHADE', 'CCEF_ECHT', 'CEDE_DRL', 'CORCO', 'DeCODE', ...
    'ECHT', 'FROFI', 'MTV_DE', 'VMCH', 'DE', 'JADE', 'L_SHADE', 'LSHADE44', ...
    'NL_SHADE_RSP', 'SHADE', 'SaDE', 'jDE', 'jSO', 'rank_DE', 'rank_jDE', ...
    'EDAver', 'CMA_ES', 'DES', 'IPOP_CMA_ES', 'OpenAI_ES', 'R1_NES', 'SNES', ...
    'sep_CMA_ES', 'xNES', 'xNES_as', 'GA', 'Global_GA', 'AO', 'CSO', 'EO', ...
    'MPA', 'PSO'};
MTSO = {'DEORA', 'DEORA_MTDE', 'MTSRA', 'CEDA_MF', 'CEDA_MP', 'CMO_LKT', ...
    'BoKTDE', 'BoKTGA', 'DTSKT', 'EMaTO_MKT', 'KR_MTEA', 'MES_RET', ...
    'sep_MES_RET', 'MaTDE', 'SBCMAES', 'SBGA', 'sep_SBCMAES', 'TNG_SNES', ...
    'TNG_SNES_EP', 'TNG_xNES', 'TRADE', 'ASCMFDE', 'AT_MFEA', 'EMTO_AI', ...
    'G_MFEA', 'LDA_MFEA', 'MFDE', 'MFEA', 'MFEA_AKT', 'MFEA_DGD', 'MFEA_DV', ...
    'MFEA_GHS', 'MFEA_II', 'MFPSO', 'SREMTO', 'TLTLA', 'BLKT_DE', 'EMEA', ...
    'IMEA', 'MFMP', 'MKTDE', 'MTDE_ADKT', 'MTEA_AD', 'MTEA_HKTS', 'MTEA_PAE', ...
    'MTEA_SaO', 'MTES', 'MTES_KG', 'sep_MTES_KG', 'SSLT_DE', 'SSLT_GA'};
MOSO = {'CCMO', 'CMOCSO', 'AR_MOEA', 'MOEA_D', 'MOEA_D_DE', 'RVEA', ...
    'SMS_EMOA', 'LMOCSO', 'MO_CMA_ES', 'MSEA', 'NSGA_II', 'NSGA_II_DE', ...
    'NSGA_III', 'SPEA2', 'SPEA2_DE'};
MTMO = {'RVC_MTEA', 'MO_EMaTO_MKT', 'MO_MaTDE', 'MO_SBO', 'EMT_PD', ...
    'MO_MFEA', 'MO_MFEA_II', 'AMT_NSGA_II', 'EMT_ET', 'EMT_MSKT', 'MM_DE', ...
    'MMTO_ETA', 'MO_EMEA', 'MO_MTEA_PAE', 'MO_MTEA_SaO', 'MOMFEA_SADE', ...
    'MTDE_MKTA', 'MTEA_D_DN', 'MTEA_D_TSD', 'MTEA_DCK'};
STREAM = {'AAEMTO', 'ABoKTDE', 'AEMEA', 'AMFEA', 'AMTEA_AD', ...
    'AMTEA_SaO', 'AMaTDE', 'ATNG_SNES', 'KR_AMTEA'};

allNames = [SO, MTSO, MOSO, MTMO, STREAM];
assert(numel(SO) == 38 && numel(MTSO) == 51 && numel(MOSO) == 15 && ...
    numel(MTMO) == 20 && numel(STREAM) == 9);
assert(numel(unique(allNames)) == 133);

% Fail if this runner drifts from the maintained IN catalog in alg.md.
inventoryText = fileread(fullfile(repoRoot, 'alg.md'));
inventoryLines = strsplit(inventoryText, '\n');
tick = char(96);
pattern = ['^\| ', tick, '([A-Za-z0-9_]+)', tick, ' \|.*\| IN \|$'];
inventoryNames = {};
for i = 1:numel(inventoryLines)
    inventoryToken = regexp(inventoryLines{i}, pattern, 'tokens', 'once');
    if ~isempty(inventoryToken)
        inventoryNames{end + 1} = inventoryToken{1}; %#ok<AGROW>
    end
end
assert(isequal(sort(allNames), sort(inventoryNames)), ...
    'Smoke class lists must match the IN classes in alg.md.');

failures = {};
passed = 0;
fixtures = {{SO, 'so'}, {MTSO, 'mtso'}, {MOSO, 'moso'}, ...
    {MTMO, 'mtmo'}, {STREAM, 'stream'}};
for group = 1:numel(fixtures)
    names = fixtures{group}{1};
    family = fixtures{group}{2};
    for i = 1:numel(names)
        name = names{i};
        try
            fe = octave_algorithm_smoke_case(name, family);
            passed = passed + 1;
            fprintf('PASS %-16s family=%-6s FE=%g\n', name, family, fe);
        catch err
            failures{end + 1} = sprintf('%s: %s', name, err.message); %#ok<AGROW>
            fprintf(2, 'FAIL %-16s family=%-6s %s\n', name, family, err.message);
        end
    end
end

fprintf('Algorithm runtime smoke: %d passed, %d failed, %d total.\n', ...
    passed, numel(failures), passed + numel(failures));
if ~isempty(failures)
    fprintf(2, '%s\n', failures{:});
    error('Octave algorithm smoke sweep failed.');
end
assert(passed == 133);
fprintf('All 133 in-scope algorithm classes completed their smoke run.\n');
