function openExercise(selector,solution)
%OPENEXERCISE Open a workshop or matching solution by ID or number.
%   openExercise(3) opens exercise 3. openExercise("w03_data",true)
%   opens its solution. Each exercise can be replayed independently.
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
if solution
    source = items(match).Solution;
else
    source = items(match).Source;
end
open(fullfile(project.RootFolder,source));
end
