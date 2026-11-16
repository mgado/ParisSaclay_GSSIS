function catalog = demoAgenda
%DEMOAGENDA List the three-day training exercises and prerequisites.
project = requireTrainingProject;
catalog = jsondecode(fileread(fullfile(project.RootFolder,'exerciseCatalog.json')));
disp(struct2table(catalog.Exercises));
end
