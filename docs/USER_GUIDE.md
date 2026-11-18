# Using the workshops

Exercise 27 starts with an introduction for readers without battery or vehicle
background. It explains SOC, discharge and delivered power, reserve protection,
unmet demand after a cutoff, and what complete-system tests catch and confirm.

API cheat sheets include an **Origin** column naming the MathWorks product or
add-on. **Training helper** identifies a provided function, not a toolbox API;
generated interfaces and shipped example data have separate labels. Read the
[helper reference](TRAINING_HELPERS.md) when an exercise calls a provided wrapper.

Exercise 27 includes a [full-resolution system diagram](../assets/system_integration/system_closed_loop.png),
a [vector SVG view](../assets/system_integration/system_closed_loop.svg) and a
[PDF view](../assets/system_integration/system_closed_loop.pdf). Use the vector
view to zoom into block labels and connections.

## Quick start

Open `ParisSaclay_GSSIS.prj` in MATLAB R2026b, then run:

```matlab
setup_check
demoAgenda
openExercise(1)
```

Use **Run Section** to follow the visible steps. Predict the effect of the
requested parameter change, run it, and record your observation before opening
`openExercise(1,true)` for the worked solution.

## Choose an exercise

The catalog contains 26 pairs with stable numbers and IDs: 1-21 and 23-27.
Select by number or exact ID:

For discoverable names, type `openExercise("` and press **Tab**. Completion
offers numbered topic labels and their short keywords. `demoAgenda` lists
the keys and descriptions together. These calls select the same exercise:

```matlab
openExercise(2)
openExercise("02-Requirements")
openExercise("Requirements")
openExercise("w02_requirements")
openExercise("Requirements",true)
```

The last call opens the solution. Text matching is case insensitive; a key
without a leading zero, such as `"2-Requirements"`, is also accepted. The
full catalog description can be used as a text selector. If a session was
already open when the files were updated, run `rehash` to refresh file discovery.

```matlab
openExercise(3)
openExercise("w19_predictiveFieldROM")
openExercise(19,true)
```

`workshops/` contains tasks and hints; `solutions/` contains worked comparisons.
`src/` contains the reusable functions explained in the lessons. `tests/`
contains automated checks. `docs/` provides topic help and further reading.

Each exercise initializes its required inputs. With the project open, it does
not depend on variables left by a previous exercise. When an exercise asks you
to modify code or a model, use your own copy and keep the supplied solution for
comparison.

## Follow the engineering story

Start with an SOC estimator's requirements and sensor-input contract. Prepare
independent data groups, compare ML/DL candidates, evaluate compression and
verification, integrate the network in Simulink, then compare implementation
results. The thermal exercises ask which dynamics or spatial quantities a
smaller model must retain.

The agentic activities connect an agent to engineering tools, use builtin and
custom skills, and require actual checks of proposed changes. A convincing
explanation alone does not establish that the change works.

### Run AI within the complete simulated system

After exercise 9, open `openExercise(27)` or the worked solution with
`openExercise(27,true)`. The included `BatterySystemClosedLoop.slx` couples
the trained neural SOC estimator to battery charge/thermal dynamics, voltage
measurements and a latched reserve supervisor. The estimate changes current,
which changes the plant and its future measurements. A known starting condition
is provided once; running control uses estimated SOC and tests observe true SOC.

Allow 30-35 minutes and a longer first compilation. MATLAB, Simulink, Deep
Learning Toolbox and a supported host C/C++ compiler are required. Compare
healthy and changing-load/temperature missions, inject voltage bias, and adjust
the reserve cutoff. A margin can protect reserve while the AI remains inaccurate,
and it reduces delivered energy in healthy operation. The transparent plant
is fictive and uncalibrated; these tests concern its stated scenarios.

Run `runtests('tests/TestClosedLoopSystem.m')` for the persistent system checks.
See [system scenarios and requirements](SYSTEM_TESTING.md#closed-loop-system-scenarios-exercise-27)
for the criterion definitions and configuration APIs.

## Run checks

From the project root, run:

```matlab
buildtool
```

This performs Code Analyzer checks and automated tests. You can run the unit
suite directly with:

```matlab
results = runtests("tests");
assertSuccess(results);
```

For an isolated worked execution, `runExercise(3,true)` runs the selected
solution and returns its status. Read the declared mode: completing an app
availability check or host prediction does not mean a connected-agent, app
training or physical-target activity was executed.

## Prerequisites and outputs

- Use MATLAB and Simulink R2026b and the products listed in the exercise.
- Inspect visible seeds, widths, thresholds and operating bounds before changing them.
- Python/PyTorch, quantization and desktop app activities need their corresponding dependencies.
- Hardware activities need the named board, supported OS/toolchain, a working connection and the required support package.
- Generated models, data, reports and implementation outputs are placed in `generated/` as indicated by each lesson.

For hardware, check the [PIL hardware guide](PIL_HARDWARE_GUIDE.md) first. A host
MEX, SIL execution and processor-in-the-loop run are different checks. Preserve
numerical equivalence, target timing and configuration information separately.

## Interpret results carefully

A low held-out error concerns the specified data and operating conditions.
Formal output bounds concern the chosen network and bounded input region.
Neither alone certifies the whole battery system.

The short sensor/thermal datasets are synthetic. Selected target exercises use
provided measured battery signals. Field reconstruction of an already known
snapshot is different from predicting an unseen field from input parameters.
A one-dimensional cooling PINN is not a trained spatial PDE solver.

## Troubleshooting

| Problem | What to check |
|---|---|
| Function or project not found | Open the supplied `.prj` and verify that its project path is active |
| Missing toolbox/library | Read the exercise prerequisites and use a topic that your installation supports |
| Unexpected training result | Check seed, data partitions, architecture, units and normalization before tuning |
| Simulink input mismatch | Match port data type, dimensions and sample times to the supplied input Dataset |
| Python error | Inspect `pyenv`, compatible Python version and module availability |
| Screenshot differs from your app | Follow the current app help and menu labels; screenshots illustrate the relevant UI activity |
| Hardware unavailable | Check power, networking, authentication, supported OS and target setup; do not report the target test as passed |

Useful help: [MATLAB Projects](https://www.mathworks.com/help/matlab/projects.html),
[Live Scripts](https://www.mathworks.com/help/matlab/live-scripts-and-functions.html),
and the API links at the end of each exercise.
