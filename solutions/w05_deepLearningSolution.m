%[text] # 05 — Train and evaluate a compact neural estimator — Solution
%[text] **Goal:** Learn the modern dlnetwork, trainnet, minibatchpredict and testnet workflow.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: Deep Learning Toolbox. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(5,true). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Change hidden width or solver iterations, compare validation results, and explain why the final test split must remain independent.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Worked reasoning:** The 12-unit network is small enough for a classroom run. RMSE below 0.03 is the teaching requirement; inspect the printed value on your machine. Regression does not automatically constrain output to [0,1].
project = requireTrainingProject;
%%
%[text] ## Prepare the training data
%[text] Predictor rows are observations and columns are voltage, current and temperature. Tune using acquisition 8. Normalize predictor inputs using only training statistics; targets are SOC fractions.
data = makeBatteryData;
trainRows = data.runId <= 7;
validationRows = data.runId == 8;
testRows = data.runId >= 9;
x = [data.voltage,data.current,data.temperature];
%%
%[text] ## Define and train with visible APIs
%[text] We use a custom layer architecture because later exercises inspect bounds, compression and layer-block Simulink export. For plain tabular fitting without those requirements, fitrnet is an even shorter alternative.
rng(7);
hiddenWidth = 12;
layers = [featureInputLayer(3,Normalization="zscore")
    fullyConnectedLayer(hiddenWidth)
    reluLayer
    fullyConnectedLayer(1)];
options = trainingOptions("lbfgs",MaxIterations=60,ExecutionEnvironment="cpu",Verbose=false);
net = trainnet(x(trainRows,:),data.soc(trainRows),layers,"mse",options);
validationPrediction = minibatchpredict(net,x(validationRows,:));
validationRMSE = sqrt(mean((validationPrediction-data.soc(validationRows)).^2))
evaluateFinalTest = true;
if evaluateFinalTest
    prediction = minibatchpredict(net,x(testRows,:));
    finalTestRMSE = sqrt(mean((prediction-data.soc(testRows)).^2))
    assert(finalTestRMSE < 0.03);
end
%%
%[text] ## Read the residuals
%[text] Inspect validation residuals while tuning. Freeze architecture and solver settings before enabling final test evaluation; that threshold is a test requirement, not a tuning objective.
maximumValidationError = max(abs(validationPrediction-data.soc(validationRows)))
plot(data.soc(validationRows),validationPrediction,'.');
xlabel('Validation reference SOC'); ylabel('Neural SOC'); grid on;
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require a configured compatible target. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`featureInputLayer`](https://www.mathworks.com/help/deeplearning/ref/nnet.cnn.layer.featureinputlayer.html) | featureInputLayer(3,Normalization="zscore") | Normalize predictors |
%[text] | [`trainnet`](https://www.mathworks.com/help/deeplearning/ref/trainnet.html) | trainnet(X,Y,layers,"mse",options) | Train modern network |
%[text] | [`minibatchpredict`](https://www.mathworks.com/help/deeplearning/ref/minibatchpredict.html) | minibatchpredict(net,X) | Batch inference |
%[text] | [`testnet`](https://www.mathworks.com/help/deeplearning/ref/testnet.html) | testnet(net,X,Y,"rmse") | Standard evaluation metric |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
