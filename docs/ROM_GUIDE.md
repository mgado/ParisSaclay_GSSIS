# Reduced order modelling: one engineering question, several methods

The battery training story needs fast models for simulation, controller testing and eventual deployment. The thermal extension asks a concrete question: can a smaller model preserve temperatures, dynamics and operating limits that matter to the engineering requirements?

| Method | What is reduced or learned | Training information | Main acceptance question | Exercise |
|---|---|---|---|---|
| Model-based projected ROM | Known state equations projected onto a small basis | Representative full-model trajectories | Does the reduced dynamical model reproduce unseen inputs? | 12 |
| Full-field compression | Spatial temperature snapshots represented by a few coefficients | Training fields on a consistent mesh | Are unseen fields reconstructed accurately, including local hot spots? | 13 |
| AI-based full-field ROM | Input parameters or state/history mapped to latent coefficients | Parameter/coefficient pairs | Can fields be predicted without access to the target fields? | Extension to 13 |
| Physics-constrained parameter inference | An unknown physical coefficient | Sparse temperature observations and governing equation | Are data fit and unsampled physical behaviour acceptable? | 14 |
| PINN / neural PDE solver | A neural representation of the solution with equation and boundary losses | Measurements, collocation samples and physics | Do independent conditions satisfy physics and prediction requirements? | Advanced instructor extension |

Exercises 12–14 are independent native plain-text Live Scripts. Open the supplied MATLAB Project, then open the selected workshop or matching solution in the Live Editor and run sections in order. Each uses synthetic illustrative data and runs without hardware or external downloads. They teach the structure of the workflow; they are not calibrated battery models.

Exercise 12 contains an actual projected dynamical model. Its held-out input is different from the input used to build the snapshot basis. Exercise 13 demonstrates full-field encoding and reconstruction, and explicitly distinguishes these operations from an AI predictor. Exercise 14 performs physics-constrained inverse fitting and residual checks; it does not claim to train a PINN.

## Extend to the unified workflow

1. Define the system-level requirement and operating envelope first.
2. Collect representative simulation or measurement data; preserve units, mesh topology, parameters and time histories.
3. Compare model-based reduction with AI surrogates using common held-out scenarios.
4. For full fields, learn the basis on training data only, then fit a parameter-to-coefficient model and measure total field-prediction error separately from projection error.
5. For physics-informed models, encode initial/boundary conditions and residual sampling explicitly. Low training loss is not evidence of global accuracy.
6. Integrate the candidate model into Simulink, test system requirements, evaluate cost and accuracy tradeoffs, then qualify the deployment target.

The stored fraction in Exercise 13 counts only latent coefficients per field. For a fair complete archive comparison, also count the shared mean and basis. For a fair speed comparison, measure full and reduced implementations on the same target; none of these scripts claims a hardware speedup.

## App-led full-field session

Obtain the Full-Field ROM File Exchange package separately and check the package's own release/product requirements. Prepare mesh coordinates, field snapshots, parameter metadata and held-out scenarios before opening the app. The basic exercise remains usable when that optional app is unavailable. Use actual captured UI screenshots for the app-led handout once the selected package is installed; no fabricated screenshot is supplied here.

## Instructor material continuity

Preserve the instructor's original ROM/PIML material, including `AI_ROM_PINNS.pptx`, as the deeper physics-informed and neural-PDE branch. The unified ROM source decks serve different purposes:

- `SESS-101_Accelerate Engineering Design with Reduced Order Modeling in MATLAB and Simulink.pptx`: concise model-based and AI-based overview.
- `Fall MAC_Accelerating Engineering Design with Reduced Order Modeling.pptx`: deeper AI-based ROM and demo workflow material.
- `AI PFT Accelerating Engineering Design using Reduced Order Modeling.pptx`: internal reference for preparation; exclude from student publication unless its sharing status is approved.

These sources remain in the development material tree. Student delivery should include the exercises and authorized instructional assets rather than copying internal source decks indiscriminately. New-release feature claims belong in the verified refresh matrix, not inferred from a deck title.

## Full-field app decision (2026-11-16)
The owner confirmed that no public full-field ROM app should be assumed. The required training path is the verified command-line POD and predictive full-field network exercises (13 and 19). App setup is not a pending prerequisite.
