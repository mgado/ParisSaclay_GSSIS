%[text] # 11 — Generate and verify code before hardware deployment
%[text] **Goal:** Compile the analytic virtual-sensor baseline and compare host numerics.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: MATLAB Coder; selected C compiler; optional target support. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(11). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Generate a MEX, compare nominal and boundary values, inspect generated C source, then choose the correct deployment route for Jetson, STM32F7 and Qualcomm.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Before opening the solution:** Record your parameter change, observed result, and engineering conclusion.
project = requireTrainingProject;
%%
%[text] ## Generate host MEX
%[text] The baseline function is explicitly code-generation-ready. This is an executed host equivalence check, not a claim that the neural model has been deployed to a board.
buildFolder = fullfile(project.RootFolder,'generated','codegen');
if ~isfolder(buildFolder), mkdir(buildFolder); end
configuration = coder.config('mex');
codegen('-config',configuration,'socEstimate','-args',{0,0,0},'-d',buildFolder);
disp(buildFolder);
%%
%[text] ## Compare the generated function
%[text] Project registration puts generated/codegen on the path. Compare a nominal point and a saturation boundary; use actual observed error.
matlabValue = socEstimate(3.55,1,25);
generatedValue = socEstimate_mex(3.55,1,25)
assert(abs(matlabValue-generatedValue)<1e-12);
assert(socEstimate_mex(5,0,25)==1);
%%
%[text] ## Choose the AI deployment path
%[text] For a PyTorch exported program use loadPyTorchExportedProgram/invoke and coder.Constant; for an editable dlnetwork use MATLAB/GPU Coder network deployment workflows. Direct .pt2 code generation arrived in R2026a. PYTHON_AND_DEPLOYMENT.md contains the provided entry point and target preflight checklist.
targets = ["Jetson Thor: CUDA/toolchain/support compatibility and runtime assets";"STM32F7 LCD: MCU resources, supported neural operators, board IO";"Qualcomm: identify exact board, OS, architecture and supported toolchain"]
disp(targets)
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require a configured compatible target. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/coder/). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text] Project setup uses [requireTrainingProject](../src/requireTrainingProject.m), a training helper using MATLAB Project APIs.
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [`coder.config`](https://www.mathworks.com/help/coder/ref/coder.config.html) | coder.config('mex') | Host code generation configuration | MATLAB Coder |
%[text] | [`codegen`](https://www.mathworks.com/help/coder/ref/codegen.html) | codegen(...,'-args',{0,0,0}) | Compile fixed input types | MATLAB Coder |
%[text] | [`coder.Constant`](https://www.mathworks.com/help/coder/ref/coder.type-class.html) | coder.Constant(modelFile) | Compile-time AI model path | MATLAB Coder |
%[text] | [`invoke`](https://www.mathworks.com/help/coder/ref/pytorchexportedprogram.invoke.html) | invoke(exportedProgram,X) | Direct PyTorch inference | MATLAB Coder + PyTorch/LiteRT support package |
%[text] | [`socEstimate`](../src/socEstimate.m) | `socEstimate(V,I,T)` | Evaluate the provided analytic SOC baseline | Training helper (MATLAB) |
%[text] | [`socEstimate_mex`](https://www.mathworks.com/help/coder/ref/codegen.html) | `socEstimate_mex(V,I,T)` | Execute the generated analytic MEX | Generated MEX interface (MATLAB Coder) |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
