%[text] # 06 — MATLAB–Python interoperability and third-party AI — Solution
%[text] **Goal:** Separate Python execution, editable network import and direct PyTorch code generation.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: MATLAB; Python; optional PyTorch and converter support. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(6,true). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable plus optional Python/PyTorch. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Exchange one sensor reading with Python. If PyTorch is available, export the provided model, import it, and compare the same input numerically.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Worked reasoning:** The Python scalar calculation must return 0.5. Import and direct deployment are different routes with different object types and data layouts. Missing torch is unavailable evidence, not a MATLAB interoperability failure.
project = requireTrainingProject;
%%
%[text] ## Call Python with explicit values
%[text] Python must be configured with a supported interpreter. This activity does not install packages or change an existing Python environment. Use pyenv to inspect it first.
environment = pyenv
runPython = environment.Status == "Loaded";
if runPython
    pythonSOC = pyrun("soc = (volts - 3 + 0.05*amps - 0.002*(temp-25))/1.2", ...
        "soc",volts=3.55,amps=1,temp=25);
    observed = double(pythonSOC)
    assert(abs(observed-0.5) < 1e-12);
else
    disp("Python exercise unavailable until a supported interpreter is configured.");
end
%%
%[text] ## Export a small PyTorch model
%[text] Set runPyTorch true only after torch is available in the configured Python. The supplied Python file uses torch.export.export and saves a .pt2 exported program. It is an analytic pretrained teaching model, not a training claim.
runPyTorch = false;
modelFile = fullfile(project.RootFolder,'generated','batterySOC.pt2');
if runPyTorch
    pyrunfile(fullfile(project.RootFolder,'python','export_soc.py'),output_path=string(modelFile));
    importedNet = importNetworkFromPyTorch(modelFile);
    disp(importedNet);
end
%%
%[text] ## Distinguish the three routes
%[text] R2026b pyTorchModel keeps execution in Python; importNetworkFromPyTorch creates an editable dlnetwork; loadPyTorchExportedProgram plus invoke keeps the exported program for code generation (available since R2026a). See PYTHON_AND_DEPLOYMENT.md for layouts and exact prerequisite checks.
routes = ["Python execution: pyTorchModel";"Editable MATLAB network: importNetworkFromPyTorch";"Direct code generation: loadPyTorchExportedProgram and invoke"]
disp(routes)
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/matlab/matlab_external/ways-to-call-python-from-matlab.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`pyenv`](https://www.mathworks.com/help/matlab/ref/pyenv.html) | [`pyenv`](https://www.mathworks.com/help/matlab/ref/pyenv.html) | Inspect interpreter |
%[text] | [`pyrun`](https://www.mathworks.com/help/matlab/ref/pyrun.html) | pyrun(code,output,...) | Exchange data |
%[text] | [`pyrunfile`](https://www.mathworks.com/help/matlab/ref/pyrunfile.html) | pyrunfile(script,...) | Run explicit Python source |
%[text] | [`importNetworkFromPyTorch`](https://www.mathworks.com/help/deeplearning/ref/importnetworkfrompytorch.html) | importNetworkFromPyTorch(file) | Import editable network |
%[text] | [`loadPyTorchExportedProgram`](https://www.mathworks.com/help/coder/ref/loadpytorchexportedprogram.html) | loadPyTorchExportedProgram(file) | Load direct deployment model |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
