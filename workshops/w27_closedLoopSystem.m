%[text] # 27 - AI inside a closed-loop battery system
%[text] **Goal:** Test a trained neural SOC estimator as part of a battery plant, sensors and reserve supervisor. The AI estimate changes current, which changes the plant and its future measurements.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB/Simulink R2026b with Deep Learning Toolbox and a supported host C/C++ compiler for model-reference simulation. No hardware, Simscape or additional testing product is needed. Allow 30-35 minutes; the first Simulink compilation takes longer than repeated runs.
%[text] **Launch:** openExercise(27), then use Run Section. Open the model from the section below; open its BatteryPlant and ReserveSupervisor subsystems to inspect the actual equations and decision logic.
%[text] **Your task:** Run a healthy mission, change its load and ambient temperature, inject a voltage-sensor bias, and adjust the reserve margin. Assess true reserve, temperature, actuator limits and delivered energy as well as AI prediction error.
%[text] **Progressive hints:** Change guardStop after the first run. Try 0.24, then 0.28, and predict which physical reserve check will fail or pass. Record the energy cost of your margin.
project = requireTrainingProject;
modelName = 'BatterySystemClosedLoop';
modelFile = fullfile(project.RootFolder,'assets','system_integration','models',[modelName '.slx']);
open_system(modelFile);
defaultStop = 0.20;
guardStop = 0.30;
%%
%[text] ## Step 1: Read the connected system
%[text] Requested current enters the ReserveSupervisor. BatteryPlant integrates charge and temperature and produces terminal voltage. SensorVector contains measured voltage, actual current and temperature, in that order. AI\_SOCEstimator is an actual exported trained neural network. PreviousEstimate provides a one-second control delay; it also breaks the instantaneous feedback loop. The reserve trip latches until the next mission starts.
%[text] The simulated true SOC is logged for tests and initializes the known starting condition once. After initialization, the supervisor receives the AI estimate, rather than true SOC. Its errors can therefore change physical battery behavior.
image(imread(fullfile(project.RootFolder,'assets','system_integration','system_closed_loop.png')));
axis image off;
%%
%[text] ## Step 2: Understand the teaching plant and units
%[text] The plant is deliberately transparent: a 1-Ah charge balance, ohmic terminal voltage and one thermal state. The voltage law matches the simplified training-data law, making the healthy case easy to interpret. The model omits electrochemical dynamics, aging and calibration to a real cell. Its test results apply to the stated fictive scenarios.
%[text:table]
%[text] | Quantity | Equation or value | Meaning |
%[text] | --- | --- | --- |
%[text] | Charge | `SOC(k+1) = SOC(k) - I(k)*Ts/(3600*capacityAh)` | Positive current discharges the battery |
%[text] | Voltage | `V = 3 + 1.2*SOC - 0.05*I + 0.002*(T-25)` | Voltage in V, current in A, temperature in deg C |
%[text] | Thermal state | `T(k+1) = T(k) + Ts*(0.05*I(k)^2 - 0.2*(T(k)-Ta(k)))/100` | Ohmic heating and cooling to ambient |
%[text] | Initial condition | `SOC = 0.35`, `T = 25`, `Ts = 1` | Known commissioning condition; one-second samples |
%[text] | Control | Stop and latch when previous estimated SOC is at most `reserveStop` | Current is otherwise limited to 4 A |
%[text:table]
%%
%[text] ## Step 3: Define system requirements before running scenarios
%[text:table]
%[text] | ID | Requirement | Observable |
%[text] | --- | --- | --- |
%[text] | SYS-001 | True SOC remains at least 0.15 | Minimum simulated true SOC |
%[text] | SYS-002 | Battery temperature stays at most 45 deg C | Peak simulated temperature |
%[text] | SYS-003 | Current stays between zero and the smaller of demand and 4 A | Actual and requested current |
%[text] | SYS-004 | Current is zero after reserve trip and the trip remains latched | Trip, current and controller estimate |
%[text] | AI-001 | Healthy-sensor SOC RMSE is at most 0.03 | Estimate compared with simulated true SOC |
%[text:table]
%[text] SystemPassed combines SYS-001 through SYS-004. AccuracyPassed is reported separately. A faulty voltage sensor falls outside the healthy-sensor accuracy assumption; a protection margin can preserve reserve while the estimator remains inaccurate. Inspect both columns.
%%
%[text] ## Step 4: Establish the standalone and healthy-system references
%[text] Reproduce the original standalone training/held-out accuracy with the same fixed seed and architecture. The system already contains its exported trained network; each mission runs that network without training it on mission results.
[~,standaloneMetrics] = trainSOCNetwork;
standaloneMetrics
assert(standaloneMetrics.rmse<=0.03);
nominal = simulateBatterySystem("nominal",defaultStop);
nominal.Summary
assert(nominal.Summary.SystemPassed && nominal.Summary.AccuracyPassed);
tiledlayout(2,1);
nexttile;
plot(nominal.Trace.Time,nominal.Trace.TrueSOC,nominal.Trace.Time,nominal.Trace.EstimatedSOC);
yline(0.15,'--','Physical reserve');
ylabel('SOC fraction'); legend('Plant truth','AI estimate'); grid on;
nexttile;
plot(nominal.Trace.Time,nominal.Trace.RequestedCurrent,nominal.Trace.Time,nominal.Trace.Current);
xlabel('Time (s)'); ylabel('Current (A)'); legend('Requested','Actual'); grid on;
%%
%[text] ## Step 5: Simulate a changing mission
%[text] The variable scenario changes demand from 1.5 to 3.5 to 6 A, then to 2 and 2.5 A. Ambient rises from 25 to 35 to 40 deg C. Inspect the 4-A actuator limit, thermal response and reserve trip. These inputs exercise interacting components rather than isolated sensor samples.
variable = simulateBatterySystem("variable",defaultStop);
variable.Summary
assert(variable.Summary.SystemPassed);
tiledlayout(2,1);
nexttile;
plot(variable.Trace.Time,variable.Trace.RequestedCurrent,variable.Trace.Time,variable.Trace.Current);
ylabel('Current (A)'); legend('Requested','Actual'); grid on;
nexttile;
plot(variable.Trace.Time,variable.Trace.Ambient,variable.Trace.Time,variable.Trace.Temperature);
yline(45,'--','Thermal limit');
xlabel('Time (s)'); ylabel('Temperature (deg C)'); legend('Ambient','Battery'); grid on;
%%
%[text] ## Step 6: Produce a system failure with the unchanged AI model
%[text] At 60 seconds, inject a +0.12-V sensor bias. Small deterministic measurement noise is present in every scenario. Positive voltage bias makes this estimator overestimate SOC, delaying the reserve trip. The plant and AI are unchanged; the input scenario changes.
biased = simulateBatterySystem("voltageBias",defaultStop);
biased.Summary
assert(~biased.Summary.ReservePassed,'The selected scenario should reveal the reserve failure.');
%[text] This assertion confirms discovery of the intended counterexample. It does not label the faulty mission as safe. Read ReservePassed and MinimumTrueSOC to see the physical violation.
%%
%[text] ## Step 7: Adjust the supervisor and observe the tradeoff
%[text] Change guardStop after the first run. Try 0.24, then 0.28, and predict which physical reserve check will fail or pass. Record the energy cost of your margin. The voltage law suggests 0.12/1.2 = 0.10 SOC of bias. Add the 0.15 physical reserve, one sample of maximum discharge and an allowance for neural error. A margin selected from these scenarios is not a formal guarantee for all faults or all cells.
protected = simulateBatterySystem("voltageBias",guardStop);
protectedNominal = simulateBatterySystem("nominal",guardStop);
comparison = [nominal.Summary;variable.Summary;biased.Summary;protected.Summary;protectedNominal.Summary]
assert(protected.Summary.SystemPassed,'Increase the margin and rerun if reserve is still violated.');
assert(~protected.Summary.AccuracyPassed,'A controller margin does not repair sensor bias.');
assert(protectedNominal.Summary.DeliveredWh<nominal.Summary.DeliveredWh);
tiledlayout(2,1);
nexttile;
plot(biased.Trace.Time,biased.Trace.TrueSOC,protected.Trace.Time,protected.Trace.TrueSOC);
yline(0.15,'--','Physical reserve');
ylabel('True SOC'); legend('Original cutoff under bias','Revised cutoff under bias'); grid on;
nexttile;
bar([nominal.Summary.DeliveredWh,protectedNominal.Summary.DeliveredWh]);
xticklabels({'Healthy original cutoff','Healthy revised cutoff'});
ylabel('Delivered energy (Wh)'); grid on;
%%
%[text] ## Step 8: Inspect the actual simulation and test APIs
%[text] Open simulateBatterySystem.m in the Editor. It builds three time series in a Dataset, uses SimulationInput.setExternalInput, overrides reserveStop in this model's workspace with setVariable, then runs sim. The saved model and network are unchanged between scenarios. It extracts ten root outputs from SimulationOutput.yout and computes the explicit requirements above.
%[text] The following configuration shows the model-workspace override. It prepares a simulation; execution occurs only when sim is called, as in the helper.
simulation = Simulink.SimulationInput(modelName);
simulation = simulation.setVariable('reserveStop',guardStop,Workspace=modelName);
%[text] Run the persistent regression suite to confirm healthy behavior, a real fault consequence, margin recovery, energy cost and charge conservation.
testResults = runtests(fullfile(project.RootFolder,'tests','TestClosedLoopSystem.m'));
assertSuccess(testResults);
%%
%[text] ## Troubleshooting and interpretation
%[text] On the first run, wait for Simulink to compile the referenced neural model. If the reference cannot be resolved, reopen ParisSaclay\_GSSIS.prj and confirm that assets/system\_integration/models is on its project path. A model-name conflict must be resolved without overwriting another model. If a new margin fails, inspect the measured reserve and estimate error; do not delete the failing requirement. Use exercise 10 for requirement links and native verification status, 23 for bounded neural verification and 25 for generated-code SIL. Those answer different questions from this system scenario.
%[text] Remember: a plausible plant is sufficient to learn the workflow, but its assumptions determine what the results establish. Reserve protection, prediction accuracy and delivered energy are separate engineering observations.
%%
%[text] ## Documentation and further reading
%[text] [Main Simulink simulation documentation](https://www.mathworks.com/help/simulink/run-simulations.html), [Deep Learning Toolbox documentation](https://www.mathworks.com/help/deeplearning/), and [MATLAB unit testing](https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html).
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal syntax | Purpose |
%[text] | --- | --- | --- |
%[text] | [open_system](https://www.mathworks.com/help/simulink/slref/open_system.html) | `open_system(modelFile)` | Inspect the connected model and its subsystems |
%[text] | [Simulink.SimulationInput](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.html) | `simulation = Simulink.SimulationInput(modelName)` | Configure one scenario |
%[text] | [setExternalInput](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setexternalinput.html) | `simulation.setExternalInput(inputs)` | Apply mission demand, ambient and sensor bias |
%[text] | [setVariable](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setvariable.html) | `simulation.setVariable('reserveStop',value,Workspace=modelName)` | Change a control margin for one run |
%[text] | [sim](https://www.mathworks.com/help/simulink/slref/sim.html) | `output = sim(simulation)` | Execute the whole coupled system |
%[text] | [Dataset](https://www.mathworks.com/help/simulink/slref/simulink.simulationdata.dataset.html) | `inputs = Simulink.SimulationData.Dataset` | Keep input signals and order explicit |
%[text] | [simulateBatterySystem](../src/simulateBatterySystem.m) | `result = simulateBatterySystem("voltageBias",0.28)` | Visible scenario setup and measured requirement table |
%[text] | [trapz](https://www.mathworks.com/help/matlab/ref/trapz.html) | `trapz(time,voltage.*current)/3600` | Integrate delivered energy in Wh |
%[text] | [runtests](https://www.mathworks.com/help/matlab/ref/runtests.html), [assertSuccess](https://www.mathworks.com/help/matlab/ref/matlab.unittest.testresult.assertsuccess.html) | Run the TestClosedLoopSystem suite and require success | Preserve system-level regression evidence |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
