%[text] # 23 ? Verify a trained SOC network with R2026b capabilities
%[text] **Goal:** Train a smooth virtual sensor, bound its prediction over a sensor-uncertainty box, and detect shifted input data with a regression OOD discriminator.
%[text] **Prerequisites:** Open the training Project in MATLAB R2026b. Deep Learning Toolbox and AI Verification Library for Deep Learning Toolbox. CPU only; no board or downloads. Estimated time: 25 minutes.
%[text] **Your task:** Change uncertaintyScale or the hidden width using validation data only. Decide whether the output bounds certify the error requirement, and compare nominal input-distribution flags with deliberately shifted voltage inputs.
%[text] **Hint 1:** A conservative bound outside a tolerance does not by itself establish a violating input. Look for a concrete counterexample or keep the verdict unproven.
%[text] **Hint 2:** softplusLayer is not a newly introduced layer; formal verification support for this layer is new in R2026b. Numeric-array OOD inputs and execution/data-format options are also R2026b additions.
%[text] **Solution:** Open the matching solution after recording your changed parameter, nominal accuracy, certified interval, and OOD observations.
project = requireTrainingProject;
rng(23,"twister");
hiddenWidth = 8;
maxIterations = 60;
uncertaintyScale = 1;
allowedAbsoluteError = 0.03;
runStrongerBounds = false;
%%
%[text] ## Step 1: Train an actual neural SOC estimator
%[text] This network is optimized from the supplied synthetic sensor data; its weights are not assigned to an exact affine law. We use runs 1 to 7 for training and run 8 for validation. Final test acquisitions 9 and 10 remain untouched while choosing network width and verification settings.
data = makeBatteryData(23,600);
trainRows = data.runId<=7;
validationRows = data.runId==8;
x = single([data.voltage,data.current,data.temperature]);
layers = [featureInputLayer(3,Normalization="zscore",Name="sensors")
    fullyConnectedLayer(hiddenWidth,Name="hidden")
    softplusLayer(Name="smoothFeatures")
    fullyConnectedLayer(1,Name="soc")];
options = trainingOptions("lbfgs",MaxIterations=maxIterations, ...
    ExecutionEnvironment="cpu",Verbose=false);
net = trainnet(x(trainRows,:),single(data.soc(trainRows)),layers,"mse",options);
validationPrediction = double(minibatchpredict(net,x(validationRows,:)));
validationRMSE = sqrt(mean((validationPrediction-data.soc(validationRows)).^2))
%%
%[text] ## Step 2: Define the operating point and sensor uncertainty
%[text] The true SOC is fixed for this local measurement-uncertainty experiment. Voltage, current and temperature may vary within the box. We assess an absolute SOC error limit of 0.03 for every input in that box; this is different from an aggregate RMSE requirement.
validationIndices = find(validationRows);
centerIndex = validationIndices(10);
center = x(centerIndex,:)';
referenceSOC = data.soc(centerIndex);
delta = uncertaintyScale*single([0.002;0.02;0.5]);
lowerInput = dlarray(center-delta,"CB");
upperInput = dlarray(center+delta,"CB");
nominalSOC = double(extractdata(predict(net,dlarray(center,"CB"))));
nominalAbsoluteError = abs(nominalSOC-referenceSOC)
%%
%[text] ## Step 3: Compute conservative bounds on the trained network
%[text] R2026b can formally bound this trained softplus network. The resulting interval encloses the network output over the complete input box. It certifies the local numerical requirement only when the whole interval lies inside the allowed error band.
[outputLower,outputUpper] = estimateNetworkOutputBounds( ...
    net,lowerInput,upperInput,ExecutionEnvironment="cpu");
boundedOutput = [double(extractdata(outputLower)),double(extractdata(outputUpper))];
assert(all(isfinite(boundedOutput)) && boundedOutput(1)<=boundedOutput(2));
worstCaseBoundedError = max(abs(boundedOutput-referenceSOC));
if worstCaseBoundedError<=allowedAbsoluteError
    boundVerdict = "certifiedWithinBox";
else
    boundVerdict = "unprovenWithCurrentBounds";
end
boundsEvidence = table(referenceSOC,nominalSOC,boundedOutput(1),boundedOutput(2), ...
    worstCaseBoundedError,boundVerdict, ...
    VariableNames=["ReferenceSOC","NominalSOC","LowerBound","UpperBound","WorstCaseErrorBound","Verdict"])
%%
%[text] ## Step 4: Sample the eight corners without confusing sampling and proof
%[text] Corner sampling can reveal an actual counterexample, but absence of a sampled failure is not a universal proof. The certificate above is based on conservative bounds, not on these eight observations.
[a,b,c] = ndgrid([-1,1],[-1,1],[-1,1]);
cornerSigns = single([a(:),b(:),c(:)]);
cornerInputs = center'+cornerSigns.*delta';
cornerPrediction = double(minibatchpredict(net,cornerInputs));
cornerMaximumError = max(abs(cornerPrediction-referenceSOC))
observedCounterexample = cornerMaximumError>allowedAbsoluteError
%%
%[text] ## Optional: Improve bounds with a bounded alpha-CROWN computation
%[text] Set runStrongerBounds true to try five optimizer epochs. alphaCROWNOptions was introduced in R2026a; the trained softplus layer support is the R2026b part. Pass the options object as Algorithm, and measure its runtime instead of assuming it is free or always improves this particular bound.
if runStrongerBounds
    strongerOptions = alphaCROWNOptions(MaxEpochs=5,MiniBatchSize=1, ...
        ExecutionEnvironment="cpu",Verbose=false);
    started = tic;
    [strongerLower,strongerUpper] = estimateNetworkOutputBounds( ...
        net,lowerInput,upperInput,Algorithm=strongerOptions);
    strongerSeconds = toc(started);
    strongerInterval = [double(extractdata(strongerLower)),double(extractdata(strongerUpper))]
    strongerSeconds
end
%%
%[text] ## Step 5: Calibrate an OOD detector for a regression network
%[text] HBOS supports regression models by analysing intermediate activations. The known training-domain inputs are ID; adding one volt creates an intentionally shifted OOD calibration set. R2026b accepts these ordinary numeric matrices directly with the explicit BC format. This is a distribution detector calibrated from examples, not a formal safety certificate.
idCalibration = x(trainRows,:);
oodCalibration = idCalibration;
oodCalibration(:,1) = oodCalibration(:,1)+single(1);
discriminator = networkDistributionDiscriminator( ...
    net,idCalibration,oodCalibration,"hbos",LayerNames="smoothFeatures", ...
    VarianceCutoff=0.0001,InputDataFormats="BC", ...
    MiniBatchSize=64,ExecutionEnvironment="cpu");
idProbe = x(validationRows,:);
oodProbe = idProbe;
oodProbe(:,1) = oodProbe(:,1)+single(1.5);
isNominalID = isInNetworkDistribution(discriminator,idProbe, ...
    InputDataFormats="BC",MiniBatchSize=64,ExecutionEnvironment="cpu");
isShiftedID = isInNetworkDistribution(discriminator,oodProbe, ...
    InputDataFormats="BC",MiniBatchSize=64,ExecutionEnvironment="cpu");
assert(numel(isNominalID)==nnz(validationRows) && numel(isShiftedID)==nnz(validationRows));
oodEvidence = table(mean(isNominalID),mean(~isShiftedID), ...
    VariableNames=["NominalFlaggedIDFraction","ShiftedFlaggedOODFraction"])
%%
%[text] ## Step 6: Preserve the model, domain and observed evidence
%[text] Save the actual trained model and input box with its numerical and distribution results. Recheck the same properties if compression or deployment changes the model. Keep a separate frozen final-test set for a final accuracy claim.
outputFolder = fullfile(project.RootFolder,"generated","verification");
if ~isfolder(outputFolder), mkdir(outputFolder); end
save(fullfile(outputFolder,"trainedSOCVerification.mat"),"net","discriminator", ...
    "center","delta","referenceSOC","boundsEvidence","oodEvidence","validationRMSE");
%%
%[text] ## Troubleshooting and takeaway
%[text] An unproven interval is a valid inconclusive result. Narrow the operating box or inspect a stronger solver before declaring a violation. If the classifier flags nominal data as OOD, review calibration coverage, feature-layer choice and threshold behaviour. Neither ID classification nor an accurate nominal point proves safety for a whole domain.
%[text] ## Documentation and further reading
%[text] [Main AI verification documentation](https://www.mathworks.com/help/deeplearning/verification.html), [R2026b bounds support and release history](https://www.mathworks.com/help/deeplearning/ref/estimatenetworkoutputbounds.html), and [regression OOD discriminator example](https://www.mathworks.com/help/deeplearning/ref/networkdistributiondiscriminator.html).
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal syntax | Purpose |
%[text] | --- | --- | --- |
%[text] | [trainnet](https://www.mathworks.com/help/deeplearning/ref/trainnet.html) | trainnet(X,T,layers,"mse",options) | Fit actual SOC model weights |
%[text] | [softplusLayer](https://www.mathworks.com/help/deeplearning/ref/nnet.cnn.layer.softpluslayer.html) | softplusLayer(Name="smoothFeatures") | Smooth activation; new R2026b formal support |
%[text] | [estimateNetworkOutputBounds](https://www.mathworks.com/help/deeplearning/ref/estimatenetworkoutputbounds.html) | estimateNetworkOutputBounds(net,lower,upper) | Conservative output interval |
%[text] | [alphaCROWNOptions](https://www.mathworks.com/help/deeplearning/ref/alphacrownoptions.html) | alphaCROWNOptions(MaxEpochs=5) | Bounded stronger-solver configuration |
%[text] | [networkDistributionDiscriminator](https://www.mathworks.com/help/deeplearning/ref/networkdistributiondiscriminator.html) | networkDistributionDiscriminator(net,ID,OOD,"hbos") | Calibrate regression OOD detection |
%[text] | [isInNetworkDistribution](https://www.mathworks.com/help/deeplearning/ref/isinnetworkdistribution.html) | isInNetworkDistribution(detector,X) | Flag input distribution shifts |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
