%[text] # 07 — Compress while preserving requirements
%[text] **Goal:** Observe the precision/error tradeoff and learn calibration-based INT8 workflow.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: Deep Learning Toolbox; optional Model Compression Library. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(7). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Change precision levels and compare RMSE against 0.03. Explain why rounding weights alone is not an INT8 runtime deployment.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Before opening the solution:** Record your parameter change, observed result, and engineering conclusion.
project = requireTrainingProject;
%%
%[text] ## Establish reference inference
%[text] Keep the same held-out measurements for each comparison. The reference network is freshly trained by the same visible workflow as exercise 5.
[net,referenceMetrics] = trainSOCNetwork;
data = makeBatteryData;
xTest = [data.voltage(data.runId>=9),data.current(data.runId>=9),data.temperature(data.runId>=9)];
reference = minibatchpredict(net,xTest);
%%
%[text] ## Explore weight precision
%[text] This simulates reduced weight precision while retaining floating-point execution. Measure output error; do not claim an INT8 memory saving from this floating-point object.
levels = 127;
roundedNet = dlupdate(@(parameter) round(parameter*levels)/levels,net);
rounded = minibatchpredict(roundedNet,xTest);
rmseRounded = sqrt(mean((rounded-data.soc(data.runId>=9)).^2))
maxPredictionChange = max(abs(rounded-reference))
referenceMetrics
%%
%[text] ## Calibrate real quantization optionally
%[text] Calibration data must cover the operating domain; never calibrate on final test data. Raw mixed-unit inputs can lose voltage resolution during INT8 quantization. Compare the initial error, then move the learned input normalization outside the quantized network and recheck the same threshold. This changes the input contract and must be included in deployment preprocessing. Fixed-Point Designer and the Model Compression Library are required.
runQuantization = false;
if runQuantization
    quantizer = dlquantizer(net,ExecutionEnvironment="MATLAB");
    xCalibration = [data.voltage(data.runId==8),data.current(data.runId==8),data.temperature(data.runId==8)];
    calibrate(quantizer,xCalibration);
    quantizedNet = quantize(quantizer);
    quantizedPrediction = minibatchpredict(quantizedNet,xTest);
    quantizedRMSE = sqrt(mean((double(quantizedPrediction)-data.soc(data.runId>=9)).^2))
    rawInputQuantizationMeetsRequirement = quantizedRMSE <= 0.03
    inputLayer = net.Layers(1);
    predictorMean = double(inputLayer.Mean(:)');
    predictorStd = double(inputLayer.StandardDeviation(:)');
    normalizedNet = replaceLayer(net,inputLayer.Name,featureInputLayer(3,Name=inputLayer.Name,Normalization="none"));
    normalizedNet = initialize(normalizedNet);
    normalizedCalibration = (xCalibration-predictorMean)./predictorStd;
    normalizedTest = (xTest-predictorMean)./predictorStd;
    normalizedFloatPrediction = minibatchpredict(normalizedNet,normalizedTest);
    assert(max(abs(double(normalizedFloatPrediction)-double(reference)))<1e-5);
    normalizedQuantizer = dlquantizer(normalizedNet,ExecutionEnvironment="MATLAB");
    calibrate(normalizedQuantizer,normalizedCalibration);
    normalizedQuantized = quantize(normalizedQuantizer);
    correctedPrediction = minibatchpredict(normalizedQuantized,normalizedTest);
    correctedRMSE = sqrt(mean((double(correctedPrediction)-data.soc(data.runId>=9)).^2))
    assert(correctedRMSE<=0.03);
end
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/compression.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`dlupdate`](https://www.mathworks.com/help/deeplearning/ref/dlupdate.html) | dlupdate(fun,net) | Inspect parameter sensitivity |
%[text] | [`dlquantizer`](https://www.mathworks.com/help/deeplearning/ref/dlquantizer.html) | dlquantizer(net,ExecutionEnvironment="MATLAB") | Configure INT8 quantization |
%[text] | [`calibrate`](https://www.mathworks.com/help/deeplearning/ref/dlquantizer.calibrate.html) | calibrate(q,XCalibration) | Collect activation ranges |
%[text] | [`quantize`](https://www.mathworks.com/help/deeplearning/ref/dlquantizer.quantize.html) | quantize(q) | Produce quantized network |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
