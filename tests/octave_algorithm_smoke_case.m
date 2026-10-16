function FE = octave_algorithm_smoke_case(name, family)
% Build a small family-appropriate problem, run one algorithm, return FE.
% The budgets intentionally permit whole-generation completion and are not
% asserted equal to maxFE for algorithms that evaluate task batches atomically.
rng(123);

switch family
    case 'so'
        Prob = Func_Sphere();
        Prob.N = 10;
        Prob.maxFE = 20;
        if strcmp(name, 'IPOP_CMA_ES')
            Prob.maxFE = 30;
        end
        Algo = feval(name);

    case 'mtso'
        if strcmp(name, 'DTSKT')
            Prob = twoTaskSphere(10, 40);
        elseif strcmp(name, 'SSLT_GA')
            Prob = CMT1();
            Prob.N = 100;
            Prob.maxFE = 400;
        elseif strcmp(name, 'DEORA')
            Prob = CMT1();
            Prob.N = 10;
            Prob.maxFE = 120;
        elseif any(strcmp(name, {'MaTDE', 'SBCMAES', 'sep_SBCMAES', 'MFPSO'}))
            Prob = CMT1();
            Prob.N = 10;
            Prob.maxFE = 40;
        else
            Prob = twoTaskSphere(10, 40);
        end
        Algo = feval(name);
        if strcmp(name, 'DTSKT')
            % Reduce DTSKT's internal default population to match this fixture.
            Algo.N = 10;
        end

    case 'moso'
        Prob = DTLZ1();
        Prob.N = 10;
        Prob.maxFE = 20;
        if any(strcmp(name, {'MOEA_D', 'MOEA_D_DE'}))
            Prob.N = 20;
            Prob.maxFE = 42;
        elseif strcmp(name, 'NSGA_III')
            Prob.N = 20;
            Prob.maxFE = 40;
        end
        Algo = feval(name);

    case 'mtmo'
        Prob = CEC17_MTMO1_CI_HS();
        Prob.N = 10;
        Prob.maxFE = 40;
        if strcmp(name, 'RVC_MTEA') || strcmp(name, 'MTEA_D_TSD')
            Prob.N = 20;
            Prob.maxFE = 80;
        elseif strcmp(name, 'MOMFEA_SADE')
            Prob.N = 60;
            Prob.maxFE = 240;
        end
        Algo = feval(name);

    case 'stream'
        Prob = AMTSO_Case1_P1();
        Prob.N = 4;
        Prob.maxFE = 24;
        Prob.setTasks();
        Algo = feval(name);
        if strcmp(name, 'AMTEA_AD')
            % Exercise the anomaly-transfer path, including batch extension.
            Algo.TRP = 1;
        end

    otherwise
        error('Unknown smoke family: %s', family);
end

Algo.run(Prob);
FE = Algo.FE;
assert(isfinite(FE) && FE > 0, '%s completed without recording evaluations.', name);
if strcmp(family, 'stream')
    assert(FE == Prob.maxFE, '%s did not consume the configured stream budget.', name);
end
end

function Prob = twoTaskSphere(N, maxFE)
Prob = Func_Sphere();
Prob.T = 2;
Prob.N = N;
Prob.D = [10, 10];
Prob.M = [1, 1];
Prob.maxFE = maxFE;
Prob.Lb = {-100 * ones(1, 10), -100 * ones(1, 10)};
Prob.Ub = {100 * ones(1, 10), 100 * ones(1, 10)};
Prob.Fnc = {@(x) Sphere(x, 1, 0, 0), @(x) Sphere(x, 1, 0, 0)};
end
