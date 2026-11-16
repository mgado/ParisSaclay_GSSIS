# Validation and rehearsal evidence

Validated on Windows with **MATLAB and Simulink R2026b**. Source inspection,
execution, UI guidance, generated-code checks and physical target evidence are
separate categories.

## Executed core

- All **19 core student Live Scripts and 19 matching solutions** executed in
  isolated function workspaces with their documented defaults.
- Training/validation/test groups remain disjoint. Exercises 4 and 5 were
  replayed after adding validation-only tuning and explicit final-test flags.
- The nonempty MATLAB unit suite passed **9/9 tests**, including known SOC,
  bounds, temperature units, reproducibility and held-out neural accuracy.
- The real `buildtool` **check → test → package** workflow passed. Runtime
  Code Analyzer reported no errors or warnings; two informational package-helper
  observations do not affect the execution results.
- The exported neural Simulink model passed a 20-sample scenario with SOC RMSE
  approximately **0.0025**. Connectivity checks reported healthy.
- The persistent Simulink Test case passed its sample count/time/finite-value
  and held-out RMSE criterion: **1 passed, 0 failed, 0 incomplete**.
- MATLAB-generated baseline MEX agreed with MATLAB at SOC **0.5** and the
  upper saturation boundary **1**.
- The small PyTorch model was exported, imported as an editable `dlnetwork`,
  loaded through the direct exported-program route, compiled to MEX, and
  compared numerically. All routes agreed with SOC **0.5** within tolerance.

## Observed model and ROM metrics

| Check | Representative observed result |
| --- | --- |
| Neural SOC final held-out RMSE | 0.0035, below teaching requirement 0.03 |
| Neural SOC validation RMSE | 0.0031 |
| Formal affine-network output bounds | [0.496667, 0.503333] |
| Weight-rounding SOC RMSE | 0.0046 |
| Raw mixed-unit input INT8 SOC RMSE | 0.0330; requirement failed |
| Explicit normalized-input INT8 SOC RMSE | 0.0045; requirement passed |
| Floating-point normalization refactor | Maximum prediction difference 0 in rehearsal |
| Model-based thermal ROM held-out error | Approximately 1.06e-6 |
| Three-mode full-field reconstruction | Approximately 2.73e-15 relative error |
| Physics-constrained inverse cooling rate | Approximately 0.04 |
| Trained PINN held-out trajectory RMSE | Approximately 0.0050 |
| Trained PINN physics residual RMSE | Approximately 0.0334 |
| Predictive full-field AI ROM held-out error | Approximately 0.0149 relative error |

These are classroom-scale synthetic examples, not industrial accuracy or
physical-board speed/memory measurements. Student starting values intentionally
produce weaker one-mode and small-network ROM results for comparison with the
solutions.

## Native rendering, screenshots and documentation links

Native `%[text]`/section/appendix structure was checked for all core sources.
HTML export verified rich text without native-directive leaks. Requirements
Editor and modern-app screenshot exports each embedded two images correctly.

Screenshot provenance distinguishes the instructor's original interface images,
official documentation screenshots and the current exported R2026b model diagram.
Documentation-example metrics are not workshop results.

All core Live Scripts include a main topic documentation page and linked APIs
in their cheat sheets. The audit checked official URL availability and corrected
class-sensitive routes. Project-owned helpers link to their actual local sources.

## Native requirement status limitation

The linked Test Manager criterion passed, but Requirements Toolbox's native
verification cache continued to show SOC-001 as **unexecuted** in this session.
The exercise retains the actual passed result and the native cache status
separately in its generated requirement-verification evidence JSON. No native
green verdict was fabricated.

For R2026b exported-result discovery, use the documented Digital Thread
**Track tool outputs** setting before export and allow artifact tracing to finish.
Export/re-import alone does not preserve testcase connections. This UI/status
tracking issue does not change the executed numerical test result.

## Hardware/PIL stream

Exercise 20 is the separate prioritized hardware stream. It reuses pretrained
quantized SOC AI, measured battery data and copied Raspberry Pi reference models
from the instructor's Expo collection. Its default status remains **unavailable**
until an actual enabled on-target run succeeds. A MIL baseline or board connection
alone cannot count as PIL passed.

Live board readiness has not yet been confirmed. Current MIL/PIL stream evidence
and any required setup are recorded in `PIL_HARDWARE_GUIDE.md` and the development
stream log. No STM32 firmware or Jetson deployment is claimed from the core host
checks. No public full-field ROM app is assumed.

## Local delivery

The student copy uses an explicit training-only allowlist. Git history, Codex and
VC workflow files, internal slides, machine-local startup code, generated caches
and model-save backups are excluded. Everything remains local; future GitHub
publication is private initially and requires a later request.

## Additional hardware-stream host evidence

Both hardware paths now use the pretrained projected floating-point Expo SOC
network. The corrected true model-reference model passed a finite 32-sample MIL
scenario. A required single-precision network-input conversion was added and
revalidated so the original interpreted-double fallback is not treated as a
code-generation-ready path.

The same real neural entry point was compiled to host C++ MEX. Its maximum
prediction difference versus MATLAB was approximately 2.98e-8, within 1e-4.
The check/test/package workflow again passed all 9 unit tests. These are host
checks; neither hardware worksheet reports them as physical PIL success.

After the hub/Ethernet reconnection, the Pi was reachable by IPv6 ping and its
SSH service responded. The supplied login was rejected, so authentication,
IPv4/OS inspection, MATLAB board setup and actual PIL remain pending correct
credentials. The target OS architecture is not yet verified.

## Actual resumed PIL results

Both neural paths executed on the RaspberryPi4 processor:
- MATLABCoder directSSH PIL:32samples, maximum difference2.98e-8 versus MATLAB,1.57seconds end-to-end for the gateway call.
- Simulink model-reference PIL:32samples, maximum difference2.98e-8 versus MIL; firstbuild/run about115.72seconds.
- Changedinputtrace with cached Simulink build:32samples, same numerical tolerance passed;35.12seconds end-to-end.

These are individual observed timings including setup/build/transport/simulation as applicable, not pure inference latency or statistical speed benchmarks.

The working route provisions the public coder.hardware('Raspberry Pi') credential context and sets only the model's nonsecret device address at runtime. It does not construct the interactive raspi I/Oserver object. Credentials remain outside model files. The model target matches32-bitARM; genericC replaces the unavailable CMSIS header dependency; variable-size propagation is During execution. Old generated CMSIS utilities were preserved outside the active build folder before the generic rebuild.

IMPORTANT: The actual OS is Raspbian10Buster32. The R2026bRaspberryPiBlockset compatibility matrix does not support that OS. These passed runs are experimental on-target evidence, not a supported classroom-configuration qualification. Migrate/recheck on a supported Bullseye/Bookworm/Trixie OS before declaring the class hardware setup ready.

Compatibility reference: https://www.mathworks.com/help/raspberrypi/gs/validate-release-wise-compatibility-of-mathworks-products-with-raspberry-pi-hardware-and-operating-system.html
