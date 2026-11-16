%[text] # Workshop 13: Reduce an entire 3D temperature field
%[text] **Goal:** Represent a battery's 3D temperature field using a few spatial modes, reconstruct unseen operating points and distinguish field compression from prediction.
%[text] **Prerequisites:** MATLAB R2026b; open the training MATLAB Project. No hardware, mesh download or toolbox is needed for the basic path. Allow 15 minutes. Open this file in the Live Editor and use **Run Section**.
project = currentProject;
projectRoot = project.RootFolder;
%%
%[text] ## Step 1: Create illustrative thermal snapshots
%[text] A snapshot is one complete spatial field. These 1,000-node fields are synthetic combinations of three spatial patterns, not results of a solved PDE. Heating intensity and cooling setting are the input parameters; temperatures are in deg C.
[x,y,z] = ndgrid(linspace(-1,1,10));
spatialModes = [exp(-3*(x(:).^2+y(:).^2)), x(:).*exp(-2*z(:).^2), y(:).*z(:)];
heating = linspace(0.1,1,30);
cooling = 0.5+0.2*sin(2*pi*heating);
coefficients = [10*heating; 3*heating.^2./cooling; 0.4*cos(pi*heating)];
snapshots = 25+spatialModes*coefficients;
trainIndex = 1:2:30;
testIndex = 2:2:30;
%%
%[text] ## Step 2: Learn a field basis without seeing test snapshots
%[text] **Exercise:** Begin with one retained mode, then increase `modeCount` to three. What changes in storage and reconstruction error? Hint 1: mean-centre using training fields only. Hint 2: columns of `U` are spatial modes; do not compute the basis from all snapshots.
meanField = mean(snapshots(:,trainIndex),2);
[U,S,~] = svd(snapshots(:,trainIndex)-meanField,"econ");
modeCount = 1; % Change to 3 and compare the held-out error.
basis = U(:,1:modeCount);
latentTest = basis'*(snapshots(:,testIndex)-meanField);
reconstructed = meanField+basis*latentTest;
relativeError = norm(reconstructed-snapshots(:,testIndex),"fro")/norm(snapshots(:,testIndex)-meanField,"fro")
storedFractionPerField = modeCount/numel(x)
%%
%[text] ## Step 3: Inspect a held-out spatial field
%[text] The plot shows one reconstructed field. **Exercise:** Colour the nodes by the reconstruction error instead of temperature. Hint: compare the first test snapshot with `reconstructed(:,1)`. Expected observation: three modes reconstruct this synthetic rank-three family to numerical precision.
scatter3(x(:),y(:),z(:),18,reconstructed(:,1),"filled")
axis equal; colorbar; title("Reconstructed held-out temperature field")
xlabel("x"); ylabel("y"); zlabel("z")
%%
%[text] ## Step 4: Connect compression to an AI-based ROM
%[text] This path demonstrates **field compression**, not a predictive AI model: `latentTest` uses the known test field. To predict fields without that field, train a regression network from heating/cooling parameters to the training latent coefficients, infer held-out coefficients and reconstruct with the same basis. Check prediction error separately from projection error.
%[text] **Command-line delivery:** No public full-field ROM app is assumed. Use the POD workflow here and the parameter-to-field AI predictor in exercise 19. Real full-field data still needs consistent mesh coordinates, snapshot order, units and parameter metadata.
%%
%[text] ## Troubleshooting
%[text] Open the training Project if no Project is active. If additional spatial patterns are introduced, three modes may no longer suffice. The storage fraction above excludes the shared mean field and basis; include those once when comparing total archive sizes.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/deeplearning/reduced-order-modeling.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | Step | API or expression | Minimal syntax | Meaning |
%[text] | --- | --- | --- | --- |
%[text] | Grid | [`ndgrid`](https://www.mathworks.com/help/matlab/ref/ndgrid.html) | `[x,y,z] = ndgrid(grid)` | Keep spatial coordinates with fields |
%[text] | Basis | [`svd`](https://www.mathworks.com/help/matlab/ref/double.svd.html) | `[U,S,V] = svd(X,"econ")` | Extract spatial POD modes |
%[text] | Encoding | [`Matrix projection`](https://www.mathworks.com/help/matlab/ref/double.mtimes.html) | `a = basis'*(field-meanField)` | Encode a known field |
%[text] | Decoding | [`Matrix reconstruction`](https://www.mathworks.com/help/matlab/ref/double.mtimes.html) | `field = meanField+basis*a` | Reconstruct the full field |
%[text] | Inspection | [`scatter3`](https://www.mathworks.com/help/matlab/ref/scatter3.html) | `scatter3(x,y,z,18,T,"filled")` | Display spatial temperature |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
