function project = requireTrainingProject
%REQUIRETRAININGPROJECT Require the opened ParisSaclay training project.
%   PROJECT = requireTrainingProject returns the current MATLAB Project.
%   Open ParisSaclay_GSSIS.prj before running a workshop.
project = currentProject;
assert(~isempty(project),'ParisSaclay:ProjectClosed', ...
    'Open ParisSaclay_GSSIS.prj before running this exercise.');
assert(isfile(fullfile(project.RootFolder,'exerciseCatalog.json')), ...
    'ParisSaclay:WrongProject','Open the ParisSaclay training project.');
end
