function outcome = runExercise(selector,solution)
%RUNEXERCISE Execute one independent workshop or worked solution.
%   OUTCOME = runExercise(3) runs the starter in its own function workspace.
%   OUTCOME = runExercise(3,true) runs the matching solution. Optional
%   walkthroughs stay labeled separately from checked numerical execution.
arguments
    selector
    solution (1,1) logical = false
end
project = requireTrainingProject;
catalog = jsondecode(fileread(fullfile(project.RootFolder,'exerciseCatalog.json')));
items = catalog.Exercises;
if isnumeric(selector)
    match = find([items.Number] == selector);
else
    match = find(strcmpi(string({items.Id}),string(selector)));
end
assert(numel(match)==1,'ParisSaclay:UnknownExercise', ...
    'Use an exact exercise ID or listed number.');
item = items(match);
if solution
    source = item.Solution;
else
    source = item.Source;
end
outcome = struct('Id',item.Id,'Source',source,'Status','', ...
    'DeclaredMode',item.Mode,'Seconds',0,'Error','', ...
    'Summary','','Evidence',struct());
started = tic;
try
    declared = executeInOwnWorkspace(fullfile(project.RootFolder,source));
    if isempty(declared)
        outcome.Status = 'executed';
    else
        outcome.Status = char(declared.Status);
        outcome.Summary = char(declared.Summary);
        outcome.Evidence = declared.Evidence;
    end
catch exception
    outcome.Status = 'failed';
    outcome.Error = getReport(exception,'extended','hyperlinks','off');
end
outcome.Seconds = toc(started);
end

function declared = executeInOwnWorkspace(source)
run(source);
if exist('demoOutcome','var') == 1
    declared = demoOutcome;
else
    declared = struct([]);
end
end
