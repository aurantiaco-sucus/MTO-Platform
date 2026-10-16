function compileProblemMex(source, output)
% Compile one self-contained Problem MEX module for the current Octave run.
quotedSource = ['"', strrep(source, '"', '\\"'), '"'];
quotedOutput = ['"', strrep(output, '"', '\\"'), '"'];
command = sprintf('mkoctfile --mex %s -o %s', quotedSource, quotedOutput);
[status, outputText] = system(command);
assert(status == 0, 'MEX build failed for %s:\n%s', source, outputText);
end
