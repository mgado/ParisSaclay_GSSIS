function modelFile = ensureSOCModel
%ENSURESOCMODEL Create a teachable Simulink layer-block estimator model.
%   MODELFILE = ensureSOCModel exports a compact trained network into a
%   project-owned generated folder. It reuses the model when it exists.
project = requireTrainingProject;
modelFolder = fullfile(project.RootFolder,'generated','models');
if ~isfolder(modelFolder)
    mkdir(modelFolder);
end
addPath(project,modelFolder);
modelFile = fullfile(modelFolder,'BatterySOCEstimator.slx');
if ~isfile(modelFile)
    net = trainSOCNetwork;
    exportNetworkToSimulink(net,ModelName="BatterySOCEstimator", ...
        ModelPath=modelFolder,SampleTime="1", ...
        SaveNetworkInModelWorkspace=true,OpenSystem=false);
end
end
