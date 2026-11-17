# Run battery AI on a Raspberry Pi with PIL

Open the training Project, then run `openExercise("w20_hardwarePIL")` for the
Simulink path or `openExercise("w21_matlabHardware")` for MATLAB command-line
code generation. Work through one Live Editor section at a time.

## Prerequisites

Use MATLAB/Simulink R2026b, Deep Learning Toolbox, MATLAB Coder/Embedded Coder,
Raspberry Pi Blockset and the products listed in the selected lesson. Connect a
supported Raspberry Pi through Ethernet or configured Wi-Fi, complete Hardware
Setup, and enter its current address. USB-C power alone is not a network link.
Store the private login in MATLAB Vault as prompted by the lesson.

Match the target's 32/64-bit architecture, OS and toolchain. **Raspbian 10 Buster
is not supported by R2026b Raspberry Pi Blockset**, even if an individual
experimental run succeeds. Use a supported OS from the
[release compatibility table](https://www.mathworks.com/help/raspberrypi/gs/validate-release-wise-compatibility-of-mathworks-products-with-raspberry-pi-hardware-and-operating-system.html).

## Keep the input and output contracts clear

The supplied projected SOC network uses **Temperature, Voltage, Current**.
Temperature is in Celsius, voltage in volts and current in amperes.

- Simulink receives raw sensor values and applies the supplied normalization;
  its output is physical SOC fraction.
- The MATLAB network entry receives normalized time-by-feature arrays and
  returns network-scaled SOC. Apply the supplied output scaler when comparing
  this output with physical SOC.
- Compare host and target outputs in the same units. Do not normalize twice.

## Simulink path

1. Run the finite 32-sample MIL reference in exercise 20.
2. Confirm the selected hardware and current device address.
3. Enable `runPIL` and run the same input through the Model block in
   **Processor-in-the-loop (PIL)** mode.
4. Require 32 finite outputs and maximum absolute MIL/PIL difference at most
   `1e-4` SOC fraction.
5. Change the trace offset and repeat without changing the algorithm. Reuse
   the cached build when model and target configuration are unchanged.

The key operation is a non-destructive simulation override:

```matlab
pilInput = simulation.setBlockParameter(referenceBlock, ...
    'SimulationMode','Processor-in-the-loop (PIL)');
pilOutput = sim(pilInput);
```

## MATLAB command-line path

Exercise 21 shows the network entry function and the direct configuration APIs:

```matlab
configuration = coder.config('lib','ecoder',true);
configuration.Hardware = coder.hardware('Raspberry Pi');
configuration.VerificationMode = 'PIL';
```

The lesson sets the private connection context, generates the library/PIL
gateway, calls that gateway with the same normalized input, and compares the
result with the MATLAB network. Inspect `predictPiSOC.m` to see
`coder.loadDeepLearningNetwork` and `predict` directly.

## Interpret the outcome

`demoOutcome.Status` is `passed` only after actual target execution and the
numerical checks pass. `unavailable` means the required target action has not
run; `failed` means an attempted execution or check failed. A host prediction,
open model, connection object or generated file alone is not PIL success.

End-to-end timing includes build/setup, communication and simulation as
applicable. Use execution profiling for a separate target compute-time metric.
Accuracy against physical SOC is also separate from host/target equivalence;
consider the recurrent network's initial state and warm-up.

## Troubleshooting

- **Cannot reach the Pi:** check power, Ethernet/Wi-Fi, address and SSH setup.
- **Wrong numerical result:** check feature order, normalization and output units.
- **Build fails:** check supported OS/architecture, compiler, target libraries
  and the hardware name selected in the lesson.
- **Model name already open:** preserve the other model and reopen the training
  Project/model before continuing.
- **No target available:** run the host/MIL sections and retain `unavailable`.

## Official references

- [SIL/PIL workflow](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html)
- [Configure SIL/PIL](https://www.mathworks.com/help/ecoder/ug/configuring-a-sil-or-pil-simulation.html)
- [SimulationInput.setBlockParameter](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setblockparameter.html)
- [sim](https://www.mathworks.com/help/simulink/slref/sim.html)
- [coder.config](https://www.mathworks.com/help/coder/ref/coder.config.html)
- [coder.hardware](https://www.mathworks.com/help/coder/ref/coder.hardware.html)
- [Raspberry Pi support](https://www.mathworks.com/hardware-support/raspberry-pi-simulink.html)
