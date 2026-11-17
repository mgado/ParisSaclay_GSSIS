# Three-day hands-on agenda

**17-19 November 2026 - 09:00-17:00 - MATLAB and Simulink R2026b**

Follow a battery SOC virtual sensor from requirements and representative data
through modeling, verification, integration and implementation. Thermal
examples extend the same engineering questions to ROMs and physics-informed AI.

Open `ParisSaclay_GSSIS.prj`, run `setup_check` and `demoAgenda`, then select a
workshop with `openExercise(number)`. Use **Run Section** and compare your work
with `openExercise(number,true)` after recording your own observations.

## Day 1 - Requirements and representative data

| Time | Topic | Exercises |
|---|---|---|
| 09:00-09:45 | Engineering story, agent/tool/skill distinction and connection checks | 1 |
| 09:45-10:30 | Measurable AI requirements and operating limits | 2 |
| 10:30-10:45 | Break | |
| 10:45-12:00 | Interfaces, requirement links and guided practice | 2 |
| 12:00-12:30 | Scenario design and independent data groups | 3 |
| 12:30-13:30 | Lunch | |
| 13:30-14:30 | Data inspection, units and leakage prevention | 3 |
| 14:30-14:45 | Break | |
| 14:45-16:00 | Missing samples, outliers, cleaning and retiming | 17 |
| 16:00-17:00 | Data/requirements practice and recap | 2, 3, 17 |

## Day 2 - Models, compression and AI verification

| Time | Topic | Exercises |
|---|---|---|
| 09:00-10:00 | Model choice and transparent ML baseline | 4 |
| 10:00-10:30 | Compact neural estimator | 5 |
| 10:30-10:45 | Break | |
| 10:45-12:00 | Training, model comparison and modern apps | 5, 15 |
| 12:00-12:30 | Validation, final test and interpretation | 4, 5 |
| 12:30-13:30 | Lunch | |
| 13:30-14:30 | Python data exchange, network import and direct deployment routes | 6 |
| 14:30-14:45 | Break | |
| 14:45-15:30 | Precision/calibration changes and requirement rechecks | 7 |
| 15:30-17:00 | Output bounds, trained-network/OOD checks, adversarial examples and robustness | 8, 23, 24 |

## Day 3 - Integration, implementation, ROMs and agentic practice

| Time | Topic | Exercises |
|---|---|---|
| 09:00-10:00 | Neural Simulink model and requirement-driven Test Manager checks | 9, 10 |
| 10:00-10:15 | Break | |
| 10:15-11:15 | Host code generation and actual SIL comparison | 11, 25 |
| 11:15-12:30 | Target-dependent PIL paths: choose the available board/activity | 20, 21, 26 |
| 12:30-13:30 | Lunch | |
| 13:30-14:45 | Model-based ROM, spatial reconstruction and predictive full-field AI | 12, 13, 19 |
| 14:45-15:00 | Break | |
| 15:00-16:00 | Physics-constrained inverse fitting and a cooling PINN | 14, 18 |
| 16:00-17:00 | Builtin/custom skills, a concrete engineering task and final recap | 16 |

## Exercise map

| Number | Stable ID | Main task |
|---:|---|---|
| 1 | `w01_agentSetup` | Check toolkit capabilities and an actual tool round trip |
| 2 | `w02_requirements` | Define measurable AI requirements |
| 3 | `w03_data` | Manage independent data groups and prevent leakage |
| 4 | `w04_mlBaseline` | Train a simple virtual sensor |
| 5 | `w05_deepLearning` | Train and evaluate a compact neural estimator |
| 6 | `w06_pythonImport` | Exchange Python data and distinguish model routes |
| 7 | `w07_modelCompression` | Recheck the model after precision/calibration changes |
| 8 | `w08_aiVerification` | Bound network outputs over a specified input box |
| 9 | `w09_simulinkIntegration` | Export and simulate the neural estimator |
| 10 | `w10_systemTesting` | Link requirements, model and meaningful test criteria |
| 11 | `w11_codegen` | Generate code and compare host numerics |
| 12 | `w12_modelBasedROM` | Project a thermal dynamical model |
| 13 | `w13_fullFieldROM` | Encode/reconstruct a spatial field and inspect its quantities |
| 14 | `w14_physicsInformed` | Infer a physical cooling coefficient |
| 15 | `w15_appWorkflows` | Inspect modern AI app workflows |
| 16 | `w16_agentEngineering` | Make and verify a skill-guided engineering change |
| 17 | `w17_dataPreparation` | Repair and retime independent acquisition logs |
| 18 | `w18_pinnCooling` | Train a neural cooling solution with a physics loss |
| 19 | `w19_predictiveFieldROM` | Predict unseen fields from heating/cooling parameters |
| 20 | `w20_hardwarePIL` | Run the neural predictor through model-reference PIL |
| 21 | `w21_matlabHardware` | Compare neural target results through MATLAB command-line PIL |
| 23 | `w23_advancedVerification` | Explore trained-network verification and OOD detection |
| 24 | `w24_adversarialWorkshop` | Find adversarial examples and evaluate formal robustness |
| 25 | `w25_silVerification` | Compare neural generated-code SIL outputs with MATLAB |
| 26 | `w26_jetsonCameraPIL` | Explore Jetson Thor image/camera PIL |

## Choose a feasible path

The short numerical path uses supplied data and visible APIs. Python, apps,
verification libraries, compilers and hardware require their stated
prerequisites. Hardware activities are alternatives within the available time;
complete the one whose target is configured, then explore the others later.

The catalog and each Live Script specify products, mode and estimated duration.
A missing target/library is unavailable, not a passed activity. The synthetic
sensor/thermal examples teach the method; selected hardware lessons use provided
measured battery data. Keep conclusions within each example's scope.

Further reading: [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted),
[Simulink Onramp](https://matlabacademy.mathworks.com/details/simulink-onramp/simulink)
and the official topic/API links in each exercise.
