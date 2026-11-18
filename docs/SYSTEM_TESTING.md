# Requirements, integration and system tests

A traceability link records what an implementation or test addresses. A verification result requires executed criteria, the correct input/model revision, and result tracking.

## Follow the requirement-to-test chain

1. Define a measurable requirement in a `.slreqx` requirement set.
2. Link the implementation model or MATLAB function with an **Implement** link.
3. Create a persistent `.mldatx` test case and link it to the requirement with **Verify**.
4. Map a held-out sensor trace to the model inputs.
5. Run meaningful criteria and inspect both the test result and native requirement status.

The SOC example uses RMSE **at most 0.03** on independent acquisitions: three percentage points of SOC fraction, not 3% relative error. Its custom criterion also checks sample count, timestamps and finite predictions before scoring accuracy.

Use [Requirements Editor](https://www.mathworks.com/help/slrequirements/ref/slreq.editor.html) to inspect the requirement and links. Open [Test Manager](https://www.mathworks.com/help/sltest/ref/sltest.testmanager.view.html) to inspect the same persistent test created by the exercise.

## Input mapping and custom criteria

Save the sensor inputs as a supported `Simulink.SimulationData.Dataset` MAT file. Add it with `addInput`, map by the appropriate model-port rule, enable the input, and inspect mapping status before running.

`getCustomCriteria(testCase)` provides the post-simulation criterion. Its callback uses the actual simulation output through `test.sltest_simout` and MATLAB test qualifications. For example, `test.verifyLessThanOrEqual(rmse,0.03)` produces an assessed criterion; displaying RMSE alone does not.

If you rewrite an input MAT file, refresh the case's corresponding TestInput, remap it and save the test before execution. Retain unrelated inputs and tests.

## Native requirement status in R2026b

Put the model, requirement and test artifacts in the opened MATLAB Project. Enable digital-thread output tracking **before** producing results, update artifact information, run the tagged test, and export its real result to the final Project location.

The following continuation uses the variables prepared by the system-testing exercise:

```matlab
trackingSettings = digitalthread.settings();
trackingSettings.ToolOutputTracking = true;
metricEngine = metric.Engine();
updateArtifacts(metricEngine);
results = sltest.testmanager.run(Tags=verificationTag);
sltest.testmanager.exportResults(results,resultFile);
updateArtifacts(metricEngine);
updateVerificationStatus(requirementSet);
nativeStatus = getVerificationStatus(accuracyRequirement(1),'self');
assert(nativeStatus.passed==1 && nativeStatus.failed==0 && ...
    nativeStatus.unexecuted==0);
```

Complete input mapping and save test/link edits before this sequence. Saving a changed test after execution can make its result stale. Exporting and re-importing a result file alone does not preserve its original test-case connection.

| Native status | Meaning |
|---|---|
| Passed | All linked verification items passed |
| Failed | At least one linked verification item failed |
| Unexecuted | A linked item has no current valid execution result |
| None | The requirement has no Verify link |

Change the error threshold or sensor units in your own exercise copy, run again, and observe a Failed status. Restore the intended criterion and rerun to obtain Passed. A requirement with no verification link remains None; it is not Unexecuted.

## Understand the test levels

| Level | Execution | Evidence to inspect |
|---|---|---|
| MIL | Simulated model | Scenario, reference, solver/sample time and errors |
| SIL | Generated code on the host | Same inputs, compiler and equivalence tolerance |
| PIL | Generated code on a target processor | Target execution, numerical agreement and timing |
| HIL | Real-time plant simulation with hardware I/O | Closed-loop behaviour, I/O calibration and timing/fault tests |

A host MEX comparison checks generated-code numerics but is not automatically a SIL simulation. The SIL and PIL exercises execute their corresponding generated interfaces. Enable a target section only with a compatible board, OS and toolchain. HIL requires a separate real-time plant and I/O setup; a processor gateway does not provide it.

Average accuracy, a network output bound, and closed-loop stability are different properties. Requirements should state the relevant metric, operating domain, hardware and measurement method.

## Closed-loop system scenarios (exercise 27)

Open `openExercise(27)` after exercise 9; use `openExercise(27,true)` for the
worked comparison. The model is
`assets/system_integration/models/BatterySystemClosedLoop.slx`, with the trained
neural reference `BatterySystemSOC_AI.slx`. Requested current enters a reserve
supervisor that uses the previous AI SOC estimate. Actual current feeds the
charge/thermal plant. Measured voltage, current and temperature feed the AI.
The estimator therefore affects physical behavior through the feedback loop.

The plant uses a one-second charge balance for a 1-Ah battery, an ohmic voltage
law and one thermal state. Initial SOC is 0.35 and initial temperature is 25 deg C.
True SOC is logged as a simulation test oracle and initializes the known
commissioning condition once; the running supervisor receives the AI estimate.
This is a transparent, fictive, uncalibrated plant for learning the workflow.

| Requirement | Scenario evidence |
|---|---|
| SYS-001: true SOC at least 0.15 | Minimum simulated true SOC |
| SYS-002: temperature at most 45 deg C | Peak simulated battery temperature |
| SYS-003: current between zero and the smaller of demand and 4 A | Requested and actual current |
| SYS-004: reserve trip stops discharge and stays latched | Trip signal, controller estimate and current |
| AI-001: healthy-sensor SOC RMSE at most 0.03 | Estimate compared with simulated true SOC |

`SystemPassed` combines SYS-001 through SYS-004. `AccuracyPassed` reports the
AI criterion separately. At the original cutoff of 0.20, a +0.12-V sensor bias
at 60 seconds produces a physical reserve violation. The worked cutoff of 0.28
restores reserve in this scenario while biased-sensor accuracy still fails.
A larger cutoff also reduces delivered energy in the healthy mission. A
protection margin does not correct the sensor or establish a guarantee over
all faults or real batteries.

`simulateBatterySystem` constructs three time series in a Dataset and uses
`Simulink.SimulationInput`, `setExternalInput`, a model-workspace `setVariable`
override and `sim`. It returns ten output traces and a requirements table.
Saved model and network files remain unchanged between runs.
`TestClosedLoopSystem` checks healthy missions, an actual fault consequence,
margin recovery, healthy energy cost and charge conservation using MATLAB's
unit-test framework. Simulink Test and Requirements Toolbox provide the separate
traceability workflow in exercise 10.

Useful references: [SimulationInput](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.html),
[setExternalInput](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setexternalinput.html),
[setVariable](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setvariable.html),
[sim](https://www.mathworks.com/help/simulink/slref/sim.html), and
[MATLAB unit testing](https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html).

## APIs and documentation

- [Requirements verification](https://www.mathworks.com/help/slrequirements/verify-requirements.html)
- [Test Manager](https://www.mathworks.com/help/sltest/)
- [Custom criteria](https://www.mathworks.com/help/sltest/ug/process-test-results-with-custom-scripts.html)
- [Input mapping](https://www.mathworks.com/help/sltest/ref/sltest.testmanager.testinput.map.html)
- [Digital-thread settings](https://www.mathworks.com/help/slcheck/ref/digitalthread.settings.html)
- [Artifact updates](https://www.mathworks.com/help/slcheck/ref/metric.engine.updateartifacts.html)
- [Native verification-status query](https://www.mathworks.com/help/slrequirements/ref/slreq.requirement.getverificationstatus.html)
- [SIL and PIL](https://www.mathworks.com/help/ecoder/ug/software-and-processor-in-the-loop-sil-and-pil-simulation.html)
