%[text] # Workshop 12: A model-based thermal ROM
%[text] **Goal:** Replace a 20-state battery cooling model with a small projected model, then check whether its temperatures remain accurate on a new heat pulse.
%[text] **Prerequisites:** MATLAB R2026b; open the training MATLAB Project first. No hardware or downloaded data is needed. Allow 12 minutes. Launch this file in the Live Editor and use **Run Section**.
project = currentProject;
projectRoot = project.RootFolder;
%%
%[text] ## Step 1: Build the full-order thermal model
%[text] Twenty temperatures describe a simplified cell stack. Heat diffuses between neighbours and escapes to the coolant. These are illustrative coefficients, not a calibrated battery model. Forward Euler with a 0.1-second step is stable for these coefficients.
stateCount = 20;
timeStep = 0.1;
time = 0:timeStep:30;
A = -0.1*eye(stateCount) + 0.02*(diag(ones(stateCount-1,1),1) + diag(ones(stateCount-1,1),-1) - 2*eye(stateCount));
B = exp(-((1:stateCount)'-10).^2/12);
inputTrain = double(time<8);
fullTrain = zeros(stateCount,numel(time));
for k = 1:numel(time)-1
    fullTrain(:,k+1) = fullTrain(:,k) + timeStep*(A*fullTrain(:,k) + B*inputTrain(k));
end
%%
%[text] ## Step 2: Discover the important directions
%[text] **Exercise:** Inspect the cumulative snapshot energy. Change `reducedOrder` until at least 99.9% of the snapshot energy is retained. Hint 1: `svd` sorts singular values from largest to smallest. Hint 2: use the first index where cumulative energy exceeds 0.999.
[basis,S,~] = svd(fullTrain,"econ");
energy = cumsum(diag(S).^2)/sum(diag(S).^2);
reducedOrder = 1; % Change this value after inspecting energy.
retainedEnergy = energy(reducedOrder)
V = basis(:,1:reducedOrder);
Ar = V'*A*V;
Br = V'*B;
%%
%[text] ## Step 3: Test a heat pulse not used to build the basis
%[text] This is a model-based ROM: we project the known equations, rather than training a network to predict temperatures. **Exercise:** Set `reducedOrder` to 3 and compare the new pulse with the one-state result. Explain why snapshot energy alone is insufficient evidence for all possible inputs.
inputTest = double(time>5 & time<16);
fullTest = zeros(stateCount,numel(time));
reducedTest = zeros(reducedOrder,numel(time));
for k = 1:numel(time)-1
    fullTest(:,k+1) = fullTest(:,k) + timeStep*(A*fullTest(:,k) + B*inputTest(k));
    reducedTest(:,k+1) = reducedTest(:,k) + timeStep*(Ar*reducedTest(:,k) + Br*inputTest(k));
end
reconstructed = V*reducedTest;
relativeError = norm(fullTest-reconstructed,"fro")/norm(fullTest,"fro")
plot(time,fullTest(10,:),time,reconstructed(10,:),"--")
xlabel("Time (s)"); ylabel("Temperature rise (deg C)"); legend("Full model","Projected ROM"); grid on
%%
%[text] ## Step 4: Connect the ROM to the engineering workflow
%[text] Expected observation: three states reproduce the centre temperature much more accurately than one. The example checks a held-out pulse, not just reconstruction of training snapshots. A production workflow also checks boundary conditions, conservation, operating range, controller behaviour and computation cost. The reduced matrices can be represented with a State-Space block for system-level simulation.
%[text] **Optional extension:** Collect snapshots at multiple operating points, compare projected dynamics with a neural latent-state predictor, and check both against the same acceptance requirements. This script does not measure a hardware speedup.
%%
%[text] ## Troubleshooting
%[text] If `currentProject` reports that no Project is open, open the supplied training Project and rerun from Step 1. If the error increases after changing coefficients, check Euler stability and collect representative snapshots; increasing the retained energy threshold cannot repair missing operating conditions.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/reduced-order-modeling.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | Step | API or expression | Minimal syntax | Meaning |
%[text] | --- | --- | --- | --- |
%[text] | Project | [`currentProject`](https://www.mathworks.com/help/matlab/ref/currentproject.html) | `p = currentProject` | Resolve the opened Project |
%[text] | Basis | [`svd`](https://www.mathworks.com/help/matlab/ref/double.svd.html) | `[U,S,V] = svd(X,"econ")` | Find dominant snapshot directions |
%[text] | Projection | [`Matrix multiplication`](https://www.mathworks.com/help/matlab/ref/double.mtimes.html) | `Ar = V'*A*V` | Project known equations into reduced coordinates |
%[text] | Acceptance | [`norm`](https://www.mathworks.com/help/matlab/ref/norm.html) | `norm(error,"fro")` | Compare entire held-out trajectories |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
