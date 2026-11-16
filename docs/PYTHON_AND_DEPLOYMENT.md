# Python interoperability and deployment

## Three routes with different goals

| Goal | API route | Result and layout |
| --- | --- | --- |
| Execute a PyTorch model in Python from MATLAB | `pyTorchModel`, `forward` | Python wrapper; configure dimension transfer |
| Edit, train, compress or export layers in MATLAB | `importNetworkFromPyTorch` | Editable `dlnetwork`; validate conversion and input formats |
| Generate C/C++/CUDA directly from exported PyTorch | `loadPyTorchExportedProgram`, `invoke` | ExportedProgram; preserve PyTorch layout |

`pyTorchModel` is an R2026b addition. Direct exported-program loading/code
generation is available since R2026a; it is not newly introduced in R2026b.

## Execute the provided small example

Exercise 6 first transfers a scalar sensor observation with `pyrun` and checks
SOC = 0.5. Python must be configured; the script neither changes the interpreter
nor installs packages. Inspect `pyenv`; configure through the official workflow
if needed. Do not terminate an existing Python session without understanding
which user state would be lost.

When PyTorch is available, enable `runPyTorch` in exercise 6. The provided
`python/export_soc.py` exports a 1-by-3 input affine SOC model to `.pt2`.
It uses the known synthetic voltage law; it does not claim to train a network.

For direct deployment, with the training Project open:

```matlab
project = requireTrainingProject;
modelFile = fullfile(project.RootFolder,'generated','batterySOC.pt2');
input = single([3.55,1,25]);
model = loadPyTorchExportedProgram(modelFile);
output = invoke(model,input);
assert(abs(double(output)-0.5)<1e-5);
cfg = coder.config('mex');
codegen('-config',cfg,'invokeSOCModel', ...
    '-args',{coder.Constant(modelFile),input}, ...
    '-d',fullfile(project.RootFolder,'generated','codegen'));
generated = invokeSOCModel_mex(modelFile,input);
assert(max(abs(double(generated)-double(output)),[],'all')<1e-5);
```

Requires MATLAB Coder, the PyTorch/LiteRT model support package, a supported
compiler and the actual `.pt2` artifact. For images, the direct route retains
NCHW; do not silently feed MATLAB HWC data. `coder.Constant` fixes the model
path at compile time. Verify host MEX before making a production library.

## Hardware preflight

| Target | Required decisions and measurements |
| --- | --- |
| NVIDIA Jetson Thor | Exact OS/JetPack, CUDA/compiler/support compatibility, model operators, runtime assets, measured accuracy and latency |
| STM32F7 with LCD | Exact MCU/board, memory budget, operator support, cross compiler, sensor/LCD interfaces, PIL and timing measurements |
| Qualcomm board | Exact board/model/OS/architecture/toolchain first; use vendor-supported route after compatibility is established |

MATLAB Coder targets C/C++; GPU Coder targets CUDA; Embedded Coder supplies
embedded interfaces and optimization; Simulink Coder/Embedded Coder target
models; HDL Coder/Deep Learning HDL Toolbox address FPGA/ASIC workflows.
The algorithm, hardware and interface determine the route.

The supplied baseline MEX is host evidence. A successful build or prediction
does not prove physical deployment, real-time deadlines, PIL or HIL. Keep a
hardware run log with transfer, on-target execution, accuracy, timing and memory.
