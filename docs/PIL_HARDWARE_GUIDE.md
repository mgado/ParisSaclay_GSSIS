# Rapid hardware prototyping with PIL

PIL is a primary training outcome. Students should see that a MATLAB/Simulink
algorithm can execute on a processor while MATLAB supplies inputs and checks
outputs; the board support tooling handles the target build and transport.

## Required first path: real battery AI on Raspberry Pi

Open exercise 20. It uses a pretrained projected floating-point SOC LSTM, measured
battery sensor data, and a copied Simulink model with three inputs in this order:
**Temperature, Voltage, Current**. No network retraining is required.

1. The instructor completes Raspberry Pi Blockset **Hardware Setup** before class.
2. Use a powered supported Pi with the configured 64-bit OS and connection.
3. Open the training Project and run the 32-sample MIL baseline.
4. Enable `runPIL`; `raspi` reuses the configured board connection.
5. Switch the same Model reference to **Processor-in-the-loop (PIL)** and run `sim`.
6. Compare actual target output to MIL with the declared `1e-4` SOC tolerance.
7. Repeat with cached code to demonstrate rapid iteration; change inputs before
   changing the algorithm or build configuration.

The first build may involve target setup/compilation and takes longer than a
cached repeat. No numerical build-time promise is made before an actual board
rehearsal. Measured end-to-end time includes communication, setup and simulation;
it is not pure inference latency.

## What counts as success

The Live Script returns `demoOutcome`:

- **passed:** actual PIL executed and output count, finite values and MIL/PIL
  numerical agreement passed.
- **unavailable:** PIL was not enabled or no configured board is ready.
- **failed:** an attempted target run or required comparison failed.

An open model, a detected support package, a board connection, a generated binary
or a MIL result alone cannot count as PIL success. Keep the actual target result.
Accuracy against physical SOC is a separate requirement; the short scenario's
network warm-up must be considered before scoring that accuracy.

## Reused assets and portability

All runtime assets are under `assets/pil_pi_soc/` in this Project. The source
wrapper's unused Terminator was replaced by a root Outport solely to capture
the SOC result for automatic comparison. The pretrained neural submodel and
dictionaries are otherwise preserved. `project.RootFolder` resolves paths; no
external source folder, startup script or hardcoded credential is needed.

The instructor-owned Expo reference tested its full workflow with R2026a.
Current R2026b host checks and actual board outcomes are recorded separately.
The original hardware step connected the Pi and opened the model; this new
exercise adds explicit PIL mode, a finite run and numerical comparison.

## Other available boards

Jetson Thor is the stronger optional GPU-AI extension: the Expo RTMPose collection
contains preserved generated PIL artifacts and prior on-target evidence. Reuse
the exact generated sources/assets and a current secure connection; do not equate
an Oct. 2026 saved result with a fresh classroom run. STM32 remains important for
resource-constrained MCU deployment, but no complete STM32 Expo demo root was
identified in the supplied reference tree. The original training's STM32/PIL
material remains available as a separately configured path.

## Official documentation

- [SIL/PIL workflow landing page](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html)
- [Choose the appropriate SIL/PIL approach](https://www.mathworks.com/help/ecoder/ug/choosing-a-sil-or-pil-approach.html)
- [Configure a SIL/PIL simulation](https://www.mathworks.com/help/ecoder/ug/configuring-a-sil-or-pil-simulation.html)
- [Raspberry Pi connection object](https://www.mathworks.com/help/raspberrypi/ref/raspi.html)
- [Raspberry Pi support](https://www.mathworks.com/hardware-support/raspberry-pi-simulink.html)
- [SimulationInput block parameter override](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setblockparameter.html)

## French presenter prompts

« Nous gardons le même algorithme et les mêmes entrées. Ce qui change, c'est le
lieu d'exécution : le processeur de la carte, piloté depuis MATLAB/Simulink. »

« La première génération prépare la cible. Ensuite, changer les scénarios est
rapide. On compare les résultats au modèle avant d'affirmer que le portage est
correct. La connexion à la carte seule ne prouve pas l'exécution du code. »

If the board is unavailable, demonstrate MIL and the documented configuration,
retain the unavailable PIL status, and schedule the physical rehearsal. Do not
announce that the hardware step passed.

## Compatibility preflight finding
The original target template expects standard LSTM/FC layer objects, but the supplied current projected network contains LSTMProjectedLayer, Dropout and two FC projection layers. The old target template therefore failed the R2026b MIL check. A matching exported candidate, SoC_LSTM_Projected_Quantized.slx, is included and selected by SimulationInput; it has not yet been rehearsed and its saved target is host/GRT. The instructor must configure the COPIED candidate to Pi64/ERT and verify MIL before a physical PIL run. Both runMIL and runPIL start disabled; the default is explicitly unavailable. The network and normalization parameters are supplied through SimulationInput, so no earlier-workshop base workspace is required.

## Input-order correction
The matching projected-network model consumes Temperature, Voltage, Current. The source test file's XTest columns are raw values in that order despite its test_data_scaled filename; the model performs input scaling internally. The copied wrapper wiring and lesson assignments are corrected accordingly. Do not scale the inputs twice. PIL numerical equivalence is distinct from physical SOC accuracy and short-trace warm-up.

## MATLAB command-line path (exercise21)
This path is independent of the Simulink Model-reference route. The supplied codegen entry point predictPiSOC loads the real projected/quantized network through coder.loadDeepLearningNetwork and calls predict on time-by-feature normalized sensor arrays, matching the Expo MATLAB source convention. The Live Script configures coder.config('lib','ecoder',true), coder.hardware('Raspberry Pi'), generic deep-learning code and VerificationMode='PIL', generates the gateway, executes it and compares actual target outputs with MATLAB. Hardware credentials come from private MATLAB Vault entries, not shared code. Defaults are unavailable until inference/codegen and a configured Pi are rehearsed; host prediction is not PIL.

Verified API pages: https://www.mathworks.com/help/coder/ref/coder.config.html ; https://www.mathworks.com/help/coder/ref/coder.hardware.html ; https://www.mathworks.com/help/coder/ref/coder.loaddeeplearningnetwork.html ; https://www.mathworks.com/help/coder/ref/codegen.html .

## R2026b float-first prototype
The supplied legacy quantized network fails host inference at an unsupported sigmoid fixed-point output type in R2026b. The first prototype therefore uses pretrained projected_net.mat (socNetProjected), whose 32-sample host inference is validated. Temperature, Voltage, Current is the feature order. The source subsystem file must be converted to a true model (PiSOCAIReference) before model-reference PIL. Quantization and on-target execution remain separately checked steps.

## Current prepared runtime (supersedes earlier candidate notes)

The Pi4 is connected through USB-Cpower only. Windows showed no USB Ethernet/RNDIS adapter and neither common Pi hostname resolved. Reachability and complete setup have not been confirmed; connect/configure Ethernet or Wi-Fi before actual PIL.

Exercise20 uses the true PiSOCAIReference model, prepared from the matching floating-point subsystem, and the corrected SoC_Target wrapper. Both use the measured Temperature, Voltage, Current input order. The source file's XTest values are raw despite its filename; the Simulink model scales inputs internally. The 32-sample host MIL baseline passed.

Exercise21 uses projected_net.mat through predictPiSOC. Its normalized time-by-feature input and 32-sample MATLAB host inference passed. Its output is network-scaled SOC; the Simulink wrapper de-scales output to physical SOC fraction. Apply the supplied output scaler when comparing the two routes. The same-route host-versus-PIL comparison uses identical units.

The old quantized network is incompatible with R2026b sigmoid fixed-point inference, and the old target model had mismatched layer indexing. These artifacts are in the development archive. First establish the projected floating-point prototype, then treat re-quantization as an explicit upgrade. No old absolute network path or credential value is required by the prepared student runtime.

An actual PIL result requires a supported network-connected board, target compilation/execution and numerical comparison; until then the hardware outcome remains unavailable. Host inference, host MEX and MIL are separate evidence.

## Updated connection checkpoint
The new USB-to-Ethernet link made the Pi reachable by IPv6 ping and SSH. Authentication was rejected with the supplied login; correct credentials are still required before inspecting IPv4/OS architecture and verifying MATLAB setup. The target remains unavailable for actual PIL. The earlier power-only/no-interface notes describe the initial connection, not the latest Ethernet state.

## Actual resumed PIL results

Both neural paths executed on the RaspberryPi4 processor:
- MATLABCoder directSSH PIL:32samples, maximum difference2.98e-8 versus MATLAB,1.57seconds end-to-end for the gateway call.
- Simulink model-reference PIL:32samples, maximum difference2.98e-8 versus MIL; firstbuild/run about115.72seconds.
- Changedinputtrace with cached Simulink build:32samples, same numerical tolerance passed;35.12seconds end-to-end.

These are individual observed timings including setup/build/transport/simulation as applicable, not pure inference latency or statistical speed benchmarks.

The working route provisions the public coder.hardware('Raspberry Pi') credential context and sets only the model's nonsecret device address at runtime. It does not construct the interactive raspi I/Oserver object. Credentials remain outside model files. The model target matches32-bitARM; genericC replaces the unavailable CMSIS header dependency; variable-size propagation is During execution. Old generated CMSIS utilities were preserved outside the active build folder before the generic rebuild.

IMPORTANT: The actual OS is Raspbian10Buster32. The R2026bRaspberryPiBlockset compatibility matrix does not support that OS. These passed runs are experimental on-target evidence, not a supported classroom-configuration qualification. Migrate/recheck on a supported Bullseye/Bookworm/Trixie OS before declaring the class hardware setup ready.

Compatibility reference: https://www.mathworks.com/help/raspberrypi/gs/validate-release-wise-compatibility-of-mathworks-products-with-raspberry-pi-hardware-and-operating-system.html
