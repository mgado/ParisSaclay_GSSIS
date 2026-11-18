%[text] # 25 — Verify the real SOC neural code with SIL
%[text] **Goal:** Execute generated C++ neural code on the host and compare it with MATLAB. SIL is a separate verification level; a normal MATLAB prediction or ordinary MEX alone is not labeled SIL.
%[text] **Prerequisites:** Open the training Project in R2026b; MATLAB Coder, Embedded Coder, Deep Learning Toolbox and a selected C++ compiler. The pretrained projected SOC network and measured test trace are included. No physical board is needed.
%[text] **Launch:** openExercise(25), then Run Section. The script creates an actual VerificationMode=SIL library and its generated gateway.
%[text] **Your task:** Compare the same32-sample input in MATLAB and SIL, then change traceOffset and repeat using the cached gateway. Explain what SIL checks and what still requires PIL.
%[text] **Hint:** Keep time-by-feature single input, with Temperature, Voltage, Current columns. The network output is scaled SOC; do not compare it directly with the de-scaled Simulink output.
%[text] **Worked reasoning:** Before reading the solution, record shape, units, maximum error and which processor executed the code.
project = requireTrainingProject;
sampleCount = 32;
traceOffset = 1;
tolerance = 1e-4;
%%
%[text] ## Step1: Load the same model and test input
%[text] Use the included pretrained projected SOC network for this neural-code comparison. Use the same input contract for MATLAB, SIL and later PIL.
dataFolder = fullfile(project.RootFolder,'assets','pil_pi_soc','data');
modelFile = char(fullfile(dataFolder,'projected_net.mat'));
data = load(fullfile(dataFolder,'test_data_scaled.mat'),'XTest_scaled');
rows = traceOffset:traceOffset+sampleCount-1;
assert(rows(end)<=size(data.XTest_scaled,1));
input = single(data.XTest_scaled(rows,:));
matlabOutput = predictPiSOC(modelFile,input);
assert(numel(matlabOutput)==sampleCount && all(isfinite(matlabOutput),'all'));
%%
%[text] ## Step2: Generate the actual SIL interface
%[text] VerificationMode=SIL selects host execution of the generated library through the SIL interface. The constant model path fixes the network for compilation. Inspect predictPiSOC.m: its two essential APIs are coder.loadDeepLearningNetwork and predict.
buildFolder = fullfile(project.RootFolder,'generated','codegen','soc_sil');
if ~isfolder(buildFolder), mkdir(buildFolder); end
configuration = coder.config('lib','ecoder',true);
configuration.TargetLang = 'C++';
configuration.DeepLearningConfig = coder.DeepLearningConfig('none');
configuration.VerificationMode = 'SIL';
codegen('-config',configuration,'predictPiSOC','-args',{coder.Constant(modelFile),input},'-d',buildFolder);
gatewayFolder = fullfile(buildFolder,'sil');
addPath(project,gatewayFolder);
%%
%[text] ## Step3: Run generated code and compare numerics
%[text] The gateway runs generated code. Verify output count and finite values before calculating the numerical difference. The elapsed call time includes SIL-interface overhead and is not a target-board latency.
started = tic;
silOutput = predictPiSOC_sil(modelFile,input);
silSeconds = toc(started);
maximumDifference = max(abs(double(silOutput)-double(matlabOutput)),[],'all')
assert(numel(silOutput)==sampleCount && all(isfinite(silOutput),'all'));
assert(maximumDifference<=tolerance);
silEvidence = struct('SILExecuted',true,'Samples',sampleCount,'MaximumDifference',maximumDifference,'GatewaySeconds',silSeconds)
%%
%[text] ## Step4: Change inputs without changing the algorithm
%[text] Change traceOffset and rerun input preparation/comparison with the same fixed-size input. A new model architecture, data type or compile-time model path requires a new build. SIL cannot prove on-target memory, processor timing, IO behavior or HIL behavior.
secondRows = 101:100+sampleCount;
secondInput = single(data.XTest_scaled(secondRows,:));
secondReference = predictPiSOC(modelFile,secondInput);
secondGenerated = predictPiSOC_sil(modelFile,secondInput);
secondDifference = max(abs(double(secondReference)-double(secondGenerated)),[],'all')
assert(secondDifference<=tolerance);
%%
%[text] ## Troubleshooting
%[text] Missing compiler/library is a prerequisite failure, not SIL success. If the gateway is absent, inspect the codegen diagnostic and actual generated folder. If input shape changed, rebuild with the intended fixed type. At the Command Window, use clear predictPiSOC\_sil to release only this generated gateway's owned application.
%%
%[text] ## Documentation and further reading
%[text] [Main SIL/PIL workflow](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html), [MATLAB code verification](https://www.mathworks.com/help/ecoder/verification-testing-and-calibration.html).
%%
%[text] ## Cheat sheet: APIs to remember
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text] Project setup uses [requireTrainingProject](../src/requireTrainingProject.m), a training helper using MATLAB Project APIs.
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [coder.config](https://www.mathworks.com/help/coder/ref/coder.config.html) | coder.config('lib','ecoder',true) | Embedded library configuration | MATLAB Coder + Embedded Coder |
%[text] | [codegen](https://www.mathworks.com/help/coder/ref/codegen.html) | codegen(...,'-args',types) | Build actual SIL interface | MATLAB Coder + Embedded Coder |
%[text] | [coder.Constant](https://www.mathworks.com/help/coder/ref/coder.constant-class.html) | coder.Constant(modelFile) | Compile-time model contract | MATLAB Coder |
%[text] | [predict](https://www.mathworks.com/help/deeplearning/ref/dlnetwork.predict.html) | predict(net,input) | MATLAB neural reference | Deep Learning Toolbox |
%[text] | [max](https://www.mathworks.com/help/matlab/ref/double.max.html) | max(abs(error),[],'all') | Numerical equivalence evidence | MATLAB |
%[text] | [`predictPiSOC`](../src/predictPiSOC.m) | `predictPiSOC(networkFile,input)` | Load and run the provided neural code-generation entry point | Training helper (MATLAB Coder + Deep Learning Toolbox) |
%[text] | [`predictPiSOC_sil`](https://www.mathworks.com/help/coder/ref/codegen.html) | `predictPiSOC_sil(modelFile,input)` | Execute the generated host neural SIL interface | Generated SIL interface (MATLAB Coder + Embedded Coder) |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
