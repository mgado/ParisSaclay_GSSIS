# R2024b-to-R2026b training refresh

Reviewed 2026-11-16 against installed R2026b source and current official MathWorks reference-page Version History sections. This is a teaching refresh, not a claim that every listed function was introduced in R2026b. “Installed” does not mean exercised successfully.

## Prioritized changes with release evidence

| Topic | Verified change | Workshop relevance | Release / evidence |
|---|---|---|---|
| Formal verification | `estimateNetworkOutputBounds` and `verifyNetworkRobustness` support additional 1-D convolution, recurrent, projected and imported-network layers | Extend beyond the old feedforward/image examples; connect verification to time-series and compressed models | R2026b, official Version History [bounds](https://www.mathworks.com/help/deeplearning/ref/estimatenetworkoutputbounds.html), [robustness](https://www.mathworks.com/help/deeplearning/ref/verifynetworkrobustness.html) |
| Out-of-distribution detection | `networkDistributionDiscriminator` accepts numeric/categorical/cell/table/datastore inputs and unformatted `dlarray`, plus batch/environment/sequence options | Use the same data table as training instead of teaching extra queue plumbing | R2026b, [Version History](https://www.mathworks.com/help/deeplearning/ref/networkdistributiondiscriminator.html) |
| OOD execution behavior | Distribution-discriminator functions default to GPU when available; batching behavior and options changed | Specify CPU explicitly for reproducible classroom timing when appropriate | R2026b, same reference |
| OOD KDE | KDE discriminator method available | Optional calibration comparison, requiring Statistics and Machine Learning Toolbox | R2026a, not new R2026b; same reference |
| Time Series Modeler | App introduced with model training, comparison, prediction and Simulink layer-block export | Strong app-to-code bridge for the shared sensor/model story | R2026a, [app Version History](https://www.mathworks.com/help/deeplearning/ref/timeseriesmodeler-app.html) |
| Time Series Modeler improvements | Sample time/units, Simulink sampling-frequency export, configurable loss/metric, vanishing/exploding-gradient detection, L-BFGS, nonlinear ARX | Explain sample time and training diagnostics; compare an app-generated model with the short direct-API lesson | R2026b, same app reference |
| Visual Anomaly Detector | New app supports Student-Teacher, PatchCore, FastFlow and FCDD, training/evaluation/threshold optimization and heatmap inspection | Optional visual-inspection branch with actual app screenshots and a small fixed-pose image dataset | R2026b, [app reference](https://www.mathworks.com/help/visual-inspection/ref/visualanomalydetector-app.html) |
| Quantized I/O | MATLAB-environment quantized `dlnetwork` objects now accept fixed-point inputs; quantized layer outputs can be fixed point | Inspect types with `quantizationDetails`; validate numerical error after quantization rather than assuming float output | R2026b, [dlquantizer Version History](https://www.mathworks.com/help/deeplearning/ref/dlquantizer.html) |
| Quantization target change | `dlquantizer` `"CPU"` execution environment using ARM Compute Library is slated for future removal; official guidance is `"MATLAB"` for generic C/C++ | Update old CPU-quantization snippets; retain board-specific checks | R2026b notice, same reference |
| Quantization licensing | MATLAB execution environment uses fixed-point simulation and requires Fixed-Point Designer for quantization/validation | Put license check in prerequisites | R2024b, same reference; not new R2026b |
| Model memory metrics | `estimateNetworkMetrics` now reports `StateMemory (MB)` rather than the older state-count metric | Update cheat sheets and table-column access; compare parameters, state and arithmetic honestly | R2025b, [metrics Version History](https://www.mathworks.com/help/deeplearning/ref/estimatenetworkmetrics.html) |
| Projection compression | `compressNetworkUsingProjection` accepts more data types, supports layers inside `networkLayer`, and avoids parameter-count increases by default | Use directly with classroom data and compare complexity plus output error | R2026a, [projection Version History](https://www.mathworks.com/help/deeplearning/ref/compressnetworkusingprojection.html) |
| Direct PyTorch/LiteRT codegen | `loadPyTorchExportedProgram` / `loadLiteRTModel` load inference artifacts for `invoke` and MEX/C++/CUDA generation without first producing an editable `dlnetwork` | Teach as a separate route from editable network import/compression; verify MEX before production builds | R2026a+, [PyTorch reference](https://www.mathworks.com/help/coder/ref/loadpytorchexportedprogram.html); installed support-package source |
| Native plain-text Live Scripts | Student `.m` files render rich text through `%[text]` and the native appendix | Update delivery format while keeping version-control-friendly source | R2025a+, installed official live-script skill |

## Concrete R2026b verification layer coverage

The official bounds/robustness pages identify newly supported layers including `convolution1dLayer`, `groupedConvolution2dLayer`, `bilstmLayer`, `lstmLayer`, `lstmProjectedLayer`, `sequenceInputLayer`, `gruLayer`, `gruProjectedLayer`, `preluLayer`, `softmaxLayer`, `softplusLayer`, `swishLayer`, `inverseNormalizationLayer`, `layerNormalizationLayer`, `networkLayer`, `scalingLayer`, `spatialDropoutLayer`, `ProjectedLayer`, 1-D pooling layers, `concatenationLayer`, and `multiplicationLayer`, plus listed imported PyTorch/ONNX/TensorFlow layer types. Use the official supported-layer list for the actual network; this is not permission to assume arbitrary network compatibility.

`alphaCROWNOptions` was introduced in R2026a. Bounds and robustness verification themselves date to R2022b. Present the 2026 expansion of supported networks separately from the older underlying verification concept.

## Exact app entry points and uncertainty

- `visualAnomalyDetector` opens the **Visual Anomaly Detector** app. The documented data-loaded form is `visualAnomalyDetector(imdsTrain,imdsCal,imdsTest,anomalyClasses)`. Training/calibration/test are image datastores; calibration optimizes the threshold. `visualAnomalyDetector close` closes this app.
- `timeSeriesModeler` opens **Time Series Modeler**, according to its official app reference. Supported data-import syntax should be checked in the attached MATLAB session before writing a data-loaded launch step.
- “Anomaly Detector app” is ambiguous. In this refresh, the exact verified image app is **Visual Anomaly Detector**; do not invent `anomalyDetector` or `signalAnomalyDetector` launch functions.
- **Visual Inspection Toolbox** is installed locally at R2026b. Product presence alone does not prove that every detector API is new: several algorithms existed in earlier products/releases.
- **3-D Full Field ROM app** remains unresolved: the material-analysis agent extracted ROM text and hyperlink relationships and found no exact app URL. It found the [Reduced Order Modeling Support Package](https://www.mathworks.com/matlabcentral/fileexchange/156364-reduced-order-modeling-support-package) and official Neural PDE Surrogates for 3-D Electrostatics / 3-D Battery Cooling Using FNO examples. It is not treated as a built-in R2026b app on name alone. A small SVD/POD full-field example can teach the concept without assuming that app is installed.
- The long full-field deck describes a `transolverNetwork` model with approximately 5.8 million learnables and nine hours of training on external car-aerodynamics data. That source demo requires a prerecorded or pretrained advanced path under this production deadline; a fresh nine-hour training run is incompatible with it.

## Two PyTorch routes students must distinguish

| Need | Route | Result |
|---|---|---|
| MATLAB editing, fine-tuning, quantization, projection or pruning | `importNetworkFromPyTorch` | Editable `dlnetwork`; conversion and layer support matter |
| Direct inference/code generation from an exported artifact | `loadPyTorchExportedProgram` then `invoke` | PyTorch ExportedProgram inference object; `.pt2` compile-time path for codegen |

The direct route needs MATLAB Coder Support Package for PyTorch and LiteRT Models. Its public loader exists at `C:/ProgramData/MATLAB/SupportPackages/R2026b/toolbox/dlcoder_oss_frameworks/supportpackages/mlir/pytorch/loadPyTorchExportedProgram.m`. The inference wrapper `pyTorchModel` exists in the base product but is a different Python-execution path; it is not interchangeable with code-generation loading.

## Teaching priorities under the three-hour production limit

Use the small direct-API path as the required runnable baseline. Add a short app walkthrough for Time Series Modeler and Visual Anomaly Detector, with real screenshots and clearly identified prerequisites. Keep ACAS global adaptive verification, hardware PIL/HIL, full-field ROM app setup, and framework import details as independent advanced branches rather than making a student's first execution depend on downloads or hardware.

For every compression/deployment branch, compare the same retained validation data before/after the change and recheck the same requirement. Model accuracy, formal input-domain evidence, generated-code equivalence, and hardware timing are separate pieces of evidence.

## Full-field app decision (2026-11-16)
The owner confirmed that no public full-field ROM app should be assumed. The required training path is the verified command-line POD and predictive full-field network exercises (13 and 19). App setup is not a pending prerequisite.
