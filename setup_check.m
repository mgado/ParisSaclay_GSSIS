function status = setup_check
%SETUP_CHECK Report installed training capabilities without installing.
%   STATUS = setup_check returns a capability table. Missing optional
%   products are reported as unavailable, never as passing exercises.
project = requireTrainingProject;
names = ["MATLAB";"Deep Learning Toolbox";"Statistics and Machine Learning Toolbox";
    "Simulink";"Requirements Toolbox";"Simulink Test";"MATLAB Coder";
    "Control System Toolbox";"Visual Inspection Toolbox"];
products = ver;
installed = string({products.Name});
available = ismember(names,installed);
status = table(names,available,VariableNames={'Product','Installed'});
disp(status);
disp("Training project: " + string(project.RootFolder));
disp("Release: " + string(version('-release')));
disp("Hardware and agent connection must be checked separately.");
end
