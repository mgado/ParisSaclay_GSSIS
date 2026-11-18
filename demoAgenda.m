function catalog = demoAgenda
%DEMOAGENDA List the three-day training exercises and prerequisites.
project = requireTrainingProject;
catalog = jsondecode(fileread(fullfile(project.RootFolder,'exerciseCatalog.json')));
agenda = struct2table(catalog.Exercises);
disp(agenda(:,{'Number','Key','Name','Day','Minutes','Products'}));
end
