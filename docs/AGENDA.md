# Three-day hands-on agenda

**17–19 November 2026 · 09:00–17:00 · MATLAB and Simulink R2026b**

The programme follows one engineering story: a battery management system uses an AI virtual sensor to estimate state of charge. We define its contract, prepare representative data, train and compare models, verify behavior, integrate the estimator in Simulink, and check generated code. Thermal reduced-order models extend the same story to fast simulation and virtual sensing.

Written materials are in English. The instructor provides explanations in French. Bring a laptop and mouse. Complete MATLAB Onramp and Simulink Onramp beforehand; see [preparation links](LEGACY_HANDSON_REFERENCES.md#prepare-before-the-training).

## How to use the workshops

Open `ParisSaclay_GSSIS.prj` first, run `setup_check`, then use `demoAgenda` to see the exercise catalog. Each exercise has a plain-text Live Script in `workshops/` and a matching solution in `solutions/`. Use `openExercise(number)` to work section by section. Follow the launch instructions, hints, expected results and API cheat sheet inside the selected file.

**Basic path:** short, visible API steps using included teaching assets. It demonstrates the engineering principle without requiring long training or connected hardware.

**Advanced path:** a separate extension using richer datasets, Python/PyTorch, formal verification, neural PDE solvers or connected hardware. Check prerequisites first. A missing add-on, compiler, dataset or hardware connection is an availability gap, not a passing execution.

Exercise numbers identify topics; they do not require a fixed execution order. The instructor may start with the agentic introduction, revisit it during data/model work, and finish with the agentic engineering exercise. Each workshop initializes the inputs it needs.

## Day 1 — Requirements, representative data and engineering evidence

| Time | Topic and exercises | Intended outcome |
|---|---|---|
| 09:00–09:45 | Welcome, engineered-system story, **1 — `w01_agentSetup`** | Check MATLAB/toolkit readiness and understand what evidence an engineering agent must produce |
| 09:45–10:30 | System requirements and **2 — `w02_requirements`** | Write measurable accuracy, operating-domain and resource requirements; inspect them in Requirements Editor |
| 10:30–10:45 | Break | |
| 10:45–12:00 | BMS architecture, interfaces, requirement links and guided continuation of exercise 2 | Give the AI estimator a testable system role; understand requirement/model/test traceability |
| 12:00–12:30 | Simulation as a data factory | Design scenarios and explain why simulation labels and held-out conditions matter |
| 12:30–13:30 | Lunch | |
| 13:30–14:30 | **3 — `w03_data`**: data management and leakage prevention | Split by scenario, preserve data provenance and inspect coverage |
| 14:30–14:45 | Break | |
| 14:45–16:00 | **17 — `w17_dataPreparation`**: preprocessing and annotation; app walkthroughs | Clean time-series measurements, inspect outliers/missing values and understand reproducible app-to-code preparation |
| 16:00–17:00 | Guided practice, data/requirements review and next-day model contract | Produce a prepared dataset and explain how it supports the requirements |

## Day 2 — Modeling, Python, compression and AI verification

| Time | Topic and exercises | Intended outcome |
|---|---|---|
| 09:00–10:00 | Model selection and **4 — `w04_mlBaseline`** | Train a compact virtual sensor and compare against a simple baseline |
| 10:00–10:30 | **5 — `w05_deepLearning`** | Build and evaluate a small neural estimator; understand `dlnetwork`, training options and prediction |
| 10:30–10:45 | Break | |
| 10:45–12:00 | Continue exercise 5; **15 — `w15_appWorkflows`** | Inspect modeling apps without hiding the generated workflow; connect app choices to data and system needs |
| 12:00–12:30 | Model evaluation and interpretation | Separate training fit, held-out performance and meaningful failure investigation |
| 12:30–13:30 | Lunch | |
| 13:30–14:30 | **6 — `w06_pythonImport`** | Exchange numeric data with Python and distinguish third-party model import from direct deployment routes |
| 14:30–14:45 | Break | |
| 14:45–15:45 | **7 — `w07_modelCompression`** | Measure size/error tradeoffs, explain projection/pruning/quantization and recheck requirements |
| 15:45–17:00 | **8 — `w08_aiVerification`**; optional ACAS Xu reference workshop | Distinguish scenario tests, adversarial search and bounded formal verification; interpret verified, unproven and violated outcomes |

## Day 3 — Integration, implementation, ROMs and agentic capstone

| Time | Topic and exercises | Intended outcome |
|---|---|---|
| 09:00–10:15 | **9 — `w09_simulinkIntegration`** and **10 — `w10_systemTesting`** | Integrate the estimator, inspect system behavior, link requirements and tests, and replay scenarios |
| 10:15–10:30 | Break | |
| 10:30–11:30 | **11 — `w11_codegen`**; MIL/SIL/PIL/HIL discussion | Generate and compare host code; explain what additional target evidence is needed for PIL/HIL |
| 11:30–12:30 | Unified ROM landscape; **12 — `w12_modelBasedROM`** and **13 — `w13_fullFieldROM`** | Choose techniques from available physics/data and required scalar, dynamic or spatial outputs; reconstruct and inspect a reduced field |
| 12:30–13:30 | Lunch | |
| 13:30–14:30 | **19 — `w19_predictiveFieldROM`** and **14 — `w14_physicsInformed`** | Predict a field for an unseen operating point; infer a cooling parameter using physical constraints |
| 14:30–14:45 | Break | |
| 14:45–15:30 | **18 — `w18_pinnCooling`**; optional Neural PDE/full-field extensions | See an actual physics-informed loss and automatic differentiation; distinguish a PINN from fitting a known parametric equation |
| 15:30–16:30 | **16 — `w16_agentEngineering`** | Use builtin and custom skills for a concrete engineering task, then inspect and independently verify the result |
| 16:30–17:00 | Final regression, evidence review and next steps | Explain the complete requirement → data → model → test → implementation chain and replay the selected workshops |

## Exercise map

| Number | ID | Day | Basic outcome | Advanced extension |
|---:|---|---:|---|---|
| 1 | `w01_agentSetup` | 1 | Environment/toolkit readiness and evidence contract | Connect the selected engineering agent |
| 2 | `w02_requirements` | 1 | Measurable AI requirements | Requirement links, architecture and UI editing |
| 3 | `w03_data` | 1 | Scenario split and leakage prevention | Broader simulation design-of-experiments |
| 4 | `w04_mlBaseline` | 2 | Compact regression virtual sensor | Compare model families in learner apps |
| 5 | `w05_deepLearning` | 2 | Small neural estimator | Longer sequence-model training |
| 6 | `w06_pythonImport` | 2 | Numeric MATLAB/Python exchange | Supported PyTorch model import/direct codegen route |
| 7 | `w07_modelCompression` | 2 | Size/error comparison and retest | Product-specific projection/pruning/quantization |
| 8 | `w08_aiVerification` | 2 | Test and bound estimator behavior | ACAS Xu local robustness/global verification |
| 9 | `w09_simulinkIntegration` | 3 | Executable AI-system model | Broader battery/plant model |
| 10 | `w10_systemTesting` | 3 | Linked model/test/requirement evidence | Richer Test Manager scenario suites |
| 11 | `w11_codegen` | 3 | Generated-code comparison on host | Board-specific PIL, HIL, CUDA or HDL workflow |
| 12 | `w12_modelBasedROM` | 3 | Reduced thermal dynamics | Larger physical state-space model |
| 13 | `w13_fullFieldROM` | 3 | Reduced-basis field reconstruction and derived KPIs | Higher-resolution spatial model |
| 14 | `w14_physicsInformed` | 3 | Physics-constrained inverse parameter estimation | Richer coupled-physics calibration |
| 15 | `w15_appWorkflows` | 2 | Inspect modern AI app choices and launch steps | Time Series/Visual Anomaly/ROM app workflows |
| 16 | `w16_agentEngineering` | 3 | Verified baseline and concrete agent task | Compare builtin and custom skill-guided changes |
| 17 | `w17_dataPreparation` | 1 | Clean and inspect raw time-series measurements | Annotation, feature extraction and app-generated code |
| 18 | `w18_pinnCooling` | 3 | Neural physics loss with automatic differentiation | PDE PINN or neural operator |
| 19 | `w19_predictiveFieldROM` | 3 | Input-to-field prediction on an unseen operating point | 3D Neural PDE surrogate |

The exercise catalog and each Live Script are the source of truth for available files, prerequisites and actual launch commands. Optional extension links are collected in [Legacy Hands-on References](LEGACY_HANDSON_REFERENCES.md). Hardware deployment requires the exact supported target, toolchain and connection; a host test does not establish PIL or HIL success.

## Prioritized hardware block

