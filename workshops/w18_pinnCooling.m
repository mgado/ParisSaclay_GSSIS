%[text] # 18 — Train a real physics-informed cooling network
%[text] **Goal:** Train a neural network from a differential equation and one initial condition, without measured trajectory labels.
%[text] **Prerequisites:** Open the training MATLAB Project in R2026b. Products: MATLAB and Deep Learning Toolbox. CPU only; no external data or hardware. Estimated time: 25 minutes.
%[text] **Launch:** Open this file in the Live Editor and run sections in order. The helper `coolingPINNLoss` is project-owned; inspect it when prompted.
%[text] **Your task:** Compare 300 and 500 Adam iterations, or change `physicsWeight` from 0.5 to 1. Measure held-out trajectory error, residual loss, and the initial-condition error separately.
%[text] **Hint 1:** The network sees time coordinates and the laws `dy/dt + y = 0`, `y(0)=1`. The analytic solution is used only after training for validation.
%[text] **Hint 2:** `EnableHigherDerivatives=true` keeps the input-derivative computation differentiable with respect to network parameters. Omitting it prevents the physics residual from training the network correctly.
project = requireTrainingProject;
rng(18,"twister");
numIterations = 300;
physicsWeight = 0.5;
learnRate = 0.01;
%%
%[text] ## Step 1: Create the network and collocation points
%[text] The scalar output is normalized excess temperature: 1 initially and 0 at ambient. Forty-one time coordinates sample the governing equation. No target temperatures are supplied to this training loop.
layers = [featureInputLayer(1,Normalization="none",Name="time")
    fullyConnectedLayer(16,Name="hidden")
    tanhLayer(Name="smoothActivation")
    fullyConnectedLayer(1,Name="temperature")];
pinn = dlnetwork(layers);
collocationTime = dlarray(single(linspace(0,1,41)),"CB");
averageGradient = [];
averageSquaredGradient = [];
lossHistory = zeros(numIterations,1);
%%
%[text] ## Step 2: Understand the physics loss
%[text] Open `coolingPINNLoss.m` from the project source. `forward` predicts y, `dlgradient` differentiates it with respect to time, and the residual is y-prime + y. The initial-condition penalty is (y(0)-1) squared. `dlfeval` traces this computation so the final parameter gradients include the derivative term.
%[text] The custom loop is justified here because the loss contains a derivative with respect to the network input. We are not fitting the analytic solution with a regression loss.
[initialLoss,~,initialPhysicsLoss,initialBoundaryLoss] = ...
    dlfeval(@coolingPINNLoss,pinn,collocationTime,physicsWeight);
initialLossValue = double(extractdata(initialLoss))
%%
%[text] ## Step 3: Train with Adam
%[text] All 41 collocation points form a small batch on every iteration. `adamupdate` changes learnable weights using gradients of the combined physical and initial-condition loss. Compare one changed setting at a time.
for iteration = 1:numIterations
    [loss,gradients] = dlfeval(@coolingPINNLoss, ...
        pinn,collocationTime,physicsWeight);
    [pinn,averageGradient,averageSquaredGradient] = adamupdate( ...
        pinn,gradients,averageGradient,averageSquaredGradient, ...
        iteration,learnRate);
    lossHistory(iteration) = double(extractdata(loss));
end
finalTrainingLoss = lossHistory(end)
%%
%[text] ## Step 4: Validate at unsampled times
%[text] Midpoints below were not training coordinates. Only now do we compute exp(-t), the analytic reference. A low differential-equation residual and a good initial condition support the model; compare them with the held-out error rather than treating either as a universal guarantee.
heldOutTime = (0.0125:0.025:0.9875)';
testTime = dlarray(single(heldOutTime'),"CB");
prediction = double(extractdata(predict(pinn,testTime)))';
reference = exp(-heldOutTime);
trajectoryRMSE = sqrt(mean((prediction-reference).^2));
[~,~,heldOutPhysicsLoss,boundaryLoss] = ...
    dlfeval(@coolingPINNLoss,pinn,testTime,physicsWeight);
pinnMetrics = struct("Iterations",numIterations, ...
    "PhysicsWeight",physicsWeight,"TrajectoryRMSE",trajectoryRMSE, ...
    "PhysicsResidualRMSE",sqrt(double(extractdata(heldOutPhysicsLoss))), ...
    "InitialConditionError",sqrt(double(extractdata(boundaryLoss))))
plot(heldOutTime,reference,"-",heldOutTime,prediction,"o");
xlabel("Normalized time"); ylabel("Normalized excess temperature");
legend("Analytic reference (validation only)","Trained PINN"); grid on
%%
%[text] ## Optional: Inspect optimization and save the model
%[text] The loss curve helps distinguish insufficient optimization from a physical modelling error. A good fit on this one-dimensional interval does not establish accurate behaviour outside it, under unknown heat sources, or for the full battery thermal model.
semilogy(lossHistory); xlabel("Adam iteration"); ylabel("Combined PINN loss"); grid on
outputFolder = fullfile(project.RootFolder,"generated","models");
if ~isfolder(outputFolder), mkdir(outputFolder); end
save(fullfile(outputFolder,"coolingPINN.mat"),"pinn","pinnMetrics");
%%
%[text] ## Troubleshooting and takeaway
%[text] If the physics loss barely changes, inspect the retained higher-derivative trace and input format. If the initial condition is poor, compare the weighting of the two terms. Keep the 16-unit smooth tanh network for the first run. This lesson trains a neural differential-equation surrogate; the earlier analytic-coefficient example solves a different problem.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/physics-informed-machine-learning.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text] Project setup uses [requireTrainingProject](../src/requireTrainingProject.m), a training helper using MATLAB Project APIs.
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [`dlnetwork`](https://www.mathworks.com/help/deeplearning/ref/dlnetwork.html) | dlnetwork(layers) | Learnable smooth surrogate | Deep Learning Toolbox |
%[text] | [`dlarray`](https://www.mathworks.com/help/deeplearning/ref/dlarray.html) | dlarray(t,"CB") | Feature and batch format | Deep Learning Toolbox |
%[text] | [`forward`](https://www.mathworks.com/help/deeplearning/ref/dlnetwork.forward.html) | forward(net,t) | Differentiable training prediction | Deep Learning Toolbox |
%[text] | [`dlgradient`](https://www.mathworks.com/help/deeplearning/ref/dlarray.dlgradient.html) | dlgradient(sum(y,"all"),t,EnableHigherDerivatives=true) | Retain differentiable time derivative | Deep Learning Toolbox |
%[text] | [`dlfeval`](https://www.mathworks.com/help/deeplearning/ref/dlfeval.html) | dlfeval(@coolingPINNLoss,net,t,w) | Trace custom physics loss | Deep Learning Toolbox |
%[text] | [`adamupdate`](https://www.mathworks.com/help/deeplearning/ref/adamupdate.html) | adamupdate(net,gradients,avg,avgSq,iteration,rate) | Apply parameter update | Deep Learning Toolbox |
%[text] | [`coolingPINNLoss`](../src/coolingPINNLoss.m) | `dlfeval(@coolingPINNLoss,net,t,w)` | Provide the custom cooling physics/data loss | Training helper (Deep Learning Toolbox) |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
