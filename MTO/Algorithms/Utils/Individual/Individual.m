classdef Individual

%------------------------------- Copyright --------------------------------
% Copyright (c) Yanchi Li. You are free to use the MToP for research
% purposes. All publications which use this platform should acknowledge
% the use of MToP and cite as "Y. Li, W. Gong, T. Zhang, F. Ming,
% S. Li, Q. Gu, and Y.-S. Ong, MToP: A MATLAB Benchmarking Platform for
% Evolutionary Multitasking, ACM Trans. Evol. Learn. Optim., 2026"
%--------------------------------------------------------------------------

%% Individual Base Class

properties
    Dec % Decision variables (1xD)
    Obj % Objective values (1xM)
    Con % Constraint values (1xC)
    CV % Constraint violation (1x1)
end

% Invoke these accessors in function form for populations, e.g. Decs(population).
% Octave dot-notation method dispatch on an object array only uses its first element.
methods
    function value = Decs(obj)
        % Return matrix of Decision variables (NxD)
        if isempty(obj)
            value = [];
        else
            % vertcat is the standard optimized concatenation
            value = vertcat(obj.Dec);
        end
    end

    function value = Objs(obj)
        % Return matrix of Objective values (NxM)
        if isempty(obj)
            value = [];
        else
            value = vertcat(obj.Obj);
        end
    end

    function value = Cons(obj)
        % Return matrix of Constraint values (NxC)
        if isempty(obj)
            value = [];
        else
            value = vertcat(obj.Con);
        end
    end

    function value = CVs(obj)
        % Return vector of Constraint Violations (Nx1)
        if isempty(obj)
            value = [];
        else
            % CV is usually a scalar, simple concatenation is fast
            value = [obj.CV]';
        end
    end
end
end
