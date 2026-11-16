function [net,metrics] = trainSOCNetwork
%TRAINSOCNETWORK Train a compact reproducible state-of-charge estimator.
%   [NET,METRICS] = trainSOCNetwork uses synthetic measurements and
%   independent acquisition groups for held-out error measurement.
%   See also trainnet, trainingOptions, minibatchpredict.
previousState = rng;
restore = onCleanup(@() rng(previousState));
rng(7);
data = makeBatteryData;
trainMask = data.runId <= 7;
testMask = data.runId >= 9;
predictors = [data.voltage,data.current,data.temperature];
layers = [featureInputLayer(3,Normalization="zscore")
    fullyConnectedLayer(12)
    reluLayer
    fullyConnectedLayer(1)];
options = trainingOptions("lbfgs",MaxIterations=60, ...
    ExecutionEnvironment="cpu",Verbose=false);
net = trainnet(predictors(trainMask,:),data.soc(trainMask),layers,"mse",options);
prediction = minibatchpredict(net,predictors(testMask,:));
metrics.rmse = sqrt(mean((double(prediction)-data.soc(testMask)).^2));
metrics.maxError = max(abs(double(prediction)-data.soc(testMask)));
metrics.numTest = nnz(testMask);
end
