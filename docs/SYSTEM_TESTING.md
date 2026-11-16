# Requirements, integration and test evidence

## Traceability chain

Exercise 2 creates a `.slreqx` requirement set and an implementation link.
Exercise 9 exports an actual layer-block Simulink network.
Exercise 10 creates a persistent `.mldatx` test, maps a held-out sensor trace, runs a custom RMSE criterion, and updates the linked requirement verification status.

The link records **what a test is intended to verify**. Verification status
requires executed criteria and result propagation; a smoke simulation or link
alone does not verify accuracy.

## Taught Test Manager activity

1. Open the model with `open_system(ensureSOCModel)`.
2. Open Test Manager with `sltest.testmanager.view`.
3. Inspect the test file created in exercise 10.
4. Import the sensor trace using `addInput(testCase,inputFile)` after saving a
   supported Dataset input MAT file. Inspect the input mapping and dimensions.
5. Add meaningful criteria through `getCustomCriteria(testCase)` or the UI:
   compare output SOC against the retained reference with RMSE <= 0.03.
6. Run the test and inspect the result; introduce a deliberately inaccurate
   model or wrong sensor units to observe a failed requirement.
7. Inspect the verification link and resulting requirement status in Requirements
   Editor. Keep the result artifact, input mapping and threshold in your evidence.

The included MATLAB unit suite independently executes nominal, range,
temperature-compensation and held-out neural-accuracy checks. Those are
meaningful host checks; they do not replace a system test against the plant.

## Test levels

| Level | Execution | Evidence needed |
| --- | --- | --- |
| MIL | Simulated model | Scenario, reference, solver/sample time, error metrics |
| SIL | Generated code on host | Same scenarios and equivalence tolerance, compiler |
| PIL | Target processor | Actual transfer/execution, numerical results, timing |
| HIL | Real-time plant simulation and hardware I/O | Closed-loop behavior, IO calibration, deadline/fault evidence |

Exercise 11 generates a host MEX and compares numerics for the analytic baseline.
It is generated-code host equivalence, not a Simulink SIL mode run. Physical
PIL/HIL require the instructor's configured hardware and are optional runbooks.

## What requirements need

- Accuracy: threshold, metric, independent dataset, operating domain.
- Latency: deadline, hardware, workload, measurement method.
- Memory: target budget and measured artifact/runtime footprint.
- Robustness: uncertainty set, failure policy, tests or formal property.
- Traceability: links among requirement, dataset/model, implementation and test.

Avoid assigning a safety verdict from average accuracy. The network's formal
output bounds and the plant's closed-loop stability are different properties.

## Executed exercise path
The supplied exercise authors and executes these Test Manager steps automatically. Its custom criterion checks sample count, timestamps, finite predictions and held-out RMSE at most 0.03. The UI activity lets students inspect that same artifact and deliberately change the threshold or sensor units. Current execution results are recorded in VALIDATION.md; the legacy MIL/SIL screenshots remain historical UI guidance.

## R2026b native status tracking
In the rehearsal, Test Manager's custom RMSE test passed, but Requirements Toolbox's native verification cache remained unexecuted. The exercise records actual test outcome separately in requirementVerificationEvidence.json. Do not call an unexecuted native status passed. For exported-result discovery, use Project Digital Thread Settings > Track tool outputs before exporting results, allow artifact tracing to complete, then refresh verification status. Export/import alone does not preserve the original testcase connection. The passed test and native cache state are distinct evidence.

## Resolved native Requirements Toolbox status
Exercise10 now registers its generatedmodel/requirements/testfolders with the MATLABProject, refreshes the ownedTestInput when its MATfileisrewritten, asserts successfulmapping, enables digitalthread.settings.ToolOutputTracking before execution, updates artifacts before/after the taggedglobalTestManagerrun, and exports the real result to its finalprojectlocation. It then calls updateVerificationStatus and asserts nativeSOC001 passedwithzero failed/unexecuted. The livepass→intentionalfail→restoredpass transitionwasverified; nojustification/manualstatussetterused. SOC002 hasno verificationlinkandremains none, whichis distinctfrom unexecuted.
