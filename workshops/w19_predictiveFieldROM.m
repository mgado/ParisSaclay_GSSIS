%[text] # Workshop 19: Predict a full temperature field with an AI ROM
%[text] **Goal:** Train a network from heating/cooling parameters to spatial POD coefficients, then predict an unseen 3D field without using that field during inference.
%[text] **Prerequisites:** MATLAB R2026b and Deep Learning Toolbox; open the training MATLAB Project. Allow 15 minutes. The basic path is independent of Workshop 13 and needs no downloaded simulation data or hardware. Launch in the Live Editor and use **Run Section**.
project = currentProject;
projectRoot = project.RootFolder;
rng(19);
%%
%[text] ## Step 1: Prepare synthetic full-field training cases
%[text] These illustrative fields are combinations of three spatial patterns, not outputs of a solved battery PDE. Each column is one 1,000-node temperature field. Each row of `trainingParameters` contains heating intensity and cooling setting for one field. The training grid contains 80 parameter cases.
[x,y,z] = ndgrid(linspace(-1,1,10));
spatialModes = [exp(-3*(x(:).^2+y(:).^2)), x(:).*exp(-2*z(:).^2), y(:).*z(:)];
[heating,cooling] = ndgrid(linspace(0.1,1,10),linspace(0.35,0.75,8));
trainingParameters = [heating(:),cooling(:)];
trainingCoefficients = [10*heating(:)'; 3*heating(:)'.^2./cooling(:)'; 0.4*cos(pi*heating(:)')];
trainingFields = 25+spatialModes*trainingCoefficients;
%%
%[text] ## Step 2: Encode training fields in a compact spatial basis
%[text] Mean and basis are calculated from training fields only. `latentTraining` has one row per case and three response columns. Normalize each response using training statistics; the same statistics must be used to decode network predictions.
meanField = mean(trainingFields,2);
[U,~,~] = svd(trainingFields-meanField,"econ");
basis = U(:,1:3);
latentTraining = (basis'*(trainingFields-meanField))';
targetMean = mean(latentTraining,1);
targetScale = std(latentTraining,0,1);
normalizedTargets = (latentTraining-targetMean)./targetScale;
%%
%[text] ## Step 3: Learn parameters to coefficients
%[text] **Exercise:** Start with this small network and 20 iterations. Then increase `hiddenWidth` to 12 and `maxIterations` to 100. Does prediction improve on unseen cases? Hint: `featureInputLayer` normalizes inputs, while the target normalization above gives each latent response a comparable influence on MSE. L-BFGS is useful for this small smooth regression problem.
hiddenWidth = 4; % Try 12 after measuring held-out prediction error.
maxIterations = 20; % Try 100.
layers = [featureInputLayer(2,Normalization="zscore"); fullyConnectedLayer(hiddenWidth); tanhLayer; fullyConnectedLayer(hiddenWidth); tanhLayer; fullyConnectedLayer(3)];
options = trainingOptions("lbfgs",MaxIterations=maxIterations,ExecutionEnvironment="cpu",Verbose=false);
net = trainnet(trainingParameters,normalizedTargets,layers,"mse",options);
%%
%[text] ## Step 4: Predict unseen fields without their temperatures
%[text] The held-out parameters are between training grid points. **Exercise:** Locate the statement where inference happens and confirm that it receives only parameter values, not held-out temperature fields. The analytical fields below are generated solely as a separate evaluation reference.
[testHeating,testCooling] = ndgrid([0.145,0.365,0.585,0.805,0.965],[0.39,0.49,0.61,0.71]);
testParameters = [testHeating(:),testCooling(:)];
predictedLatent = minibatchpredict(net,testParameters);
predictedLatent = predictedLatent.*targetScale+targetMean;
predictedFields = meanField+basis*predictedLatent';
referenceCoefficients = [10*testHeating(:)'; 3*testHeating(:)'.^2./testCooling(:)'; 0.4*cos(pi*testHeating(:)')];
referenceFields = 25+spatialModes*referenceCoefficients;
predictionError = norm(predictedFields-referenceFields,"fro")/norm(referenceFields-meanField,"fro")
projectionOnly = meanField+basis*(basis'*(referenceFields-meanField));
projectionError = norm(projectionOnly-referenceFields,"fro")/norm(referenceFields-meanField,"fro")
scatter3(x(:),y(:),z(:),18,predictedFields(:,1)-referenceFields(:,1),"filled")
axis equal; colorbar; title("AI field-prediction error (deg C)"); xlabel("x"); ylabel("y"); zlabel("z")
%%
%[text] ## Step 5: Interpret the two errors
%[text] `projectionError` measures the basis's ability to encode a field that is already known. `predictionError` also includes the network's parameter-to-coefficient error. Expected observation: projection error is near floating-point precision; AI prediction error is larger and should improve with the wider network and longer fit. This establishes prediction on a held-out synthetic parameter grid, not battery physics validity or performance outside the training envelope.
%[text] **Optional extension:** Replace synthetic snapshots with authorized simulation data, split by independent operating scenarios, check local hot-spot errors as well as global norms, and integrate the predictive ROM into a controller-level Simulink test. A dynamic ROM may require state/history inputs rather than just instantaneous parameters.
%%
%[text] ## Troubleshooting
%[text] Open the training Project if `currentProject` fails. If `trainnet` is unavailable, verify Deep Learning Toolbox and the MATLAB release. Inspect target scales before fitting; a nearly constant coefficient needs a protected scale rather than division by zero. Do not re-fit normalization or the POD basis on test fields to make the metric look better.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/reduced-order-modeling.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | Step | API | Minimal syntax | Meaning |
%[text] | --- | --- | --- | --- |
%[text] | Encode | [`svd`](https://www.mathworks.com/help/matlab/ref/double.svd.html) | `[U,S,V] = svd(X,"econ")` | Spatial POD basis from training fields |
%[text] | Network | [`featureInputLayer`](https://www.mathworks.com/help/deeplearning/ref/nnet.cnn.layer.featureinputlayer.html) | `featureInputLayer(2,Normalization="zscore")` | Normalize two parameter inputs |
%[text] | Train | [`trainnet`](https://www.mathworks.com/help/deeplearning/ref/trainnet.html) | `net = trainnet(X,T,layers,"mse",options)` | Learn latent regression targets |
%[text] | [`Predict`](https://www.mathworks.com/help/deeplearning/ref/dlnetwork.predict.html) | [`minibatchpredict`](https://www.mathworks.com/help/deeplearning/ref/minibatchpredict.html) | `A = minibatchpredict(net,XTest)` | Infer coefficients from parameters only |
%[text] | Decode | [`Matrix multiplication`](https://www.mathworks.com/help/matlab/ref/double.mtimes.html) | `field = meanField+basis*A'` | Reconstruct the predicted full field |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
