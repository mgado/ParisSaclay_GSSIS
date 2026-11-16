function [loss,gradients,physicsLoss,boundaryLoss] = coolingPINNLoss(net,time,physicsWeight)
%coolingPINNLoss Compute cooling PINN loss and parameter gradients.
%   [loss,gradients,physicsLoss,boundaryLoss] =
%   coolingPINNLoss(net,time,physicsWeight) enforces dy/dt = -y and
%   y(0) = 1. Call this function through dlfeval. time is a formatted
%   dlarray with one feature channel and one batch dimension.
%
%   See also dlfeval, dlgradient, adamupdate, dlnetwork

prediction = forward(net,time);
derivative = dlgradient(sum(prediction,"all"),time, ...
    EnableHigherDerivatives=true);
residual = derivative + prediction;
physicsLoss = mean(residual.^2,"all");
initialTime = dlarray(single(0),"CB");
initialPrediction = forward(net,initialTime);
boundaryLoss = (initialPrediction-1).^2;
loss = physicsWeight*physicsLoss + boundaryLoss;
gradients = dlgradient(loss,net.Learnables);
end
