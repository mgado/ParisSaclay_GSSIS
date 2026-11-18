%[text] # Solution 12: A model-based thermal ROM
%[text] **Goal:** Project a 20-state thermal model onto a snapshot basis and validate it using an unseen heat pulse. Open the training MATLAB Project and run sections in order. MATLAB R2026b; no hardware or external data. Allow 12 minutes.
project = currentProject;
projectRoot = project.RootFolder;
%%
%[text] ## Step 1: The full-order model
%[text] The model describes diffusion and cooling in an illustrative cell stack. Its states are temperature rises above coolant temperature; coefficients are not calibrated battery data.
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
%[text] ## Step 2: Select and project the basis
%[text] **Answer:** The singular-value energy gives a defensible initial order, but use at least three states here to allow comparison on a longer, unseen pulse. Snapshot energy is a training-data criterion; the held-out dynamics remain the acceptance check.
[basis,S,~] = svd(fullTrain,"econ");
energy = cumsum(diag(S).^2)/sum(diag(S).^2);
reducedOrder = max(3,find(energy>=0.999,1));
retainedEnergy = energy(reducedOrder)
V = basis(:,1:reducedOrder);
Ar = V'*A*V;
Br = V'*B;
%%
%[text] ## Step 3: Validate the new heat pulse
%[text] **Answer:** Integrate the projected equations with the same new input as the full-order model, then reconstruct physical temperatures. Comparing only `V*V'*fullTrain` would not test the reduced dynamics.
inputTest = double(time>5 & time<16);
fullTest = zeros(stateCount,numel(time));
reducedTest = zeros(reducedOrder,numel(time));
for k = 1:numel(time)-1
    fullTest(:,k+1) = fullTest(:,k) + timeStep*(A*fullTest(:,k) + B*inputTest(k));
    reducedTest(:,k+1) = reducedTest(:,k) + timeStep*(Ar*reducedTest(:,k) + Br*inputTest(k));
end
reconstructed = V*reducedTest;
relativeError = norm(fullTest-reconstructed,"fro")/norm(fullTest,"fro")
assert(relativeError<0.01,"The held-out temperature error exceeds 1%.");
plot(time,fullTest(10,:),time,reconstructed(10,:),"--")
xlabel("Time (s)"); ylabel("Temperature rise (deg C)"); legend("Full model","Projected ROM"); grid on
%%
%[text] ## Step 4: Engineering interpretation
%[text] The three-state solution should satisfy the 1% held-out relative-error requirement. Reducing state count changes computation, but this example does not measure execution time on a target. In a controller simulation, use the reduced matrices in a State-Space block and repeat system-level requirements with the same test inputs.
%[text] **Optional extension:** Compare model-based projection with a learned reduced-coordinate predictor under the same operating envelope. Keep training, validation and system-test scenarios distinct.
%%
%[text] ## Troubleshooting
%[text] Open the training Project if `currentProject` fails. If modified parameters fail the error assertion, inspect stability, snapshot coverage and the selected reduced order; keep the failure as evidence rather than loosening the requirement without justification.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/reduced-order-modeling.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [`currentProject`](https://www.mathworks.com/help/matlab/ref/currentproject.html) | `p = currentProject` | Project: Resolve the opened Project | MATLAB |
%[text] | [`svd`](https://www.mathworks.com/help/matlab/ref/double.svd.html) | `[U,S,V] = svd(X,"econ")` | Basis: Find dominant snapshot directions | MATLAB |
%[text] | [`Matrix multiplication`](https://www.mathworks.com/help/matlab/ref/double.mtimes.html) | `Ar = V'*A*V` | Projection: Project known equations | MATLAB |
%[text] | [`norm`](https://www.mathworks.com/help/matlab/ref/norm.html) | `norm(error,"fro")` | Acceptance: Measure held-out trajectory error | MATLAB |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
