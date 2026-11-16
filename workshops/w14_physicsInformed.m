%[text] # Workshop 14: Physics-informed cooling and an inverse problem
%[text] **Goal:** Infer a cooling coefficient from a few temperature observations, then test the fitted trajectory against the governing equation. Relate this small example to physics-informed neural networks.
%[text] **Prerequisites:** MATLAB R2026b; open the training MATLAB Project. Basic path uses MATLAB only, with no downloaded model or hardware. Allow 12 minutes. Launch in the Live Editor and use **Run Section**.
project = currentProject;
projectRoot = project.RootFolder;
%%
%[text] ## Step 1: State the physics before fitting data
%[text] Newton cooling gives `dT/dt = -alpha*(T-Tambient)`. The initial temperature is 45 deg C and ambient is 25 deg C. We generate noise-free illustrative observations with `alpha = 0.04` per second. In a real inverse problem, alpha is unknown and sensor uncertainty must be included.
ambient = 25;
initialTemperature = 45;
trueAlpha = 0.04;
observationTime = (0:10:60)';
observedTemperature = ambient+(initialTemperature-ambient)*exp(-trueAlpha*observationTime);
%%
%[text] ## Step 2: Infer the unknown coefficient
%[text] **Exercise:** Change the initial guess and confirm that the fitted coefficient remains close to 0.04. Hint 1: optimize the logarithm of alpha so the inferred cooling coefficient stays positive. Hint 2: the analytic physics solution already enforces the initial condition; only alpha remains to estimate.
initialGuess = 0.15; % Try 0.005 and 0.5.
loss = @(logAlpha) mean((ambient+(initialTemperature-ambient)*exp(-exp(logAlpha)*observationTime)-observedTemperature).^2);
logAlphaFit = fminsearch(loss,log(initialGuess),optimset("Display","off"));
alphaFit = exp(logAlphaFit)
%%
%[text] ## Step 3: Test the physics on unsampled times
%[text] **Exercise:** Predict temperatures every second and inspect the energy-balance residual. Why should the temperature stay between ambient and its initial value? Hint: compare a finite-difference slope with `-alphaFit*(T-ambient)`; the boundary derivative has a larger discretization error.
time = (0:1:60)';
prediction = ambient+(initialTemperature-ambient)*exp(-alphaFit*time);
temperatureSlope = gradient(prediction,time);
physicsResidual = temperatureSlope+alphaFit*(prediction-ambient);
interiorResidual = max(abs(physicsResidual(2:end-1)))
plot(observationTime,observedTemperature,"o",time,prediction)
xlabel("Time (s)"); ylabel("Temperature (deg C)"); legend("Sparse observations","Physics-constrained fit"); grid on
%%
%[text] ## Step 4: Extend the same idea to PINNs and neural PDE solvers
%[text] This worked path is a physics-constrained parameter fit, **not a trained PINN**. For a PINN, replace the analytic trajectory with a `dlnetwork` taking time as input, use `dlfeval` and `dlgradient` to calculate its time derivative, and minimize data error, ODE residual and initial-condition error together. A neural PDE solver also requires spatial derivatives, boundary conditions and mesh/domain sampling.
%[text] **Optional exercise:** Write a PINN loss specification before training: identify the network input/output, collocation times, measured-data term, initial-condition term and ODE residual. Explain how a low training loss can still hide errors outside the sampled time range. Follow the instructor's original PINN/PDE examples for the full training implementation.
%%
%[text] ## Troubleshooting
%[text] Open the training Project if `currentProject` fails. Noise or a misspecified model may change the inferred coefficient. A finite-difference residual is a numerical check, not proof of the differential equation everywhere. Reduce the time step to separate discretization error from model error.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/physics-informed-machine-learning.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | Step | API | Minimal syntax | Meaning |
%[text] | --- | --- | --- | --- |
%[text] | Physics | [`exp`](https://www.mathworks.com/help/matlab/ref/double.exp.html) | `T = Ta+(T0-Ta)*exp(-alpha*t)` | Analytic cooling trajectory |
%[text] | Infer | [`fminsearch`](https://www.mathworks.com/help/matlab/ref/fminsearch.html) | `p = fminsearch(loss,p0)` | Estimate an unknown coefficient |
%[text] | Check | [`gradient`](https://www.mathworks.com/help/matlab/ref/gradient.html) | `dT = gradient(T,t)` | Numerical derivative for residual testing |
%[text] | PINN extension | [`dlfeval`](https://www.mathworks.com/help/deeplearning/ref/dlfeval.html), [`dlgradient`](https://www.mathworks.com/help/deeplearning/ref/dlarray.dlgradient.html) | Evaluate a traced loss and its derivatives | Differentiate a network-defined trajectory |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
