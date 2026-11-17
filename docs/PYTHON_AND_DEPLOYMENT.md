# MATLAB, Python and AI deployment

Open `openExercise("w06_pythonImport")` and run one section at a time.
Use `pyenv` to inspect the Python interpreter. A supported interpreter and the
packages required by the selected path must be available before enabling it.

## Choose the route by your goal

| Goal | APIs | Result |
| --- | --- | --- |
| Execute a PyTorch model in Python from MATLAB | `pyTorchModel`, `forward` | Python-backed model with explicit dimension transfer |
| Edit, train or compress the network in MATLAB | `importNetworkFromPyTorch` | Editable `dlnetwork` |
| Generate C/C++/CUDA from an exported model | `loadPyTorchExportedProgram`, `invoke` | Exported-program inference and code generation |

These object types and input layouts differ. Verify numerical agreement before
switching routes. For direct image inference preserve PyTorch's **NCHW** layout;
do not pass MATLAB HWC data without the documented permutation.

## Start with one sensor observation

Exercise 6 transfers voltage, current and temperature through `pyrun`.
The supplied example uses **3.55 V, 1 A, 25 C** and expects **SOC = 0.5**.
This checks data exchange; it is not hardware deployment.

When PyTorch is available, enable the export/import section. The included
`python/export_soc.py` produces a `.pt2` affine sensor model with one 1-by-3
input. Its values implement the teaching voltage relation rather than a trained
battery model.

## Verify direct inference and generated code

After creating `generated/batterySOC.pt2`, use the same input on both paths:

```matlab
project = requireTrainingProject;
modelFile = fullfile(project.RootFolder,'generated','batterySOC.pt2');
input = single([3.55,1,25]);
model = loadPyTorchExportedProgram(modelFile);
output = invoke(model,input);
assert(abs(double(output)-0.5)<1e-5);
configuration = coder.config('mex');
codegen('-config',configuration,'invokeSOCModel', ...
    '-args',{coder.Constant(modelFile),input}, ...
    '-d',fullfile(project.RootFolder,'generated','codegen'));
generated = invokeSOCModel_mex(modelFile,input);
assert(max(abs(double(generated)-double(output)),[],'all')<1e-5);
```

Requires MATLAB Coder, the PyTorch/LiteRT model support package and a supported
compiler. `coder.Constant` fixes the model path during compilation. A successful
host MEX establishes generated-code agreement for these inputs; PIL executes on
an actual processor and needs its supported target configuration.

## Choose deployment tools

| Target/use | Main considerations |
| --- | --- |
| Raspberry Pi | Supported OS/architecture, connection, input scaling and actual PIL comparison |
| NVIDIA Jetson Thor | Compatible CUDA/cuDNN/toolchain, operator support and runtime assets |
| STM32F7 | Exact MCU, RAM/flash budget, supported operators and sensor/display interfaces |
| Qualcomm | Exact board/OS/architecture and supported vendor toolchain |

MATLAB Coder generates C/C++; GPU Coder generates CUDA; Embedded Coder supports
embedded interfaces and optimization. Simulink Coder/Embedded Coder generate
model code. HDL Coder/Deep Learning HDL Toolbox address FPGA/ASIC workflows.
Select the tool from the algorithm, hardware and interface requirements.

## Troubleshooting

- **Python unavailable:** configure a supported interpreter using `pyenv`.
- **Package/import unavailable:** check the required package or converter before
  running that optional section.
- **Wrong inference value:** compare identical inputs, data types and dimensions.
- **Compiler error:** check the selected compiler and support-package requirements.
- **Target absent:** retain host results and an unavailable target outcome.

## Official references

- [pyenv](https://www.mathworks.com/help/matlab/ref/pyenv.html)
- [pyrun](https://www.mathworks.com/help/matlab/ref/pyrun.html)
- [PyTorch import](https://www.mathworks.com/help/deeplearning/ref/importnetworkfrompytorch.html)
- [loadPyTorchExportedProgram](https://www.mathworks.com/help/coder/ref/loadpytorchexportedprogram.html)
- [coder.Constant](https://www.mathworks.com/help/coder/ref/coder.constant-class.html)
- [codegen](https://www.mathworks.com/help/coder/ref/codegen.html)
- [SIL/PIL workflow](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html)
