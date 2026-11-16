%[text] # 09 — Integrate the neural virtual sensor in Simulink
%[text] **Goal:** Export inspectable layer blocks and compare MATLAB and model execution.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: Simulink; Deep Learning Toolbox. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(9). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Open the generated model, identify normalization and neural layers, then explain the input shape and sample time. Compare output against the MATLAB network on the same sensor trace.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Before opening the solution:** Record your parameter change, observed result, and engineering conclusion.
project = requireTrainingProject;
%%
%[text] ## Export a model from the network
%[text] ensureSOCModel uses exportNetworkToSimulink and keeps generated artifacts in this project. The output is an actual layer-block model, rather than a screenshot or a conceptual diagram.
modelFile = ensureSOCModel;
open_system(modelFile);
modelName = 'BatterySOCEstimator';
%%
%[text] ## Provide a small sensor trace
%[text] The external input is a Dataset with three-element sensor samples. SimulationInput overrides avoid changing saved model settings. Inspect port dimensions if an input shape mismatch is reported.
data = makeBatteryData(42,20);
time = (0:19)';
sensorSamples = [data.voltage,data.current,data.temperature];
inputs = Simulink.SimulationData.Dataset;
inputs = inputs.addElement(timeseries(sensorSamples,time),'sensors');
simulation = Simulink.SimulationInput(modelName);
simulation = simulation.setExternalInput(inputs);
simulation = simulation.setModelParameter('StopTime','19','SaveOutput','on','OutputSaveName','yout','SaveFormat','Dataset');
result = sim(simulation);
estimatedSOC = result.yout{1}.Values.Data;
modelRMSE = sqrt(mean((double(squeeze(estimatedSOC))-data.soc).^2))
assert(modelRMSE<0.03);
%%
%[text] ## Compare to the requirement
%[text] Do not confuse functional integration with code generation or hardware timing. Inspect the time and output dimensions before scoring.
disp("Inspect output dimensions, sample timing and held-out sensor domain before assigning a system-level pass.");
%%
%[text] ## UI screenshot guide
%[text] Screenshots below are from the instructor's original 2025 materials. They explain the interface and links; they are not current R2026b execution results. Use the exercise's own generated artifacts for current evidence.
%%
%[text] ## Original system-level SOC model
%[text] Static screenshot displayed inline for this teaching document; consult the provenance note above.
image(imread(fullfile(project.RootFolder,'assets','screenshots','simulink_model_legacy.png')));
axis image off;
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`exportNetworkToSimulink`](https://www.mathworks.com/help/deeplearning/ref/dlnetwork.exportnetworktosimulink.html) | exportNetworkToSimulink(net,ModelName=...)  | Generate neural layer blocks |
%[text] | [`SimulationInput`](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.html) | Simulink.SimulationInput(model) | Non-destructive overrides |
%[text] | [`setExternalInput`](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setexternalinput.html) | simulation.setExternalInput(dataset) | Supply sensor trace |
%[text] | [`sim`](https://www.mathworks.com/help/simulink/slref/sim.html) | sim(simulation) | Execute model |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
