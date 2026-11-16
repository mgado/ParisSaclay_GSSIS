# UI screenshot provenance

These instructor-provided screenshots are extracted from the original 2025
training decks. They illustrate the legacy interface; they are **not** newly
captured R2026b validation evidence. The exact screenshot product release is
not established by the pixels. Current menu names may differ.

- `requirements_editor_legacy.png`: Day 1 original training deck, slide 64.
- `requirements_test_link_legacy.png`: Day 1 original training deck, slide 64.
- `simulink_test_equivalence_legacy.png`: Day 3 original training deck, slide 79.
- `simulink_model_legacy.png`: Day 3 original training deck, slide 80.
- `pil_workflow_legacy.png`: Day 3 original training deck, slide 82.

## Official documentation app screenshots (retrieved 2026-11-16)

These images are screenshots supplied by MathWorks in the current public app-reference documentation. They illustrate the application interface. **They are documentation screenshots, not fresh local execution evidence and not proof that the workshop data/model was run in these apps.** The source URLs are current unversioned documentation pages; the source image itself does not establish the local MATLAB release.

| Local image | Official reference page | Exact image URL | Verified format/dimensions | Visible UI |
|---|---|---|---|---|
| `timeseries_modeler_official.png` | https://www.mathworks.com/help/deeplearning/ref/timeseriesmodeler-app.html | https://www.mathworks.com/help/deeplearning/ref/timeseriesapp_full_app.png | PNG, 1222 × 786, 39,645 bytes | Time Series Modeler; model comparison, validation RMSE, response/prediction and predictor traces |
| `visual_anomaly_detector_official.png` | https://www.mathworks.com/help/visual-inspection/ref/visualanomalydetector-app.html | https://www.mathworks.com/help/visual-inspection/ref/visualanomalydetector_window.png | PNG, 1533 × 818, 33,272 bytes | Visual Anomaly Detector; FastFlow/PatchCore/StudentTeacher models, threshold histogram and ROC curve |

Source attribution: MathWorks official documentation. Image responses reported `image/png`; both files passed PNG integrity checks and visual inspection. Metrics shown belong to the documentation examples and must not be reported as workshop measurements.

## Current model diagram
- soc_model_r2026b.png: rendered from the actually exported BatterySOCEstimator model with MATLAB/Simulink R2026b print. It shows the current generated layer-block model, not a hardware deployment.

- soc_pil_model_r2026b.png: diagram rendered from the actual reused/corrected SoC_Target model after the resumed32-bit Pi PIL experiments. It illustrates the model; the numerical evidence is recorded separately in validation docs.
