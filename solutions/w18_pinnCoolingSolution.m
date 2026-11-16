%[text] # Solution 18 — Physics-informed cooling neural network
%[text] **Goal:** Train an actual PINN for dy/dt = -y and y(0)=1, then assess it at unseen time coordinates. Open the training MATLAB Project in R2026b; Deep Learning Toolbox; CPU only; no downloaded assets; 25 minutes.
%[text] **Answer:** Use 500 Adam updates and equally weight the physics and boundary losses. The analytic exp(-t) trajectory is never used in the optimization objective; it is held back for validation.
project = requireTrainingProject;
rng(18,"twister");
numIterations = 500;
physicsWeight = 1;
learnRate = 0.01;
%%
%[text] ## Step 1: Define smooth neural prediction and physical coordinates
%[text] **Answer:** A small tanh network has differentiable time derivatives. Forty-one collocation coordinates sample the residual; these are inputs, not temperature labels.
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
%[text] ## Step 2: Inspect the actual loss implementation
%[text] **Answer:** `coolingPINNLoss` computes y-prime with `dlgradient(sum(prediction,"all"),time,EnableHigherDerivatives=true)`, then differentiates the combined residual and initial-condition loss with respect to `net.Learnables`. The retained higher-order differentiation is essential because the residual itself contains a derivative.
[initialLoss,~,initialPhysicsLoss,initialBoundaryLoss] = ...
    dlfeval(@coolingPINNLoss,pinn,collocationTime,physicsWeight);
initialLossValue = double(extractdata(initialLoss))
%%
%[text] ## Step 3: Optimize physical and boundary losses
for iteration = 1:numIterations
    [loss,gradients] = dlfeval(@coolingPINNLoss, ...
        pinn,collocationTime,physicsWeight);
    [pinn,averageGradient,averageSquaredGradient] = adamupdate( ...
        pinn,gradients,averageGradient,averageSquaredGradient, ...
        iteration,learnRate);
    lossHistory(iteration) = double(extractdata(loss));
end
finalTrainingLoss = lossHistory(end)
assert(finalTrainingLoss<initialLossValue,"PINN optimization did not reduce loss.");
%%
%[text] ## Step 4: Check the unseen trajectory, residual and initial condition
%[text] **Answer:** None of these midpoint coordinates was a training collocation point. Report three errors separately: trajectory RMSE versus the analytic reference, equation-residual RMSE, and initial-condition error. A 0.1 tolerance is an illustrative teaching check, not a battery safety requirement.
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
assert(all(isfinite(prediction)),"PINN prediction is nonfinite.");
assert(trajectoryRMSE<0.1,"Held-out cooling trajectory error is too large.");
assert(pinnMetrics.PhysicsResidualRMSE<0.1,"Physics residual is too large.");
assert(pinnMetrics.InitialConditionError<0.1,"Initial condition was not learned.");
plot(heldOutTime,reference,"-",heldOutTime,prediction,"o");
xlabel("Normalized time"); ylabel("Normalized excess temperature");
legend("Analytic reference (validation only)","Trained PINN"); grid on
%%
%[text] ## Step 5: Inspect training and preserve the trained model
%[text] **Answer:** Lower loss after more iterations supports convergence on this simple problem. It does not demonstrate generalization to an unknown forcing function or a different thermal domain.
semilogy(lossHistory); xlabel("Adam iteration"); ylabel("Combined PINN loss"); grid on
outputFolder = fullfile(project.RootFolder,"generated","models");
if ~isfolder(outputFolder), mkdir(outputFolder); end
save(fullfile(outputFolder,"coolingPINN.mat"),"pinn","pinnMetrics");
%%
%[text] ## Conclusion and troubleshooting
%[text] This is neural optimization driven by an equation and boundary information. It differs from fitting a coefficient inside a known analytic solution. The training loop exposes `forward`, `dlgradient`, `dlfeval`, and `adamupdate` directly. Keep validation coordinates separate and report the physical domain behind every claim.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/physics-informed-machine-learning.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`dlnetwork`](https://www.mathworks.com/help/deeplearning/ref/dlnetwork.html) | dlnetwork(layers) | Trained neural surrogate |
%[text] | [`dlarray`](https://www.mathworks.com/help/deeplearning/ref/dlarray.html) | dlarray(t,"CB") | Explicit channel/batch shape |
%[text] | [`forward`](https://www.mathworks.com/help/deeplearning/ref/pytorchmodel.forward.html) | forward(net,t) | Training-time differentiable prediction |
%[text] | [`dlgradient`](https://www.mathworks.com/help/deeplearning/ref/dlarray.dlgradient.html) | dlgradient(loss,net.Learnables) | Physics-loss parameter gradient |
%[text] | [`dlfeval`](https://www.mathworks.com/help/deeplearning/ref/dlfeval.html) | dlfeval(@coolingPINNLoss,net,t,w) | Automatic differentiation trace |
%[text] | [`adamupdate`](https://www.mathworks.com/help/deeplearning/ref/adamupdate.html) | adamupdate(net,gradients,avg,avgSq,k,lr) | Actual neural training step |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
