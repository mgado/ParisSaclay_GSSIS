# ParisSaclay GSSIS — AI for engineered systems

Three-day hands-on training, **17–19 November 2026**, MATLAB and Simulink R2026b.
Written materials are in English; French instructor prompts accompany each block.

## Start here

1. Complete MATLAB Onramp and Simulink Onramp beforehand.
2. Open `ParisSaclay_GSSIS.prj` in this folder.
3. At the MATLAB Command Window, run `setup_check`, then `demoAgenda`.
4. Run `openExercise(1)` and use **Run Section** in the Live Editor.
5. Run `openExercise(1,true)` to compare the worked solution.

Each exercise is a **native plain-text Live Script `.m`**, with rich text,
visible APIs, working starter values, an experiment to perform, progressive hints,
expected observations, troubleshooting and an API cheat sheet. Change the working
values deliberately and record the result before reading the solution.

## Engineering story

Can a battery state-of-charge virtual sensor meet its requirements across its
operating domain and implementation constraints? Follow the chain:

**requirements → data → ML/DL → import → compression → verification → Simulink
integration → tests → generated code → hardware evidence**.

Thermal models extend that story into model-based ROM, full-field reconstruction,
and physics-informed learning. Agentic engineering supports the same steps;
actual execution, tests and traceability assess its output.

## How the three days fit together

| Day | Main work | Exercises |
| --- | --- | --- |
| 1 | Agent toolkit readiness, engineering requirements, data and operating domain | 1–3; data cleaning extension |
| 2 | ML/DL, Python, compression, formal bounds, modern apps | 4–8, 15 |
| 3 | Simulink, tests, code generation, ROM and agent engineering | 9–14, 16; PINN/full-field extensions |

The stable catalog supports reordering: agentic work can start the training or
return after the technical fundamentals. The programme contains five themes;
they run across these three days rather than one theme per day.

## Products and optional paths

The numerical baseline uses MATLAB, Statistics and Machine Learning Toolbox,
Deep Learning Toolbox, Requirements Toolbox, Simulink, Simulink Test and
MATLAB Coder. Specific exercises state their own prerequisites.

Python/PyTorch, formal AI verification, quantization, modern apps and physical
targets require their corresponding interpreter/library/support package/product.
Nothing installs automatically. `setup_check` reports installed products;
successful installation does not prove a hardware connection or license checkout.

The synthetic sensor and thermal datasets are explicitly teaching models. They
are not measured battery data, certified plant models or industrial performance
claims. Test results establish behavior on the documented teaching inputs only.

## Checks

With this project open, run `buildtool` from the project root. It checks runtime
source and runs the nonempty unit test suite. Workshop execution, UI rendering,
optional Python, formal verification and code generation are recorded separately
in `docs/VALIDATION.md`; a walkthrough is never reported as an executed pass.

## Further reading

- `docs/USER_GUIDE.md`: detailed student workflow and recovery.
- `docs/AGENTIC_GUIDE.md`: toolkit round trip, builtin/custom skill exercise.
- `docs/ROM_GUIDE.md`: unified ROM choice and thermal examples.
- `docs/PYTHON_AND_DEPLOYMENT.md`: editable import versus direct code generation.
- `docs/SYSTEM_TESTING.md`: requirements/model/test traceability and test levels.
- `docs/R2026B_REFRESH.md`: release-specific updates with official references.

## Distribution

This folder is the student-facing source tree. The separate development materials
and internal reference slides are not part of the student distribution. Repository
publication is deferred; the intended visibility is private initially.

## Two hardware prototype paths
The catalog also includes Simulink PIL (20) and MATLAB command-line AI deployment/PIL (21), prioritized for Day3. Both use the real Expo SOC assets and preserve actual passed/unavailable/failed hardware evidence. A Raspberry Pi4 plugged only into USB-Cpower has no configured network path by default; connect/configure Ethernet, Wi-Fi or USB gadget networking before live PIL. No hardware run is inferred from host validation.

