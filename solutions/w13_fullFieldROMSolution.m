%[text] # Solution 13: Full-field temperature compression
%[text] **Goal:** Build a spatial POD basis from training fields, measure held-out reconstruction error and explain the additional step needed for AI field prediction. Open the training MATLAB Project and run sections in order. MATLAB R2026b; no external data or hardware; 15 minutes.
project = currentProject;
projectRoot = project.RootFolder;
%%
%[text] ## Step 1: Define the synthetic field family
%[text] These fields are deliberately rank-three combinations of spatial patterns. They illustrate data organization and compression; they are not a validated battery PDE solution.
[x,y,z] = ndgrid(linspace(-1,1,10));
spatialModes = [exp(-3*(x(:).^2+y(:).^2)), x(:).*exp(-2*z(:).^2), y(:).*z(:)];
heating = linspace(0.1,1,30);
cooling = 0.5+0.2*sin(2*pi*heating);
coefficients = [10*heating; 3*heating.^2./cooling; 0.4*cos(pi*heating)];
snapshots = 25+spatialModes*coefficients;
trainIndex = 1:2:30;
testIndex = 2:2:30;
%%
%[text] ## Step 2: Keep three modes and measure the held-out error
%[text] **Answer:** Fit the mean and basis using training snapshots only. Three modes span this field family. The coefficients of a new field are obtained by projection, so this stage is an encoder/decoder evaluation rather than a predictive surrogate evaluation.
meanField = mean(snapshots(:,trainIndex),2);
[U,S,~] = svd(snapshots(:,trainIndex)-meanField,"econ");
modeCount = 3;
basis = U(:,1:modeCount);
latentTest = basis'*(snapshots(:,testIndex)-meanField);
reconstructed = meanField+basis*latentTest;
relativeError = norm(reconstructed-snapshots(:,testIndex),"fro")/norm(snapshots(:,testIndex)-meanField,"fro")
storedFractionPerField = modeCount/numel(x)
assert(relativeError<1e-10,"The rank-three field reconstruction should be exact to floating-point precision.");
%%
%[text] ## Step 3: Plot reconstruction error in space
%[text] **Answer:** Colour by error, not reconstructed temperature. The error should be close to machine precision. With one mode, the spatial residual reveals missing patterns even if a global metric looks small.
fieldError = reconstructed(:,1)-snapshots(:,testIndex(1));
scatter3(x(:),y(:),z(:),18,fieldError,"filled")
axis equal; colorbar; title("Held-out field reconstruction error (deg C)")
xlabel("x"); ylabel("y"); zlabel("z")
%%
%[text] ## Step 4: Separate encoding from AI prediction
%[text] A predictive ROM requires a model mapping input parameters to latent coefficients without access to the held-out temperature field. Train only on training parameters/coefficients, predict on test parameters, decode with this fixed basis and measure the total field-prediction error. For time-dependent systems, include state/history rather than assuming two instantaneous parameters uniquely determine a field.
%[text] **Command-line delivery:** No public full-field ROM app is assumed. Use the POD workflow here and the parameter-to-field AI predictor in exercise 19. Real full-field data still needs consistent mesh coordinates, snapshot order, units and parameter metadata.
%%
%[text] ## Troubleshooting
%[text] If modified data contains more independent spatial patterns, increase the basis rank and validate it. Count the shared mean and basis when estimating total storage; `storedFractionPerField` counts only per-snapshot coefficients.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/reduced-order-modeling.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | Step | API or expression | Minimal syntax | Meaning |
%[text] | --- | --- | --- | --- |
%[text] | Grid | [`ndgrid`](https://www.mathworks.com/help/matlab/ref/ndgrid.html) | `[x,y,z] = ndgrid(grid)` | Spatial coordinates |
%[text] | Basis | [`svd`](https://www.mathworks.com/help/matlab/ref/double.svd.html) | `[U,S,V] = svd(X,"econ")` | POD spatial modes |
%[text] | Encode | [`Matrix projection`](https://www.mathworks.com/help/matlab/ref/double.mtimes.html) | `a = basis'*(field-meanField)` | Encode a known field |
%[text] | Decode | [`Matrix reconstruction`](https://www.mathworks.com/help/matlab/ref/double.mtimes.html) | `field = meanField+basis*a` | Reconstruct the full field |
%[text] | Inspect | [`scatter3`](https://www.mathworks.com/help/matlab/ref/scatter3.html) | `scatter3(x,y,z,18,error,"filled")` | Locate spatial error |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
