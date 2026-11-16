%[text] # Solution 19: A predictive full-field AI ROM
%[text] **Goal:** Learn heating/cooling parameters to POD coefficients and reconstruct held-out temperature fields. Open the training MATLAB Project and run sections in order. MATLAB R2026b and Deep Learning Toolbox; no external data or hardware. Allow 15 minutes.
project = currentProject;
projectRoot = project.RootFolder;
rng(19);
%%
%[text] ## Step 1: Create 80 training field/parameter pairs
%[text] These rank-three fields illustrate the predictive pipeline; they are synthetic spatial patterns, not a validated battery PDE solution. The training data is a grid of heating intensity and cooling settings.
[x,y,z] = ndgrid(linspace(-1,1,10));
spatialModes = [exp(-3*(x(:).^2+y(:).^2)), x(:).*exp(-2*z(:).^2), y(:).*z(:)];
[heating,cooling] = ndgrid(linspace(0.1,1,10),linspace(0.35,0.75,8));
trainingParameters = [heating(:),cooling(:)];
trainingCoefficients = [10*heating(:)'; 3*heating(:)'.^2./cooling(:)'; 0.4*cos(pi*heating(:)')];
trainingFields = 25+spatialModes*trainingCoefficients;
%%
%[text] ## Step 2: Learn the basis and target normalization from training data
%[text] **Answer:** Centre with the training mean, extract three modes, project training fields and normalize each response. The basis and normalization statistics remain fixed for every held-out inference case.
meanField = mean(trainingFields,2);
[U,~,~] = svd(trainingFields-meanField,"econ");
basis = U(:,1:3);
latentTraining = (basis'*(trainingFields-meanField))';
targetMean = mean(latentTraining,1);
targetScale = std(latentTraining,0,1);
normalizedTargets = (latentTraining-targetMean)./targetScale;
%%
%[text] ## Step 3: Train the compact latent predictor
%[text] **Answer:** Two hidden layers of width 12 represent this smooth parameter map. Use 100 L-BFGS iterations, input z-score normalization and normalized latent targets. The goal is held-out field accuracy rather than low training loss alone.
hiddenWidth = 12;
maxIterations = 100;
layers = [featureInputLayer(2,Normalization="zscore"); fullyConnectedLayer(hiddenWidth); tanhLayer; fullyConnectedLayer(hiddenWidth); tanhLayer; fullyConnectedLayer(3)];
options = trainingOptions("lbfgs",MaxIterations=maxIterations,ExecutionEnvironment="cpu",Verbose=false);
net = trainnet(trainingParameters,normalizedTargets,layers,"mse",options);
%%
%[text] ## Step 4: Predict and then evaluate unseen fields
%[text] **Answer:** `minibatchpredict` receives only the 20 held-out parameter pairs. Decode its latent outputs using fixed training statistics. Construct the reference temperature fields afterwards for evaluation; they are never passed to the predictor.
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
assert(predictionError<0.1,"Held-out AI field-prediction error exceeds 10%.");
assert(projectionError<1e-10,"The rank-three POD basis should span the reference field family.");
scatter3(x(:),y(:),z(:),18,predictedFields(:,1)-referenceFields(:,1),"filled")
axis equal; colorbar; title("AI field-prediction error (deg C)"); xlabel("x"); ylabel("y"); zlabel("z")
%%
%[text] ## Step 5: Engineering acceptance
%[text] Prediction error contains both latent-prediction and field-reconstruction errors; the tiny projection-only error isolates how much error can be attributed to the trained predictor in this synthetic example. The 10% requirement is an illustrative global field-error gate, not a battery safety threshold. Add hot-spot, operating-envelope, system-level and physics checks before using real thermal models.
%[text] **Optional extension:** Train on genuine simulation snapshots, use independent scenario splits, include state/history for dynamic predictions, and test the decoded field inside the system-level workflow. Do not claim measured speedup without benchmarking comparable full and reduced implementations.
%%
%[text] ## Troubleshooting
%[text] If modified data fails acceptance, inspect training coverage, optimization convergence, basis rank and normalization. Keep the test cases held out; do not tune the basis on reference test fields. Protect nearly zero target scales if a latent response is constant.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/reduced-order-modeling.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | Step | API | Minimal syntax | Meaning |
%[text] | --- | --- | --- | --- |
%[text] | Encode | [`svd`](https://www.mathworks.com/help/matlab/ref/double.svd.html) | `[U,S,V] = svd(X,"econ")` | Training-only POD basis |
%[text] | Normalize inputs | [`featureInputLayer`](https://www.mathworks.com/help/deeplearning/ref/nnet.cnn.layer.featureinputlayer.html) | `featureInputLayer(2,Normalization="zscore")` | Parameter normalization |
%[text] | Train | [`trainnet`](https://www.mathworks.com/help/deeplearning/ref/trainnet.html) | `net = trainnet(X,T,layers,"mse",options)` | Learn latent coefficients |
%[text] | Infer | [`minibatchpredict`](https://www.mathworks.com/help/deeplearning/ref/minibatchpredict.html) | `A = minibatchpredict(net,XTest)` | Parameter-only held-out prediction |
%[text] | Decode | [`Matrix multiplication`](https://www.mathworks.com/help/matlab/ref/double.mtimes.html) | `field = meanField+basis*A'` | Recover the full spatial field |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
