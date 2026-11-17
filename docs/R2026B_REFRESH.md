# MATLAB and Simulink capabilities for R2026b

Use this guide to identify capabilities relevant to the exercises and distinguish new R2026b functionality from earlier APIs.

## Changes you can use

| Capability | Release relevance | Apply it in the workflow |
|---|---|---|
| [Formal network verification](https://www.mathworks.com/help/deeplearning/ref/estimatenetworkoutputbounds.html) | R2026b adds support for more recurrent, projected, 1-D convolution and imported-network layers, including softplus | Bound a trained network over explicit sensor uncertainty |
| [OOD detection](https://www.mathworks.com/help/deeplearning/ref/networkdistributiondiscriminator.html) | R2026b accepts numeric, categorical, cell, table and datastore inputs, with batching, format and execution options | Reuse prepared data directly and inspect distribution shifts |
| [Time Series Modeler](https://www.mathworks.com/help/deeplearning/ref/timeseriesmodeler-app.html) | Introduced R2026a; R2026b adds sample-time/units, Simulink export sampling frequency, loss/metric choice, gradient diagnostics, L-BFGS and nonlinear ARX | Compare time-series models and connect app results to system integration |
| [Visual Anomaly Detector](https://www.mathworks.com/help/visual-inspection/ref/visualanomalydetector-app.html) | App introduced R2026b | Train, calibrate thresholds, evaluate held-out images and inspect heatmaps |
| [Quantized network I/O](https://www.mathworks.com/help/deeplearning/ref/dlquantizer.html) | R2026b MATLAB-environment quantized networks accept fixed-point inputs and can produce fixed-point layer outputs | Inspect `quantizationDetails` and evaluate numerical error after conversion |
| [Network memory metrics](https://www.mathworks.com/help/deeplearning/ref/estimatenetworkmetrics.html) | R2025b reports state memory as `StateMemory (MB)` | Compare parameters, states and arithmetic without confusing count with memory |
| [Projection compression](https://www.mathworks.com/help/deeplearning/ref/compressnetworkusingprojection.html) | R2026a adds more input types and nested-layer support and avoids size increases by default | Compare complexity and validation error after compression |
| [Direct PyTorch/LiteRT inference code generation](https://www.mathworks.com/help/coder/ref/loadpytorchexportedprogram.html) | Available R2026a+ | Load an exported inference artifact, verify MEX, then generate target code |
| [Project-based verification results](https://www.mathworks.com/help/slrequirements/ug/view-unified-verification-results-as-metrics-dashboard-in-the-requirements-editor.html) | R2026b discovers exported results through the digital thread; settings API is available R2025a+ | Enable tool-output tracking before execution/export and refresh native requirement status |
| Native plain-text Live Scripts | Available R2025a+ | Open the supplied `.m` exercises as rich documents in Live Editor |

## Verification: check the actual network

R2026b supports additional layers such as `convolution1dLayer`, LSTM/GRU variants, `softplusLayer`, `swishLayer`, normalization layers, `networkLayer` and projected layers. Check the [supported-layer and release-history reference](https://www.mathworks.com/help/deeplearning/ref/verifynetworkrobustness.html) for your exact model.

The bounds and robustness APIs date to R2022b. `alphaCROWNOptions`, `findAdversarialExamples` and `adversarialOptions` are R2026a APIs. KDE OOD detection is also an R2026a addition. New support does not imply compatibility with every imported operator or network architecture.

OOD functions can select a GPU automatically in R2026b. Use an explicit execution environment when you need reproducible device selection.

## Quantization choices

For portable C/C++ quantization, use the `"MATLAB"` execution environment. The older `"CPU"` environment based on ARM Compute Library is slated for future removal. MATLAB-environment quantization uses fixed-point simulation and requires Fixed-Point Designer; this requirement applies from R2024b.

Use calibration data to establish scales, validation data to choose settings, and an untouched final test set after the configuration is frozen. Recheck accuracy and the relevant requirement after conversion.

## Keep the PyTorch routes distinct

| Goal | Route | Result |
|---|---|---|
| Edit, fine-tune or compress in MATLAB | [importNetworkFromPyTorch](https://www.mathworks.com/help/deeplearning/ref/importnetworkfrompytorch.html) | Editable `dlnetwork` |
| Execute or generate code from an exported artifact | [loadPyTorchExportedProgram](https://www.mathworks.com/help/coder/ref/loadpytorchexportedprogram.html) and `invoke` | Exported-program inference object |
| Execute the original model in Python | `pyTorchModel` | Python-execution interface |

The direct-codegen route requires MATLAB Coder Support Package for PyTorch and LiteRT Models, a compatible model artifact and compiler. Preserve the model's input shape and data type, compare the same input numerically, and verify host MEX before a production target build.

## Apps and full-field ROM

`timeSeriesModeler` opens Time Series Modeler. `visualAnomalyDetector` opens Visual Anomaly Detector; its data-loaded form accepts separate training, calibration and test image datastores. The app supports Student-Teacher, PatchCore, FastFlow and FCDD models. Several algorithms predate the new app.

The full-field ROM exercises use command-line POD encoding, coefficient prediction and field reconstruction. A separate full-field app is not required. Use the [Reduced Order Modeling documentation](https://www.mathworks.com/help/deeplearning/reduced-order-modeling.html) to explore further workflows.
