# Choose and test a reduced-order model

The thermal examples ask one engineering question: can a smaller model preserve
the temperatures, dynamics and operating limits required by the system?
Open the Project, select the relevant Live Script, and run sections in order.

| Method | What it does | Acceptance question | Lesson |
| --- | --- | --- | --- |
| Model-based projection | Reduce known state equations using a trajectory basis | Does it reproduce a new input? | `w12_modelBasedROM` |
| Full-field compression | Encode spatial temperature fields with a few coefficients | Is the unseen field reconstructed accurately? | `w13_fullFieldROM` |
| Physics-constrained inference | Fit a physical coefficient from observations | Are fit and unsampled physics acceptable? | `w14_physicsInformed` |
| PINN | Train a neural solution using equation/initial-condition losses | Do unseen points satisfy physics and prediction requirements? | `w18_pinnCooling` |
| Predictive full-field AI | Map parameters to latent coefficients and decode a field | Can it predict without seeing the target field? | `w19_predictiveFieldROM` |

The examples use small synthetic data/models to expose the APIs. MATLAB is
sufficient for the projection/inverse-fitting lessons; the neural lessons also
require Deep Learning Toolbox. No public full-field ROM app is required.

## A shared workflow

1. Define the desired output and operating envelope: scalar KPI, dynamic signal
   or spatial field.
2. Keep units, time histories, mesh coordinates and parameter metadata consistent.
3. Split representative scenarios before fitting the basis or predictor.
4. Fit only with training data; use validation data to select complexity.
5. Freeze the choice and evaluate held-out cases with the system's metric.
6. Integrate the reduced model and recheck requirements after implementation changes.

For thermal models, distinguish temperature in Celsius from normalized neural
outputs. A physics residual has units derived from the governing equation;
changing time units changes the required coefficient and residual scale.

## Full fields: reconstruction versus prediction

Exercise 13 projects a known held-out field into a POD basis and reconstructs it.
Exercise 19 predicts coefficients from input parameters, without access to the
held-out field, then decodes with the fixed training basis. Compare their errors
separately: an excellent encoder/decoder does not guarantee a good predictor.

The per-field coefficient ratio excludes the shared mean and basis. Include
those shared arrays when comparing total storage. Measure actual full/reduced
implementations on the same target before claiming a speedup.

## Physics-informed learning

Exercise 14 fits an analytic cooling law; it is not a trained PINN. Exercise 18
trains a neural solution from the ODE residual and initial condition, using the
analytic solution only for held-out assessment. Low training loss alone does
not establish accuracy across a new operating domain.

## Expected observations and troubleshooting

- Increasing POD rank should reduce missing spatial/dynamic content until the
  relevant modes are retained; check held-out error rather than energy alone.
- A rank-three field family should reconstruct near floating-point precision
  when all three training modes are kept.
- Predictive field error also includes coefficient-prediction error.
- For cooling, inspect initial-condition error, the equation residual and the
  unseen trajectory. Use an adequate time step for numerical derivatives.
- If a changed dataset violates an assertion, inspect units, data split, rank,
  model capacity and the criterion before relaxing the requirement.

## Official references

- [svd](https://www.mathworks.com/help/matlab/ref/svd.html)
- [ode45](https://www.mathworks.com/help/matlab/ref/ode45.html)
- [fminsearch](https://www.mathworks.com/help/matlab/ref/fminsearch.html)
- [trainnet](https://www.mathworks.com/help/deeplearning/ref/trainnet.html)
- [dlgradient](https://www.mathworks.com/help/deeplearning/ref/dlarray.dlgradient.html)
- [Reduced-order modelling](https://www.mathworks.com/discovery/reduced-order-modeling.html)
