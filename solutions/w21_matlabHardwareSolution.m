%[text] # Solution 21 — MATLAB command-line AI deployment and PIL
%[text] **Goal:** Use MATLAB APIs to generate and execute the supplied projected battery AI on a Raspberry Pi, then compare real target results with MATLAB. This is the command-line counterpart of the Simulink Model-reference PIL lesson.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj; MATLAB Coder, Embedded Coder, Deep Learning Toolbox, the model-compression library, Fixed-Point Designer, Raspberry Pi Blockset and a configured supported Pi. All target operations are opt-in. The real measured data and pretrained network are included locally.
%[text] **Launch:** openExercise(21,true), then Run Section. First inspect the input/network and host prediction. Enable PIL only after the instructor verifies the board connection, target architecture/toolchain and private credentials.
%[text] **Documentation:** [MATLAB hardware configuration](https://www.mathworks.com/help/coder/ref/coder.hardware.html), [code-generation configuration](https://www.mathworks.com/help/coder/ref/coder.config.html), [main SIL/PIL workflow](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html).
%[text] **Worked reasoning:** Keep the same network, scaled inputs and initial state for host and target. The support package prepares the build/transport, while the numerical assertions decide correctness. A generated library or host prediction is not target evidence. Preserve unavailable/failed status until the actual neural PIL gateway returns and matches.
project = requireTrainingProject;
runHostAI = true;
runPIL = false;
piAddress = ''; % Enter this board's current IPv4 address before enabling PIL.
sampleCount = 32;
traceOffset = 1;
equivalenceTolerance = 1e-4;
demoOutcome = struct('Status','unavailable','Summary','MATLAB AI PIL has not executed; board and code-generation path require rehearsal.','Evidence',struct('PILExecuted',false));
%%
%[text] ## Step 1: Inspect the same real AI artifact and input contract
%[text] The Expo MATLAB entry point uses time-by-feature input arrays. Here the features are scaled Temperature, Voltage and Current, in that order. Scaling belongs to the deployed input contract; do not substitute raw sensor values. This is a neural model path, not the analytic socEstimate baseline.
dataFolder = fullfile(project.RootFolder,'assets','pil_pi_soc','data');
networkFile = char(fullfile(dataFolder,'projected_net.mat'));
data = load(fullfile(dataFolder,'test_data_scaled.mat'),'XTest_scaled','YTest_scaled');
rows = traceOffset:traceOffset+sampleCount-1;
assert(rows(end)<=size(data.XTest_scaled,1));
input = single(data.XTest_scaled(rows,:));
inputSize = size(input)
%%
%[text] ## Step 2: Establish the MATLAB neural reference
%[text] Enable runHostAI after the instructor checks the current network's inference/codegen support. The helper is short and code-generation-ready: it loads the network with coder.loadDeepLearningNetwork and calls predict. Open its source to see both APIs. Record output shape and finite values before comparing a target.
if runHostAI || runPIL
    hostOutput = predictPiSOC(networkFile,input);
    hostValues = reshape(double(hostOutput),[],1);
    assert(numel(hostValues)==sampleCount && all(isfinite(hostValues)));
    hostRange = [min(hostValues),max(hostValues)]
end
%%
%[text] ## Step 3: Reuse the configured Pi connection securely
%[text] The instructor verifies the supported OS and target toolchain. This direct SSH PIL path uses coder.hardware credentials; it does not construct the separate raspi I/O-server object. Store the private Pi login once using the interactive commands setSecret("TrainingPiUserName") and setSecret("TrainingPiPassword") at your own MATLAB prompt. Never put credential values in shared files or display/save the hardware configuration object.
if runPIL
    assert(~isempty(piAddress),'Enter the current Pi IPv4 address in piAddress.');
    assert(isSecret('TrainingPiUserName') && isSecret('TrainingPiPassword'),'Store the private Pi credentials before enabling PIL.');
    boardName = 'Raspberry Pi';
end
%%
%[text] ## Step 4: Generate the library and its PIL gateway
%[text] The selected supported hardware supplies cross-compilation and communication. The constant model path fixes the network during code generation. The generated PIL gateway runs that neural code on the processor; generating files alone is not PIL success. The support package/toolchain must match the board's OS and architecture.
if runPIL
    try
        buildFolder = fullfile(project.RootFolder,'generated','codegen','pi_soc_pil');
        if ~isfolder(buildFolder), mkdir(buildFolder); end
        configuration = coder.config('lib','ecoder',true);
        configuration.TargetLang = 'C++';
        configuration.DeepLearningConfig = coder.DeepLearningConfig('none');
        configuration.Hardware = coder.hardware('Raspberry Pi');
        configuration.Hardware.DeviceAddress = piAddress;
        configuration.Hardware.Username = getSecret('TrainingPiUserName');
        configuration.Hardware.Password = getSecret('TrainingPiPassword');
        configuration.VerificationMode = 'PIL';
        codegen('-config',configuration,'predictPiSOC','-args',{coder.Constant(networkFile),input},'-d',buildFolder);
        gatewayFolder = fullfile(buildFolder,'pil');
        assert(isfile(fullfile(gatewayFolder,['predictPiSOC_pil.' mexext])),'The generated PIL gateway is missing.');
        addPath(project,gatewayFolder);
        started = tic;
        targetOutput = predictPiSOC_pil(networkFile,input);
        endToEndSeconds = toc(started);
        targetValues = reshape(double(targetOutput),[],1);
        assert(numel(targetValues)==sampleCount && all(isfinite(targetValues)));
        maximumDifference = max(abs(targetValues-hostValues))
        assert(maximumDifference<=equivalenceTolerance);
        demoOutcome = struct('Status','passed','Summary','Actual MATLAB Coder AI PIL agrees with the host neural model.','Evidence',struct('PILExecuted',true,'Board',boardName,'Samples',sampleCount,'MaximumDifference',maximumDifference,'EndToEndSeconds',endToEndSeconds));
    catch exception
        demoOutcome = struct('Status','failed','Summary',exception.message,'Evidence',struct('PILExecuted',false,'ErrorIdentifier',exception.identifier));
        rethrow(exception);
    end
end
demoOutcome
%%
%[text] ## Troubleshooting and engineering conclusion
%[text] If no board is configured, keep the outcome unavailable. A host neural prediction cannot count as PIL. If inference or code generation fails for this compressed network, retain the exact message and use the instructor's verified compatible network path; do not silently substitute the analytic baseline and call it AI deployment. The Simulink exercise independently tests the model-reference route. End-to-end gateway timing includes communication; use profiling for target compute latency.
%[text] **Hint:** The first build prepares generated code and target communication. After that, vary inputs before regenerating the algorithm. Keep the same output comparison and scaling contract.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: MATLAB hardware APIs to remember
%[text:table]
%[text] | API | Minimal syntax | Purpose |
%[text] | --- | --- | --- |
%[text] | [coder.hardware](https://www.mathworks.com/help/coder/ref/coder.hardware.html) | coder.hardware('Raspberry Pi') | Configure direct SSH PIL without the I/O-server object |
%[text] | [coder.config](https://www.mathworks.com/help/coder/ref/coder.config.html) | `coder.config('lib','ecoder',true)` | Embedded library configuration |
%[text] | [coder.hardware](https://www.mathworks.com/help/coder/ref/coder.hardware.html) | `coder.hardware('Raspberry Pi')` | Supported target integration |
%[text] | [coder.DeepLearningConfig](https://www.mathworks.com/help/coder/ref/coder.deeplearningconfig.html) | `coder.DeepLearningConfig('none')` | Generic neural inference code |
%[text] | [coder.loadDeepLearningNetwork](https://www.mathworks.com/help/coder/ref/coder.loaddeeplearningnetwork.html) | Load the constant network MAT-file | Codegen-ready pretrained network |
%[text] | [coder.Constant](https://www.mathworks.com/help/coder/ref/coder.type-class.html) | `coder.Constant(networkFile)` | Fix the model path at compile time |
%[text] | [predict](https://www.mathworks.com/help/deeplearning/ref/dlnetwork.predict.html) | `predict(network,input)` | Compute the neural output |
%[text] | [codegen](https://www.mathworks.com/help/coder/ref/codegen.html) | `codegen(...,'-args',{constantPath,input})` | Generate target code and PIL gateway |
%[text] | [getSecret](https://www.mathworks.com/help/matlab/ref/getsecret.html) | `getSecret(secretName)` | Resolve private credentials at use |
%[text] | [PIL workflow](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html) | Read before target build | Interpret processor evidence correctly |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
