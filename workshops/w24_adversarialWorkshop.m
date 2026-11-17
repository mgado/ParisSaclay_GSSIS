%[text] # 24 ? Adversarial search and formal robustness from the existing workshop
%[text] **Goal:** Train a small digit CNN, search for bounded counterexamples, then ask a formal verifier whether one prediction holds throughout its input box.
%[text] **Prerequisites:** Open the training Project in MATLAB R2026b. Deep Learning Toolbox and AI Verification Library for Deep Learning Toolbox. Uses shipped digit data; CPU only. Estimated time: 25 minutes.
%[text] **Notice:** Relevant third-party terms are retained in [the MathWorks verification license](../licenses/MathWorks-ai-verification.txt).
%[text] **Your task:** Compare perturbation sizes 0.05 and 0.1. Record whether search found an example and whether the formal result is verified, unproven or violated. Never describe unsuccessful search as a proof of robustness.
%[text] **Hint 1:** Train a quick classifier first and attack only test inputs it classifies correctly. Small pixel changes are a numerical constraint; do not promise that every changed image is imperceptible.
%[text] **Hint 2:** FGSM takes one gradient step; BIM repeats bounded steps. Limit both the attempt count and BIM iterations. The solution uses a second bounded attempt, not an unbounded search-until-success loop.
project = requireTrainingProject;
rng(24,"twister");
numTrainingImages = 1600;
maxEpochs = 6;
perturbationSize = 0.05;
maxSearchAttempts = 1;
bimIterations = 10;
%%
%[text] ## Step 1: Train a small modern classifier
%[text] We train on at most 1600 supplied images for six epochs. This is a short verification teaching model, not a claim of production accuracy. trainnet uses the cross-entropy loss and no legacy classificationLayer or trainNetwork.
[XTrain,TTrain] = digitTrain4DArrayData;
trainingIndices = randperm(size(XTrain,4),min(numTrainingImages,size(XTrain,4)));
layers = [imageInputLayer([28,28,1],Normalization="none",Name="image")
    convolution2dLayer(3,8,Padding="same",Name="conv")
    reluLayer(Name="relu")
    maxPooling2dLayer(2,Stride=2,Name="pool")
    fullyConnectedLayer(10,Name="scores")
    softmaxLayer(Name="probabilities")];
options = trainingOptions("adam",MaxEpochs=maxEpochs,MiniBatchSize=64, ...
    Shuffle="every-epoch",ExecutionEnvironment="cpu",Verbose=false,Plots="none");
net = trainnet(single(XTrain(:,:,:,trainingIndices)),TTrain(trainingIndices), ...
    layers,"crossentropy",options);
%%
%[text] ## Step 2: Choose correctly classified test inputs
%[text] Reference labels are withheld digit-test labels. We choose at most eight correctly classified observations, so a changed class is a meaningful counterexample to the original correct prediction rather than a classifier error that already existed.
[XTest,TTest] = digitTest4DArrayData;
testCount = min(1000,size(XTest,4));
XTest = single(XTest(:,:,:,1:testCount));
TTest = TTest(1:testCount);
classNames = categorical(0:9);
testScores = predict(net,dlarray(XTest,"SSCB"));
testPredictions = scores2label(testScores,classNames);
testAccuracy = mean(testPredictions(:)==TTest(:))
correctIndices = find(testPredictions(:)==TTest(:));
assert(~isempty(correctIndices),"The quick classifier has no correct test input; review training.");
selectedIndices = correctIndices(1:min(8,numel(correctIndices)));
X = dlarray(XTest(:,:,:,selectedIndices),"SSCB");
labels = TTest(selectedIndices);
XLower = max(X-perturbationSize,0);
XUpper = min(X+perturbationSize,1);
%%
%[text] ## Step 3: Search with an explicit bounded budget
%[text] findAdversarialExamples and adversarialOptions were introduced in R2026a. Attempt 1 is FGSM. An enabled second attempt is BIM with ten iterations. The R2026b formal-verification expansions are exercised in lesson 23. The search never exceeds maxSearchAttempts calls, and none found remains a valid inconclusive observation.
assert(maxSearchAttempts>=1 && maxSearchAttempts<=2);
fgsmOptions = adversarialOptions("fgsm",StepSize=perturbationSize, ...
    MiniBatchSize=8,ExecutionEnvironment="cpu",Verbose=false);
bimOptions = adversarialOptions("bim",StepSize=perturbationSize/5, ...
    NumIterations=bimIterations,MiniBatchSize=8,ExecutionEnvironment="cpu",Verbose=false);
examples = [];
mislabels = [];
iX = [];
for attempt = 1:maxSearchAttempts
    if attempt==1, attackOptions = fgsmOptions; else, attackOptions = bimOptions; end
    [examples,mislabels,iX] = findAdversarialExamples( ...
        net,XLower,XUpper,labels,Algorithm=attackOptions);
    if ~isempty(examples), break; end
end
if isempty(examples)
    searchStatus = "noneFound";
    exampleCount = 0;
else
    searchStatus = "counterexampleFound";
    exampleCount = numel(mislabels);
end
searchEvidence = struct("Status",searchStatus,"AttemptsUsed",attempt, ...
    "MaximumAttempts",maxSearchAttempts,"BIMIterationLimit",bimIterations, ...
    "PerturbationSize",perturbationSize,"ExamplesFound",exampleCount)
%%
%[text] ## Step 4: Inspect a counterexample only when one exists
%[text] iX maps the returned example back to its original batch input. The guarded code does not index example 1 when search found none. The original class is correct; the returned mislabel is the class actually assigned to the adversarial input.
if ~isempty(examples)
    inputIndex = iX(1);
    originalImage = squeeze(extractdata(X(:,:,:,inputIndex)));
    adversarialImage = squeeze(extractdata(examples(:,:,:,1)));
    measuredPerturbation = max(abs(originalImage-adversarialImage),[],"all")
    assert(measuredPerturbation<=perturbationSize+1e-6);
    tiledlayout(1,2);
    nexttile; imagesc(originalImage); axis image off; colormap gray
    title("Original: "+string(labels(inputIndex)));
    nexttile; imagesc(adversarialImage); axis image off; colormap gray
    title("Adversarial: "+string(mislabels(1)));
else
    disp("No counterexample found within this bounded search. Robustness is not proved.");
end
%%
%[text] ## Step 5: Verify one complete input region
%[text] verifyNetworkRobustness checks class invariance throughout the region for the first correct input. verified certifies that property within this box; violated means the property does not hold; unproven is inconclusive. The single-region CPU run avoids turning this short lesson into the upstream whole-domain adaptive-mesh analysis.
[result,detailedResult] = verifyNetworkRobustness(net, ...
    XLower(:,:,:,1),XUpper(:,:,:,1),labels(1), ...
    MiniBatchSize=1,ExecutionEnvironment="cpu");
formalStatus = string(result(1))
assert(any(formalStatus==["verified","unproven","violated"]));
overallVerdict = formalStatus;
firstInputCounterexampleValidated = false;
firstInputExample = find(iX==1,1);
if ~isempty(firstInputExample) && ~isempty(examples)
    candidate = examples(:,:,:,firstInputExample);
    candidateData = extractdata(candidate);
    lowerData = extractdata(XLower(:,:,:,1));
    upperData = extractdata(XUpper(:,:,:,1));
    candidateWithinBox = all(candidateData>=lowerData,"all") && ...
        all(candidateData<=upperData,"all");
    candidateLabel = scores2label(predict(net,candidate),classNames);
    firstInputCounterexampleValidated = candidateWithinBox && ...
        string(candidateLabel)~=string(labels(1));
    if firstInputCounterexampleValidated, overallVerdict = "violated"; end
end
overallVerdict
proofEvidence = struct("Result",formalStatus,"OverallVerdict",overallVerdict, ...
    "FirstInputCounterexampleValidated",firstInputCounterexampleValidated, ...
    "InputIndex",selectedIndices(1),"ExpectedClass",string(labels(1)), ...
    "PerturbationSize",perturbationSize);
detailedResult
%[text] A validated counterexample inside the first image's input box proves that its class-invariance property is violated, even if the formal solver reports unproven. The solver's result remains unproven, but the combined evidence is conclusive for this case. A counterexample for a different image does not change the verdict of the first image's box; without a validated first-image counterexample, overallVerdict retains the formal result.
%%
%[text] ## Step 6: Save the observed evidence and explain the difference
%[text] Test accuracy is a sample statistic. Search supplies a concrete counterexample when successful. A formal verifier assesses all inputs in its specified region, with an explicit inconclusive result when it cannot decide. None of these alone proves a deployed system is safe outside the tested operating domain.
outputFolder = fullfile(project.RootFolder,"generated","verification");
if ~isfolder(outputFolder), mkdir(outputFolder); end
save(fullfile(outputFolder,"digitVerification.mat"),"net","searchEvidence", ...
    "proofEvidence","overallVerdict","testAccuracy","selectedIndices");
%%
%[text] ## Troubleshooting and next activity
%[text] If no counterexample is found, record noneFound and compare a second bounded attempt or a larger declared uncertainty budget. If no validated counterexample exists and formal verification is unproven, narrow the box or try the separately taught stronger bound solver. Do not silently change the network or data to manufacture a passed proof. Broader operating-domain verification requires additional networks and domain-specific properties.
%[text] ## Documentation and further reading
%[text] [Main AI verification documentation](https://www.mathworks.com/help/deeplearning/verification.html), [original MathWorks workshop](https://github.com/mathworks/ai-verification-workshop), and [formal robustness reference](https://www.mathworks.com/help/deeplearning/ref/verifynetworkrobustness.html).
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal syntax | Purpose |
%[text] | --- | --- | --- |
%[text] | [digitTrain4DArrayData / digitTest4DArrayData](https://www.mathworks.com/help/deeplearning/ref/findadversarialexamples.html) | [X,T] = digitTest4DArrayData | Shipped example data used by the official verification example |
%[text] | [trainnet](https://www.mathworks.com/help/deeplearning/ref/trainnet.html) | trainnet(X,T,layers,"crossentropy",options) | Train a modern classifier |
%[text] | [convolution2dLayer](https://www.mathworks.com/help/deeplearning/ref/nnet.cnn.layer.convolution2dlayer.html) | convolution2dLayer(3,8,Padding="same") | Small image feature extractor |
%[text] | [scores2label](https://www.mathworks.com/help/deeplearning/ref/scores2label.html) | scores2label(scores,classNames) | Convert output scores to actual labels |
%[text] | [adversarialOptions](https://www.mathworks.com/help/deeplearning/ref/adversarialoptions.html) | adversarialOptions("bim",NumIterations=10) | Explicit finite search budget |
%[text] | [findAdversarialExamples](https://www.mathworks.com/help/deeplearning/ref/findadversarialexamples.html) | [examples,mislabels,iX] = findAdversarialExamples(net,lower,upper,labels) | Find actual bounded counterexamples |
%[text] | [verifyNetworkRobustness](https://www.mathworks.com/help/deeplearning/ref/verifynetworkrobustness.html) | verifyNetworkRobustness(net,lower,upper,label) | Check the whole input region |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
