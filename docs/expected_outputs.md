# Expected observations and representative rehearsal outputs

These values come from the R2026b classroom-scale synthetic examples. They are
engineering checks on the declared teaching inputs, not industrial battery or
hardware performance claims. Student parameter changes can change the values.

| Exercise | Expected observation |
| --- | --- |
| 1 | MATLAB round-trip target SOC = 0.5; agent connection separately demonstrated |
| 2 | Measurable SOC-001 requirement, implementation link and held-out RMSE below 0.03 |
| 3 | 420 training, 60 validation and 120 test rows, disjoint acquisition groups |
| 4 | Tree and analytic baseline error comparison; representative RMSE 0.0347 and 0.0016 |
| 5 | Compact neural held-out RMSE approximately 0.0035, max error approximately 0.0123 |
| 6 | Python scalar, imported network and direct PyTorch inference agree at 0.5 when enabled |
| 7 | Weight-rounding RMSE approximately 0.0046; largest reference prediction change approximately 0.0072 |
| 8 | Formal affine-network output interval approximately [0.496667, 0.503333] |
| 9 | Twenty time-aligned Simulink SOC samples and model RMSE below 0.03 |
| 10 | Persistent Test Manager input mapping and custom RMSE assessment; linked SOC-001 status reflects the executed result |
| 11 | Generated host MEX agrees with MATLAB at nominal SOC 0.5 and saturation output 1 |
| 12 | Held-out thermal-model projection error approximately 1.06e-6 |
| 13 | Rank-three field reconstruction error near machine precision; per-field coefficient ratio 3/1000 |
| 14 | Fitted cooling rate approximately 0.04; interior physics residual approximately 2.05e-4 |
| 15 | Actual app-capability inventory and attributed UI screenshots; app metrics shown are documentation examples |
| 16 | Boundary behavior checked; agent must supply its own executed edit/test evidence |
| 17 | Nine missing values and one spike per acquisition repaired; solution resampling yields 121 rows per split |
| 18 | Trained PINN trajectory RMSE approximately 0.0050, residual RMSE approximately 0.0334, initial error approximately 0.0012 |
| 19 | Predicted field relative error approximately 0.0149; POD-only error near machine precision |

The simulation and generated-code checks use actual execution. PIL/HIL and
physical-board resource/timing measurements require the configured target.
No public full-field ROM app is assumed.

## Optional real quantization
The measured raw-input INT8 quantization RMSE was about 0.0330, failing the 0.03 requirement. Moving learned z-score normalization outside the quantized network preserved floating-point outputs exactly in this rehearsal and reduced quantized RMSE to about 0.0045. Deployment must include that preprocessing; this is an accuracy result, not a measured board-memory or speed claim.
