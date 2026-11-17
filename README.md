# ParisSaclay GSSIS - AI for engineered systems

**17-19 November 2026 - MATLAB and Simulink R2026b**

Learn how to define, train, verify and implement AI components for engineered
systems. A battery state-of-charge (SOC) virtual sensor connects the exercises;
thermal models introduce reduced-order modeling (ROM) and physics-informed AI.

## Start here

1. Open `ParisSaclay_GSSIS.prj` in MATLAB R2026b.
2. Run the commands below in the MATLAB Command Window.
3. Use **Run Section** in the Live Editor and complete the task before viewing
   its worked solution.

```matlab
setup_check
demoAgenda
openExercise(1)
```

To compare your reasoning with a solution:

```matlab
openExercise(1,true)
```

The project contains **25 exercise/solution pairs**. Each is a native plain-text
Live Script `.m` with an objective, prerequisites, launch instructions, an
experiment, hints, expected observations and an API cheat sheet.

## Three-day learning path

| Day | Topics | Exercises |
|---|---|---|
| 1 | Agentic tools, measurable requirements, independent data and preprocessing | 1-3, 17 |
| 2 | ML/DL, Python, compression, AI verification and modern apps | 4-8, 15, 23-24 |
| 3 | Simulink, tests, code generation, SIL/PIL, ROMs, physics and agentic practice | 9-14, 16, 18-21, 25-26 |

Work through the basic path first. Exercises initialize the inputs they need
and can be revisited independently with the project open. Hardware and optional
app/Python activities require their stated prerequisites.

## What you will practice

**Requirements - representative data - model - compression and verification ?
integration and tests - generated code and target comparison.**

You will also compare model-based reduction, spatial-field reconstruction,
predictive full-field AI and a cooling PINN. In the agentic exercises, you ask
an engineering agent for a concrete change and check its result with MATLAB or
Simulink.

## Requirements

Complete [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted)
and [Simulink Onramp](https://matlabacademy.mathworks.com/details/simulink-onramp/simulink)
beforehand. `setup_check` lists installed products; each exercise identifies
its required toolboxes, libraries, interpreter, compiler or target support.

The short sensor/thermal examples use explicitly synthetic data. Selected
hardware exercises use provided battery measurements and a pretrained network.
Treat each result within its stated data, operating-domain and target scope.
A missing hardware connection is unavailable, not a passed target test.

## Guides

- [User guide](docs/USER_GUIDE.md): navigation, checks and troubleshooting.
- [Agenda](docs/AGENDA.md): three-day schedule and exercise map.
- [Daily takeaways](docs/DAILY_TAKEAWAYS.md): concepts to retain.
- [Agentic engineering](docs/AGENTIC_GUIDE.md): tools, skills and concrete tasks.
- [ROM guide](docs/ROM_GUIDE.md): model-based, full-field and physics-informed methods.
- [Python and deployment](docs/PYTHON_AND_DEPLOYMENT.md): import and implementation routes.
- [System testing](docs/SYSTEM_TESTING.md): requirements, test criteria and execution levels.
- [R2026b features](docs/R2026B_REFRESH.md): relevant release updates and official help.

Course repository: [ParisSaclay_GSSIS](https://github.com/mgado/ParisSaclay_GSSIS).
Access to the private repository requires permission.
