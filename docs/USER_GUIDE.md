# Student user guide

## Quick Start

Open `ParisSaclay_GSSIS.prj`, then run:

```matlab
setup_check
demoAgenda
openExercise(1)
```

Use the Live Editor's **Run Section** to work through a lesson. Its starter has
working values; perform the named experiment before opening the solution with
`openExercise(1,true)`. Exercises initialize their own data and can run independently
after the Project is open. They do not rely on a previous exercise's workspace.

Use `runExercise(3,true)` for an isolated solution rehearsal. Its returned status
distinguishes an execution failure from success; its declared mode still identifies
optional agent/app/hardware walkthroughs. Executing a capability-check section
does not mean the optional target action ran.

## Navigation and lesson roles

The catalog has stable numbers and IDs. It records the source, solution, day,
products, mode and estimated classroom time. Unknown IDs raise an error instead
of silently selecting a different exercise.

- `workshops/`: student experiments with runnable starting values and hints.
- `solutions/`: matching worked reasoning and complete comparison paths.
- `src/`: small reusable functions, each explained where used.
- `tests/`: meaningful unit verification, separate from demonstrations.
- `assets/screenshots/`: original UI screenshot guidance with provenance.
- `docs/`: agenda, deployment, test, ROM, agentic and recovery guides.

## The coherent story

Begin with battery SOC requirements and data, then train a virtual sensor,
evaluate/verify/compress it, export it into Simulink and compare generated code.
Thermal exercises introduce ROMs and physics-informed neural learning using
the same engineered-system mindset: define outputs and domains, keep independent
test cases, and retain evidence.

## Running checks

`buildtool` runs runtime Code Analyzer checks and the actual unit tests.
The checked functions include sensor bounds/units and held-out neural accuracy.
Exercise execution, Live Editor rendering, formal output bounds, code generation,
Python import and app activities have separate evidence in `VALIDATION.md`.

Run MATLAB from the Project root for `buildtool`; resource paths inside lessons
come from `project.RootFolder`, so the lesson logic is independent of Current Folder.

## Configuration

- Target teaching release: R2026b. Native plain-text Live Scripts require R2025a+;
  only R2026b is validated for this delivery.
- Dataset seeds and model widths are visible in each exercise.
- Optional Python/PyTorch, quantization and desktop launches are opt-in flags.
- Runtime outputs go under `generated/`; original source data/slides stay separate.
- Hardware steps require the identified board, supported toolchain and actual
  target connection. No hardware deployment runs automatically.

## Troubleshooting

- **Unknown function/project:** open the supplied `.prj`; do not patch paths.
- **Missing product/library:** record unavailable and follow the independent core
  route or documented walkthrough.
- **Simulink data mismatch:** match the exported port's type, dimensions and
  sampling with the input Dataset; the supplied example uses double sensor data.
- **Training metric changed:** verify seed, split and architecture before tuning.
- **Python failed:** inspect `pyenv` and module availability; do not reset another
  person's Python session without permission.
- **UI differs from screenshot:** the supplied UI images are from the original
  training deck. Read the screenshot provenance and current app documentation.

## Teaching limits

Synthetic measurements and fields make the workflow short and reproducible.
They establish no battery chemistry validity, industrial accuracy, hardware
latency or safety certificate. The original public hands-on references provide
the longer domain-specific extensions. PIL/HIL and the external full-field ROM
app remain target/add-on dependent; their unexecuted status is explicit.

## Build a local archive
With the Project root selected, run buildtool package. It depends on the actual check/test tasks, creates a clean archive under generated/packages, extracts it for structural inspection, and writes a file manifest. It excludes Git history and agent/development folders. No remote publication occurs.
