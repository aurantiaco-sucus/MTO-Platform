function octave_problem_catalog_run(repoRoot)
% Instantiate every Problem class, evaluate one in-bounds candidate per task,
% and explicitly account for the catalog's excluded classes.

files = collectMFiles(fullfile(repoRoot, 'MTO', 'Problems'));
names = {};
paths = {};
for i = 1:numel(files)
    fid = fopen(files{i}, 'rb');
    bytes = fread(fid, 1024, '*uint8');
    fclose(fid);
    % Four legacy files contain non-UTF-8 comments. The class declaration is
    % ASCII, so sanitize only the short header used by this static audit.
    bytes(bytes > 127) = uint8(32);
    header = char(bytes(:))';
    token = regexp(header, ...
        'classdef[[:space:]]+([A-Za-z][A-Za-z0-9_]*)[[:space:]]*<[[:space:]]*Problem', ...
        'tokens', 'once');
    if isempty(token)
        token = regexp(header, ...
            'classdef[[:space:]]+\([^\n]*\)[[:space:]]+([A-Za-z][A-Za-z0-9_]*)[[:space:]]*<[[:space:]]*Problem', ...
            'tokens', 'once');
    end
    if ~isempty(token)
        names{end + 1} = token{1}; %#ok<AGROW>
        paths{end + 1} = files{i}; %#ok<AGROW>
    end
end
assert(numel(names) == 435, 'Expected 435 Problem classes, found %d.', numel(names));

excluded = false(1, numel(names));
for i = 1:numel(paths)
    path = strrep(paths{i}, '\\', '/');
    excluded(i) = ~isempty(strfind(path, '/Optimal Power Flow/')) || ...
        ~isempty(strfind(path, '/Multiobjective Optimal Power Flow/')) || ...
        ~isempty(strfind(path, '/Competitive Multiobjective Optimal Power Flow/')) || ...
        ~isempty(strfind(path, '/Global Trajectory Optimization/')) || ...
        ~isempty(strfind(path, '/Policy Search/'));
end

passed = 0;
skipped = 0;
failures = {};
for i = 1:numel(names)
    name = names{i};
    if excluded(i)
        skipped = skipped + 1;
        try
            feval(name);
            fprintf('SKIP %-32s excluded constructor OK\n', name);
        catch err
            fprintf('SKIP %-32s excluded constructor: %s\n', name, err.message);
        end
        continue;
    end

    try
        Prob = feval(name);
        Prob.setTasks();
        assert(~isempty(Prob.T) && Prob.T >= 1, 'empty task count');
        assert(numel(Prob.D) >= Prob.T, 'dimension metadata incomplete');
        for t = 1:Prob.T
            D = Prob.D(t);
            assert(isfinite(D) && D >= 1, 'invalid dimension');
            x = 0.5 * ones(1, D);
            [Obj, Con] = Prob.evaluate(x, t);
            assert(size(Obj, 1) == 1, 'objective row count mismatch');
            assert(size(Con, 1) == 1, 'constraint row count mismatch');
            assert(~any(isnan(Obj(:))), 'objective returned NaN');
        end
        passed = passed + 1;
        fprintf('PASS %-32s T=%d\n', name, Prob.T);
    catch err
        failures{end + 1} = sprintf('%s [%s]: %s', name, paths{i}, err.message); %#ok<AGROW>
        fprintf(2, 'FAIL %-32s %s\n', name, err.message);
    end
end

fprintf('Problem catalog: %d passed, %d excluded, %d failed, %d total.\n', ...
    passed, skipped, numel(failures), numel(names));
if ~isempty(failures)
    fprintf(2, '%s\n', failures{:});
    error('Problem catalog smoke failed.');
end
assert(passed == 419 && skipped == 16);
fprintf('All 419 in-scope Problem classes evaluated one candidate on every task.\n');
end

function files = collectMFiles(root)
entries = dir(root);
files = {};
for i = 1:numel(entries)
    name = entries(i).name;
    if strcmp(name, '.') || strcmp(name, '..')
        continue;
    end
    path = fullfile(root, name);
    if entries(i).isdir
        files = [files, collectMFiles(path)]; %#ok<AGROW>
    elseif length(name) >= 2 && strcmp(name(end - 1:end), '.m')
        files{end + 1} = path; %#ok<AGROW>
    end
end
end
