%[text] # 08 — Test and formally bound an AI estimator — Solution
%[text] **Goal:** Distinguish sampled tests from guarantees over a specified input box.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: Deep Learning Toolbox; AI Verification Library. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(8,true). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Increase voltage perturbation from 0.002 to 0.02 V and observe whether the output bounds widen. State exactly what property is proved.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Worked reasoning:** The half-width is 0.0033333 SOC; bounds should be near [0.4966667,0.5033333]. These prove a local output-range property for the affine network, not accuracy versus unknown physical truth or global closed-loop stability.
project = requireTrainingProject;
%%
%[text] ## Use an exactly understood neural baseline
%[text] This one-layer network represents the synthetic analytic SOC relation before clamping. We verify a small input box; it is deliberately easy to explain and can be checked analytically. Verification of a trained nonlinear network is an extension.
inputLayer = featureInputLayer(3,Normalization="none");
outputLayer = fullyConnectedLayer(1);
outputLayer.Weights = single([1/1.2,0.05/1.2,-0.002/1.2]);
outputLayer.Bias = single((-3+0.002*25)/1.2);
linearNet = dlnetwork([inputLayer;outputLayer]);
center = single([3.55;1;25]);
delta = single([0.002;0.02;0.5]);
lowerInput = dlarray(center-delta,'CB');
upperInput = dlarray(center+delta,'CB');
%%
%[text] ## Compute bounds over the whole box
%[text] Output bounds apply only to this network, input normalization and box. A verified box is not a safety certificate for an entire closed-loop battery system.
[lowerBound,upperBound] = estimateNetworkOutputBounds(linearNet,lowerInput,upperInput,ExecutionEnvironment="cpu");
bounds = [double(extractdata(lowerBound)),double(extractdata(upperBound))]
assert(bounds(1)>0.49 && bounds(2)<0.51);
analyticHalfWidth = sum(abs([1/1.2,0.05/1.2,-0.002/1.2]).*double(delta'))
assert(abs(bounds(1)-(0.5-analyticHalfWidth))<1e-5);
%%
%[text] ## Locate the R2026b additions
%[text] The refresh guide records official release evidence: expanded convolution/recurrent verification support and distribution-discriminator data types in R2026b; direct ONNX/PyTorch verification was already R2026a. Original local robustness and ACAS global-stability workshops are advanced reuse, with explicit missing-model prerequisites.
disp("A sample test checks points. A sound bound encloses every network output in the specified box.");
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/verification.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`dlnetwork`](https://www.mathworks.com/help/deeplearning/ref/dlnetwork.html) | dlnetwork(layers) | Explicit verified network |
%[text] | [`dlarray`](https://www.mathworks.com/help/deeplearning/ref/dlarray.html) | dlarray(X,'CB') | Label feature and batch dimensions |
%[text] | [`estimateNetworkOutputBounds`](https://www.mathworks.com/help/deeplearning/ref/estimatenetworkoutputbounds.html) | estimateNetworkOutputBounds(net,lower,upper) | Formal regression bounds |
%[text] | [`verifyNetworkRobustness`](https://www.mathworks.com/help/deeplearning/ref/verifynetworkrobustness.html) | verifyNetworkRobustness(net,lower,upper,label) | Classification robustness |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
