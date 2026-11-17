%[text] # Solution 20 — Run the battery AI on a Raspberry Pi with PIL
%[text] **Goal:** Prototype from MATLAB/Simulink, execute the same projected SOC network on a supported board, and compare its output with the host model. PIL is a primary learning outcome: the support package handles the target build and communication so you can focus on engineering behavior.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in R2026b; Simulink, Embedded Coder, Deep Learning Toolbox, Fixed-Point Designer and Raspberry Pi Blockset. Complete Hardware Setup for a powered Raspberry Pi with a supported OS matching the model's 32/64-bit target. No board connection or deployment runs until you enable the flags below.
%[text] **Launch:** openExercise(20,true), then use Run Section. This lesson uses the included pretrained network and measured battery data. No training run or external folder is needed.
%[text] **Main documentation:** [SIL/PIL workflow](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html), [configure a SIL/PIL simulation](https://www.mathworks.com/help/ecoder/ug/configuring-a-sil-or-pil-simulation.html), [Raspberry Pi support](https://www.mathworks.com/hardware-support/raspberry-pi-simulink.html).
%[text] **Worked reasoning:** Use the same finite measured trace and reset model state for MIL and PIL. A passing target comparison demonstrates code-port correctness for these inputs, not all physical operating conditions. The first build deploys code; a cached repeat shows the prototyping benefit. Keep the declared tolerance and label unavailable hardware honestly.
%[text] **Hint:** The matched network expects Temperature, Voltage, Current in that order. The measured XTest columns have that same order. A connected board object is not proof of PIL; only the actual PIL simulation and numerical comparison count.
project = requireTrainingProject;
runMIL = true;
runPIL = false;
piAddress = ''; % Enter this board's current IPv4 address before enabling PIL.
targetHardwareName = 'Raspberry Pi'; % Match the configured 32/64-bit target.
runRepeatedPIL = false;
sampleCount = 32;
traceOffset = 1;
equivalenceTolerance = 1e-4;
demoOutcome = struct('Status','unavailable','Summary','PIL unavailable until a network-connected Raspberry Pi is configured.','Evidence',struct('PILExecuted',false));
%%
%[text] ## Step 1: Open the real pretrained SOC model
%[text] The wrapper supplies Temperature, Voltage and Current to the projected neural estimator and captures its SOC output. The model uses ERT and generic C; its hardware architecture must match your board's OS.
modelFolder = fullfile(project.RootFolder,'assets','pil_pi_soc','models');
dataFolder = fullfile(project.RootFolder,'assets','pil_pi_soc','data');
addPath(project,modelFolder);
addPath(project,dataFolder);
modelFile = fullfile(modelFolder,'SoC_Target.slx');
if bdIsLoaded('SoC_Target') && ~strcmp(get_param('SoC_Target','FileName'),modelFile)
    error('ParisSaclay:PILModelNameInUse','A different SoC_Target model is open; preserve it and resolve the name before this exercise.');
end
open_system(modelFile);
modelName = 'SoC_Target';
referenceBlock = Simulink.ID.getFullName('SoC_Target:1');
%%
%[text] ## Step 2: Supply a short measured sensor trace
%[text] The included measured trace is shortened for a finite classroom test. The independent PIL question is whether generated target code reproduces MIL; accuracy against physical SOC is a separate requirement and must consider network state/warm-up.
data = load(fullfile(dataFolder,'test_data_scaled.mat'),'XTest','YTest');
networkData = load(fullfile(dataFolder,'projected_net.mat'),'socNetProjected');
scalers = load(fullfile(dataFolder,'scalers.mat'));
rows = traceOffset:traceOffset+sampleCount-1;
assert(rows(end)<=size(data.XTest,1));
time = (0:sampleCount-1)';
simulation = Simulink.SimulationInput(modelName);
simulation = simulation.setVariable('socNetProjected',networkData.socNetProjected);
simulation = simulation.setVariable('biasIn',scalers.biasIn);
simulation = simulation.setVariable('biasOut',scalers.biasOut);
simulation = simulation.setVariable('scalerIn',scalers.scalerIn);
simulation = simulation.setVariable('scalerOut',scalers.scalerOut);
simulation = simulation.setVariable('ts',1);
simulation = simulation.setBlockParameter(referenceBlock,'ModelName','PiSOCAIReference');
simulation = simulation.setVariable('voltage',timeseries(data.XTest(rows,2),time));
simulation = simulation.setVariable('temperature',timeseries(data.XTest(rows,1),time));
simulation = simulation.setVariable('current',timeseries(data.XTest(rows,3),time));
simulation = simulation.setModelParameter('StopTime',num2str(sampleCount-1),'SaveOutput','on','SaveFormat','Dataset','OutputSaveName','yout');
%%
%[text] ## Step 3: Establish the MIL reference
%[text] MIL runs the copied model on the host. It is useful reference evidence but cannot be labeled PIL. The model reference SID is resolved with the public Simulink ID API instead of guessing a block path.
if runMIL || runPIL
    milInput = simulation.setBlockParameter(referenceBlock,'SimulationMode','Normal');
    milOutput = sim(milInput);
    milValues = reshape(double(milOutput.yout{1}.Values.Data),[],1);
    assert(numel(milValues)==sampleCount && all(isfinite(milValues)));
    milReference = table(time,milValues,data.YTest(rows),VariableNames={'Seconds','MIL_SOC','Measured_SOC'})
    demoOutcome.Evidence.MILExecuted = true;
    demoOutcome.Evidence.Samples = sampleCount;
end
%%
%[text] ## Step 4: Connect and run on the processor
%[text] After verifying a supported OS and matching target architecture, use the public coder.hardware credential context for direct SSH PIL. It is shared with Simulink; no raspi I/O-server object is constructed. Set only the current nonsecret address in the model at runtime, and obtain credentials from the MATLAB Vault. Selecting PIL without executing sim does not establish on-target evidence.
if runPIL
    try
        assert(~isempty(piAddress),'Enter the current Pi IPv4 address in piAddress.');
        assert(isSecret('TrainingPiUserName') && isSecret('TrainingPiPassword'),'Store private credentials in the MATLAB Vault first.');
        pilHardware = coder.hardware(targetHardwareName);
        pilHardware.DeviceAddress = piAddress;
        pilHardware.Username = getSecret('TrainingPiUserName');
        pilHardware.Password = getSecret('TrainingPiPassword');
        assert(strcmp(get_param('PiSOCAIReference','HardwareBoard'),targetHardwareName),'Model target must match the board OS architecture.');
        codertarget.data.setParameterValue('PiSOCAIReference','BoardParameters.DeviceAddress',piAddress);
        boardName = targetHardwareName;
        pilInput = simulation.setBlockParameter(referenceBlock,'SimulationMode','Processor-in-the-loop (PIL)');
        started = tic;
        pilOutput = sim(pilInput);
        endToEndSeconds = toc(started);
        pilValues = reshape(double(pilOutput.yout{1}.Values.Data),[],1);
        assert(numel(pilValues)==sampleCount && all(isfinite(pilValues)));
        maximumDifference = max(abs(pilValues-milValues))
        assert(maximumDifference<=equivalenceTolerance);
        demoOutcome = struct('Status','passed','Summary','Actual Raspberry Pi PIL agrees with MIL.','Evidence',struct('PILExecuted',true,'Board',boardName,'Samples',sampleCount,'MaximumDifference',maximumDifference,'EndToEndSeconds',endToEndSeconds));
    catch exception
        demoOutcome = struct('Status','failed','Summary',exception.message,'Evidence',struct('PILExecuted',false,'ErrorIdentifier',exception.identifier));
        rethrow(exception);
    end
end
%%
%[text] ## Step 5: Repeat without changing generated code
%[text] Enable repeated PIL only after the first run passes. Its elapsed time still includes host/target communication and simulation overhead. Do not divide it by 32 and call it pure inference latency; use execution profiling for that separate metric.
if runPIL && runRepeatedPIL
    started = tic;
    repeatedOutput = sim(pilInput);
    repeatedEndToEndSeconds = toc(started)
    repeatedValues = reshape(double(repeatedOutput.yout{1}.Values.Data),[],1);
    assert(max(abs(repeatedValues-milValues))<=equivalenceTolerance);
end
demoOutcome
%%
%[text] ## UI guide and troubleshooting
%[text] Open the Model block's Simulation Mode setting and compare Normal, SIL and PIL. In Configuration Parameters, inspect the Raspberry Pi hardware target. The legacy screenshot below is interface guidance, not proof that this Raspberry Pi run executed.
image(imread(fullfile(project.RootFolder,'assets','screenshots','pil_workflow.png')));
axis image off;
%[text] If no board is ready, retain demoOutcome as unavailable. If MIL fails, inspect the copied dictionaries, input order and numeric types first. If target compilation fails, check the guided Hardware Setup, supported 64-bit OS, compiler/libraries and board connection; keep the actual error. Do not replace a failed PIL run with a host result.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal syntax | Purpose |
%[text] | --- | --- | --- |
%[text] | [coder.hardware](https://www.mathworks.com/help/coder/ref/coder.hardware.html) | coder.hardware(targetHardwareName) | Shared direct SSH PIL credential context |
%[text] | [open_system](https://www.mathworks.com/help/simulink/slref/open_system.html) | `open_system(modelFile)` | Inspect the copied model |
%[text] | [load](https://www.mathworks.com/help/matlab/ref/load.html) | `load(file,'XTest','YTest')` | Load measured sensor data |
%[text] | [timeseries](https://www.mathworks.com/help/matlab/ref/timeseries.html) | `timeseries(sensor,time)` | Time-align sensor inputs |
%[text] | [SimulationInput](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.html) | `Simulink.SimulationInput(model)` | Own the simulation overrides |
%[text] | [setVariable](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setvariable.html) | `simulation.setVariable(name,value)` | Supply model inputs |
%[text] | [setBlockParameter](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setblockparameter.html) | `simulation.setBlockParameter(block,'SimulationMode',mode)` | Switch the same model among MIL/SIL/PIL |
%[text] | [sim](https://www.mathworks.com/help/simulink/slref/sim.html) | `sim(pilInput)` | Execute the actual target simulation |
%[text] | [assert](https://www.mathworks.com/help/matlab/ref/assert.html) | `assert(error<=tolerance)` | Require actual numerical agreement |
%[text] | [SIL/PIL workflow](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html) | Read before configuring the target | Distinguish host and processor evidence |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
