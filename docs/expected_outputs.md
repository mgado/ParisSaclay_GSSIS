# Expected exercise observations

Use this checklist while running each Live Script. Values apply to the declared
teaching inputs and units. A parameter change can change the result; compare it
with the requirement, not with an assumed universal performance value.

| Exercise | What to check |
| --- | --- |
| 1 | The MATLAB sensor round trip returns SOC 0.5; inspect actual tool output |
| 2 | Requirements name a metric, threshold/domain and verification method; links identify implementation/tests |
| 3 | Disjoint groups: 420 training, 60 validation and 120 test observations |
| 4 | Compare validation errors before freezing the ML choice for final testing |
| 5 | The final held-out neural SOC RMSE meets the 0.03 fraction threshold |
| 6 | The same 3.55 V, 1 A, 25 C input gives SOC 0.5 across enabled Python/MATLAB paths |
| 7 | Measure error after rounding/quantization; verify the input scaling contract and the same accuracy threshold |
| 8 | The affine model's declared input box gives bounds near [0.496667, 0.503333] |
| 9 | Twenty time-aligned model outputs, finite values and SOC RMSE below 0.03 |
| 10 | The executed Test Manager criteria pass; inspect linked requirement status separately and refresh it if needed |
| 11 | Host generated code agrees at nominal SOC 0.5 and upper saturation output 1 |
| 12 | A held-out thermal input meets the declared reduced-model error criterion |
| 13 | Three retained modes reconstruct the rank-three field family near floating-point precision |
| 14 | The fitted cooling rate is near 0.04 for the supplied synthetic law; check residual and temperature behavior |
| 15 | Inspect input partitions, selected app/model and exported result; screenshot metrics are not your own result |
| 16 | Require the agent's actual edit/check result and compare it with the requirement |
| 17 | Repair nine missing values and one spike per acquisition; 1-second spacing gives 61 rows/run, 0.5-second spacing gives 121 |
| 18 | Assess unseen trajectory, physics residual and initial condition; the worked solution's stated error criteria must pass |
| 19 | Separate POD-only error from parameter-to-field prediction error; the worked solution requires prediction error below 10% |
| 20 | Actual Simulink PIL returns 32 finite samples and maximum MIL/PIL difference at most 1e-4 |
| 21 | Actual MATLAB neural PIL returns 32 finite samples and maximum host/PIL difference at most 1e-4 in matching network units |
| 27 | Healthy missions preserve reserve, temperature and current limits; voltage bias breaches the true-SOC reserve; a revised cutoff restores reserve while prediction error remains elevated and healthy delivered energy decreases |

### Exercise 27: worked scenario comparison

These example values use the supplied 600-second plant and the solution's
revised cutoff of **0.28**. The student file starts with 0.30, so its revised
cutoff values differ. Compare requirements and measured traces rather than
matching rounded numbers exactly.

| Scenario | Reserve cutoff | Minimum true SOC | SOC RMSE | Delivered energy (Wh) | System outcome |
|---|---:|---:|---:|---:|---|
| Healthy nominal | 0.20 | 0.19722 | 0.00149 | 0.49242 | Pass |
| Changing demand and ambient | 0.20 | 0.19667 | 0.00161 | 0.48550 | Pass |
| +0.12-V sensor bias from 60 s | 0.20 | 0.09611 | 0.09560 | 0.80357 | Reserve failure |
| Same sensor bias, revised margin | 0.28 | 0.17778 | 0.09462 | 0.55320 | Protection passes; AI remains inaccurate |
| Healthy nominal, revised margin | 0.28 | 0.27611 | 0.00137 | 0.24116 | Pass; lower energy service |

The physical reserve requirement is true SOC at least 0.15. The extra energy
delivered by the failed biased mission comes from discharging past that reserve.
The larger margin improves protection; it does not repair the measurements or
prove behavior outside this fictive plant and its tested scenarios.

SOC thresholds use fractions: 0.03 is three percentage points, not 3% relative
error. Thermal and field examples are illustrative models, not calibrated plant
certificates. A linked requirement or generated file alone does not establish
successful execution.

For optional hardware sections, `passed` requires actual processor execution.
Keep `unavailable` when the target action did not run, and retain `failed` for an
attempted run that violates a check. On-target timing includes transport/setup
unless a separate execution-profiling measurement explicitly isolates compute.

For the image/camera PIL lesson, check frame/detection shapes and actual target
execution. Host camera acquisition, a static picture or a PC model result is not
processor-in-the-loop success.
