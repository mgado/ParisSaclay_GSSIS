%[text] # Solution 14: Physics-constrained cooling inference
%[text] **Goal:** Infer the cooling coefficient from sparse observations and verify physical behaviour on unsampled times. Open the training MATLAB Project and run sections in order. MATLAB R2026b; no hardware or external data; 12 minutes.
project = currentProject;
projectRoot = project.RootFolder;
%%
%[text] ## Step 1: State and sample the governing equation
%[text] Newton cooling gives `dT/dt = -alpha*(T-Tambient)`. Its analytic solution enforces the initial temperature. The observations below are noise-free illustrative data, not measured battery data.
ambient = 25;
initialTemperature = 45;
trueAlpha = 0.04;
observationTime = (0:10:60)';
observedTemperature = ambient+(initialTemperature-ambient)*exp(-trueAlpha*observationTime);
%%
%[text] ## Step 2: Fit a positive coefficient
%[text] **Answer:** Optimize `log(alpha)` to make negative cooling coefficients impossible. Starting at 0.15 should still recover approximately 0.04; the fit uses the physical solution, rather than an unconstrained polynomial.
initialGuess = 0.15;
loss = @(logAlpha) mean((ambient+(initialTemperature-ambient)*exp(-exp(logAlpha)*observationTime)-observedTemperature).^2);
logAlphaFit = fminsearch(loss,log(initialGuess),optimset("Display","off","TolX",1e-9));
alphaFit = exp(logAlphaFit)
assert(abs(alphaFit-trueAlpha)<1e-5,"Recovered cooling coefficient is inaccurate.");
%%
%[text] ## Step 3: Validate between observations
%[text] **Answer:** A positive coefficient makes this trajectory monotonically decrease towards ambient. The finite-difference derivative leaves a small interior residual even for an exact analytic trajectory; that residual is discretization error.
time = (0:1:60)';
prediction = ambient+(initialTemperature-ambient)*exp(-alphaFit*time);
temperatureSlope = gradient(prediction,time);
physicsResidual = temperatureSlope+alphaFit*(prediction-ambient);
interiorResidual = max(abs(physicsResidual(2:end-1)))
assert(all(prediction>=ambient & prediction<=initialTemperature),"Temperature bounds violated.");
assert(all(diff(prediction)<=0),"Cooling trajectory must be monotone.");
assert(interiorResidual<0.001,"Interior cooling residual is too large.");
plot(observationTime,observedTemperature,"o",time,prediction)
xlabel("Time (s)"); ylabel("Temperature (deg C)"); legend("Sparse observations","Physics-constrained fit"); grid on
%%
%[text] ## Step 4: PINN loss specification
%[text] **Answer:** A PINN would take time as input, predict temperature, compute its derivative through `dlgradient` within `dlfeval`, and minimize a weighted sum of measurement MSE, initial-condition MSE and ODE-residual MSE at collocation times. Use automatic differentiation with higher derivatives enabled when differentiating the derivative term with respect to network parameters. This script fits an analytic physics model; it does not train a PINN.
%[text] A neural PDE version adds spatial inputs and derivatives, boundary conditions and a sampling strategy. Use the linked physics-informed documentation for spatial PDE extensions. Check unseen time ranges and coefficient uncertainty independently of the training loss.
%%
%[text] ## Troubleshooting
%[text] If modified/noisy observations fail the parameter assertion, distinguish sensor uncertainty from optimizer failure. Lower the time step when evaluating the numerical residual. Retain the physical-bound and monotonicity checks even if the data-fit criterion is changed.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/physics-informed-machine-learning.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [`exp`](https://www.mathworks.com/help/matlab/ref/double.exp.html) | `T = Ta+(T0-Ta)*exp(-alpha*t)` | Physics: Analytic cooling trajectory | MATLAB |
%[text] | [`fminsearch`](https://www.mathworks.com/help/matlab/ref/fminsearch.html) | `p = fminsearch(loss,p0)` | Infer: Estimate unknown physics parameters | MATLAB |
%[text] | [`gradient`](https://www.mathworks.com/help/matlab/ref/gradient.html) | `dT = gradient(T,t)` | Check: Numerical ODE residual | MATLAB |
%[text] | [`dlfeval`](https://www.mathworks.com/help/deeplearning/ref/dlfeval.html), [`dlgradient`](https://www.mathworks.com/help/deeplearning/ref/dlarray.dlgradient.html) | Evaluate a traced loss and its derivatives | PINN extension: Network derivatives and training gradients | Deep Learning Toolbox |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
