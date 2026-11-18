function openExercise(selector,solution)
%OPENEXERCISE Open a workshop or solution by number, name or legacy ID.
%   openExercise(2) and openExercise("02-Requirements") open exercise 2.
%   openExercise("Requirements",true) opens its worked solution.
%   Existing IDs such as "w02_requirements" remain supported.
%   Type openExercise(" and press Tab to browse the available names.
%   See also demoAgenda, resolveExerciseSelector.
arguments
    selector
    solution (1,1) logical = false
end
project = requireTrainingProject;
item = resolveExerciseSelector(selector);
if solution
    source = item.Solution;
else
    source = item.Source;
end
open(fullfile(project.RootFolder,source));
end
