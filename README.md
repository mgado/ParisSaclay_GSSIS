# ParisSaclay GSSIS - AI for engineered systems

**17-19 November 2026 - MATLAB and Simulink R2026b**

Learn how to define, train, verify and implement AI components for engineered
systems. A battery state-of-charge (SOC) virtual sensor connects the exercises;
thermal models introduce reduced-order modeling (ROM) and physics-informed AI.

## Start here

1. Open `ParisSaclay_GSSIS.prj` in MATLAB R2026b.
2. Run the commands below in the MATLAB Command Window.
3. Use **Run Section** in the Live Editor and complete the task before viewing
   its worked solution.

```matlab
setup_check
demoAgenda
openExercise(1)
```

To compare your reasoning with a solution:

```matlab
openExercise(1,true)
```

The project contains **25 exercise/solution pairs**. Each is a native plain-text
Live Script `.m` with an objective, prerequisites, launch instructions, an
experiment, hints, expected observations and an API cheat sheet.

## Three-day learning path

| Day | Topics | Exercises |
|---|---|---|
| 1 | Agentic tools, measurable requirements, independent data and preprocessing | 1-3, 17 |
| 2 | ML/DL, Python, compression, AI verification and modern apps | 4-8, 15, 23-24 |
| 3 | Simulink, tests, code generation, SIL/PIL, ROMs, physics and agentic practice | 9-14, 16, 18-21, 25-26 |

Work through the basic path first. Exercises initialize the inputs they need
and can be revisited independently with the project open. Hardware and optional
app/Python activities require their stated prerequisites.

## What you will practice

**Requirements - representative data - model - compression and verification -
integration and tests - generated code and target comparison.**

You will also compare model-based reduction, spatial-field reconstruction,
predictive full-field AI and a cooling PINN. In the agentic exercises, you ask
an engineering agent for a concrete change and check its result with MATLAB or
Simulink.

## Requirements

Complete [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted)
and [Simulink Onramp](https://matlabacademy.mathworks.com/details/simulink-onramp/simulink)
beforehand. `setup_check` lists installed products; each exercise identifies
its required toolboxes, libraries, interpreter, compiler or target support.

The short sensor/thermal examples use explicitly synthetic data. Selected
hardware exercises use provided battery measurements and a pretrained network.
Treat each result within its stated data, operating-domain and target scope.
A missing hardware connection is unavailable, not a passed target test.

### Minimum MATLAB release

| Component | Minimum supported release for this course |
|---|---|
| MATLAB | **R2026b** |
| Simulink, when required by an exercise | **R2026b** |
| Toolboxes, libraries and hardware support packages | Versions compatible with **R2026b** |

The full course uses R2026b features, including Visual Anomaly Detector and
expanded trained-network verification. Native plain-text Live Scripts were
introduced in R2025a, but that alone does not make the full course compatible
with R2025a. Earlier releases may run individual sections; they are not the
supported configuration for this package.

### MathWorks products

MATLAB is required for **every exercise**. Install the other products for the
exercises and optional branches you intend to run. Product names link to their
main documentation pages.

| Product | Used for | Exercises |
|---|---|---|
| [MATLAB](https://www.mathworks.com/help/matlab/) | Live Scripts, data, numerical analysis, projects and unit tests | All |
| [Simulink](https://www.mathworks.com/help/simulink/) | Neural model integration and simulation; prerequisite for Simulink Coder | 9, 10, 20; Coder dependency for 21, 25, 26; optional app export in 15 |
| [Deep Learning Toolbox](https://www.mathworks.com/help/deeplearning/) | Training, inference, PINNs, neural ROMs and verification | 2, 5, 7, 8, 9, 10, 18, 19, 20, 21, 23, 24, 25, 26; optional AI branches in 6 and 15 |
| [Statistics and Machine Learning Toolbox](https://www.mathworks.com/help/stats/) | Regression-tree virtual sensor | 4 |
| [Requirements Toolbox](https://www.mathworks.com/help/slrequirements/) | Requirement sets, links and verification status | 2, 10 |
| [Simulink Test](https://www.mathworks.com/help/sltest/) | Test Manager, test cases and executed model results | 10 |
| [Simulink Check](https://www.mathworks.com/help/slcheck/) | Digital-thread artifact tracing and native result refresh using `metric.Engine` | 10 |
| [MATLAB Coder](https://www.mathworks.com/help/coder/) | MEX generation, neural C/C++ generation and MATLAB SIL/PIL | 11, 20, 21, 25, 26 |
| [Simulink Coder](https://www.mathworks.com/help/rtw/) | Simulink code generation; prerequisite for Embedded Coder | 20; Embedded Coder dependency for 21, 25, 26 |
| [Embedded Coder](https://www.mathworks.com/help/ecoder/) | Embedded library configuration and SIL/PIL | 20, 21, 25, 26 |
| [GPU Coder](https://www.mathworks.com/help/gpucoder/) | CUDA detector generation and NVIDIA PIL | 26; optional CUDA deployment extension in 11 |
| [Fixed-Point Designer](https://www.mathworks.com/help/fixedpoint/) | Supplied Simulink hardware model and quantized-network workflow | 20; optional quantization in 7 |
| [Image Processing Toolbox](https://www.mathworks.com/help/images/) | Resize/display camera images; visual inspection dependency | 26; optional visual inspection branch in 15 |
| [Computer Vision Toolbox](https://www.mathworks.com/help/vision/) | YOLOX detection and image annotations; visual inspection dependency | 26; optional visual inspection branch in 15 |
| [Image Acquisition Toolbox](https://www.mathworks.com/help/imaq/) | Host-camera path using `videoinput` and `getsnapshot` | 26, only when `cameraMode="host"` |
| [Visual Inspection Toolbox](https://www.mathworks.com/help/visual-inspection/) | Visual Anomaly Detector app | 15, when choosing visual inspection |
| [Signal Processing Toolbox](https://www.mathworks.com/help/signal/) | Signal Labeler and labeled signal sets | Optional app branch in 15; `openSignalLabeler=true` in 17 |
| [System Identification Toolbox](https://www.mathworks.com/help/ident/) | ARMAX/nonlinear ARX models in Time Series Modeler | 15, only when selecting these model families |

Embedded Coder requires MATLAB Coder and Simulink Coder; Simulink Coder requires
Simulink. Include these prerequisites when installing for exercises 20, 21, 25
or 26. The supplied CPU training exercises do not require a GPU or Parallel
Computing Toolbox. MATLAB's `runtests` and `assertSuccess` are included in
MATLAB; the separate MATLAB Test product is not required for these unit tests.

### Libraries, support packages and external tools

These are additional components, rather than toolbox licenses. Install them
for the same MATLAB release through **Home > Add-Ons** or the linked setup guide.

| Component | Required for |
|---|---|
| [AI Verification Library for Deep Learning Toolbox](https://www.mathworks.com/help/deeplearning/verification.html) | 8, 23, 24: bounds, OOD detection, adversarial search and formal robustness |
| [Deep Learning Toolbox Model Compression Library](https://www.mathworks.com/help/deeplearning/ref/dlquantizer.html) | 7: optional `runQuantization=true` branch; also install when quantizing or recompressing a network |
| [Raspberry Pi Blockset](https://www.mathworks.com/help/raspberrypi/) | 20 and 21: Pi hardware configuration, target build and PIL; use a supported OS and matching architecture |
| [MATLAB Coder Support Package for NVIDIA Jetson and NVIDIA DRIVE Platforms](https://www.mathworks.com/help/coder/nvidia/) | 26: Jetson connection, target code generation and PIL |
| Image Acquisition Toolbox support package for the selected camera | 26 host-camera branch; the supplied Windows path uses the `winvideo` adaptor |
| [MATLAB and Simulink agentic toolkits](docs/AGENTIC_GUIDE.md) and a configured coding-agent client | Interactive agent/tool/skill activities in 1 and 16 |
| [Compatible Python interpreter](https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html), NumPy and optional PyTorch | 6: Python interoperability; PyTorch for the exported-model branch |
| Deep Learning Toolbox converter for the chosen model format | 6, if choosing editable PyTorch/ONNX import; the MATLAB-Python and direct exported-program routes do not use that converter |
| [Supported C/C++ compiler](https://www.mathworks.com/support/requirements/supported-compilers.html) | 11 and 25 on the host; target toolchain/build dependencies for 20, 21 and 26 |
| Compatible NVIDIA CUDA/cuDNN and configured Jetson Thor | 26 target execution; see the [Jetson guide](docs/JETSON_VISUAL_PIL.md) |

The pretrained projected SOC network is supplied. Running its inference in
21 or 25 does not require recompressing it. Camera acquisition on Thor uses the
NVIDIA support package; Image Acquisition Toolbox is needed for the separate
host-camera route. Some optional inspection models also need a downloadable
pretrained backbone.

### Requirements per exercise

MATLAB R2026b is implicit in every row. The product column lists the supplied
exercise's main path; the last column identifies optional branches and external
setup. Include the Coder product prerequisites listed above where applicable.

| Exercise | Topic | Products beyond MATLAB | Optional branches / additional setup |
|---|---|---|---|
| [1](workshops/w01_agentSetup.m) | Agentic setup and evidence | None for the numerical baseline | Official toolkits and a configured agent for interactive activities; Simulink for model-tool activities |
| [2](workshops/w02_requirements.m) | Measurable AI requirements | Requirements Toolbox; Deep Learning Toolbox | Deep Learning Toolbox is also used by the supplied accuracy-evidence section |
| [3](workshops/w03_data.m) | Data management and leakage prevention | None | No additional setup |
| [4](workshops/w04_mlBaseline.m) | ML virtual-sensor baseline | Statistics and Machine Learning Toolbox | No additional setup |
| [5](workshops/w05_deepLearning.m) | Neural estimator training | Deep Learning Toolbox | CPU training |
| [6](workshops/w06_pythonImport.m) | Python and third-party AI | None for the base MATLAB section | Python/NumPy for interoperability; PyTorch for export; Deep Learning Toolbox and the relevant converter for editable import/model-wrapper branches |
| [7](workshops/w07_modelCompression.m) | Compression and quantization | Deep Learning Toolbox | Model Compression Library and Fixed-Point Designer for `runQuantization=true` |
| [8](workshops/w08_aiVerification.m) | Output bounds | Deep Learning Toolbox | AI Verification Library |
| [9](workshops/w09_simulinkIntegration.m) | Neural model integration | Simulink; Deep Learning Toolbox | No hardware required |
| [10](workshops/w10_systemTesting.m) | Requirement/test/model links and native status | Simulink; Deep Learning Toolbox; Simulink Test; Requirements Toolbox; Simulink Check | Project artifact tracing and tool-output tracking must be enabled as shown in the exercise |
| [11](workshops/w11_codegen.m) | Generate and compare host MEX | MATLAB Coder | Supported host C/C++ compiler; GPU Coder and target support only for a CUDA deployment extension |
| [12](workshops/w12_modelBasedROM.m) | Model-based thermal ROM | None | Uses direct MATLAB matrix operations |
| [13](workshops/w13_fullFieldROM.m) | Full-field reconstruction | None | Uses direct MATLAB matrix operations |
| [14](workshops/w14_physicsInformed.m) | Physics-constrained inverse fitting | None | Uses MATLAB `fminsearch`; no Optimization Toolbox required |
| [15](workshops/w15_appWorkflows.m) | AI app workflows | None for the capability/data check | Deep Learning Toolbox for Time Series Modeler/Deep Network Designer; System Identification Toolbox for ARMAX/ARX; Visual Inspection Toolbox plus Deep Learning, Computer Vision and Image Processing Toolboxes for visual inspection; Signal Processing Toolbox for Signal Labeler; Simulink for model export |
| [16](workshops/w16_agentEngineering.m) | Builtin and custom skills | None for the numerical baseline | Configured agent and official toolkits; install products required by the engineering change you choose |
| [17](workshops/w17_dataPreparation.m) | Cleaning and resampling | None for numerical processing | Signal Processing Toolbox only for `openSignalLabeler=true` |
| [18](workshops/w18_pinnCooling.m) | Cooling PINN | Deep Learning Toolbox | CPU training |
| [19](workshops/w19_predictiveFieldROM.m) | Predictive full-field AI ROM | Deep Learning Toolbox | CPU training; command-line workflow |
| [20](workshops/w20_hardwarePIL.m) | Simulink Pi neural PIL | Simulink; Deep Learning Toolbox; Fixed-Point Designer; MATLAB Coder; Simulink Coder; Embedded Coder | Raspberry Pi Blockset, supported configured Pi, target toolchain and private connection settings |
| [21](workshops/w21_matlabHardware.m) | MATLAB Pi neural PIL | MATLAB Coder; Embedded Coder; Deep Learning Toolbox; Coder prerequisites above | Raspberry Pi Blockset, supported configured Pi and target toolchain; supplied network does not need a new compression run |
| [23](workshops/w23_advancedVerification.m) | Trained-network bounds and OOD | Deep Learning Toolbox | AI Verification Library; CPU execution |
| [24](workshops/w24_adversarialWorkshop.m) | Adversarial search and robustness | Deep Learning Toolbox | AI Verification Library; CPU execution |
| [25](workshops/w25_silVerification.m) | Generated neural code SIL | MATLAB Coder; Embedded Coder; Deep Learning Toolbox; Coder prerequisites above | Supported host C/C++ compiler; no board required |
| [26](workshops/w26_jetsonCameraPIL.m) | Jetson image/camera PIL | GPU Coder; MATLAB Coder; Embedded Coder; Deep Learning Toolbox; Computer Vision Toolbox; Image Processing Toolbox; Coder prerequisites above | NVIDIA support package, configured Thor, compatible CUDA/cuDNN and camera; Image Acquisition Toolbox/adaptor for the host-camera branch |

Run `setup_check` for its quick capability report. To inspect the complete
installed product and add-on lists, run:

```matlab
ver
matlab.addons.installedAddons
mex -setup C++
```

Having a product installed does not establish a working Python, compiler,
agent or hardware connection. Complete the selected exercise's setup before
enabling its optional sections.

## Guides

- [User guide](docs/USER_GUIDE.md): navigation, checks and troubleshooting.
- [Agenda](docs/AGENDA.md): three-day schedule and exercise map.
- [Daily takeaways](docs/DAILY_TAKEAWAYS.md): concepts to retain.
- [Agentic engineering](docs/AGENTIC_GUIDE.md): tools, skills and concrete tasks.
- [ROM guide](docs/ROM_GUIDE.md): model-based, full-field and physics-informed methods.
- [Python and deployment](docs/PYTHON_AND_DEPLOYMENT.md): import and implementation routes.
- [System testing](docs/SYSTEM_TESTING.md): requirements, test criteria and execution levels.
- [R2026b features](docs/R2026B_REFRESH.md): relevant release updates and official help.

Course repository: [ParisSaclay_GSSIS](https://github.com/mgado/ParisSaclay_GSSIS).
Access to the private repository requires permission.
