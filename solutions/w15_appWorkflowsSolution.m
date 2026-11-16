%[text] # 15 — Use modern AI apps without hiding the workflow — Solution
%[text] **Goal:** Connect modern apps to the same data/training/calibration/test workflow.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: Tool-specific products; desktop UI. Estimated time: 20 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(15,true). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable capability check plus app walkthrough. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Choose one app, load its input data, identify training/calibration/test partitions and export the result or MATLAB code. Explain where its output fits the battery digital-twin story.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Worked reasoning:** Apps accelerate interaction, but the engineered artifact still needs data provenance, an independent test and system integration. An app screenshot is walkthrough evidence, not a training-performance result.
project = requireTrainingProject;
%%
%[text] ## Inventory actual app availability
%[text] App names and releases matter. The refresh guide separates R2026a Time Series Modeler from R2026b additions and the new Visual Anomaly Detector. No public full-field ROM app is assumed for this training; use the command-line POD and predictive-field exercises.
appNames = {'timeSeriesModeler';'visualAnomalyDetector';'deepNetworkDesigner';'signalLabeler'};
available = cellfun(@(name) ~isempty(which(name)),appNames);
appCapabilities = table(appNames,available)
time = (0:299)';
current = 0.8 + 0.6*sin(time/30);
soc = 0.85-cumsum(current)/7200;
temperature = 25 + 2*sin(time/80);
voltage = 3 + 1.2*soc - 0.05*current + 0.002*(temperature-25);
sensorSequence = timetable(seconds(time),voltage,current,temperature,soc);
head(sensorSequence)
inspection = makeInspectionImages;
countEachLabel(inspection.Train)
countEachLabel(inspection.Calibration)
openSelectedApp = false;
if openSelectedApp && available(1), timeSeriesModeler; end
openVisualApp = false;
if openVisualApp && available(2)
    visualAnomalyDetector(inspection.Train,inspection.Calibration,inspection.Test,"defect");
end
%%
%[text] ## Perform one visible app workflow
%[text] The supplied sensorSequence is a synthetic coulomb-counting/voltage trajectory. In Time Series Modeler, import it from the Live Editor workspace, select SOC as response and voltage/current/temperature as predictors, split independent acquisitions and export the trained result. Visual Anomaly Detector receives separate synthetic cover-image train/calibration/test sets; select a supported detector, calibrate its threshold and inspect held-out ROC/heatmaps. The images contain illustrative marks, not real battery defects. Model training/backbone packages may require additional resources.
disp("App activity: import data, split groups, fit, assess, export, and compare exported code with the command-line lesson.");
%%
%[text] ## Record evidence and recovery
%[text] The screenshot pack contains actual captured UI views when available. Exercises 13 and 19 teach full-field reconstruction and prediction with direct MATLAB commands; no public full-field app is required.
disp("Keep app version, input dataset, exported artifact and measured result with your exercise notes.");
%%
%[text] ## UI screenshot guide
%[text] The following app screenshots come from official MathWorks documentation; their exact URLs and attribution are in assets/screenshots/PROVENANCE.md. They illustrate the interface, not a local run on the workshop dataset. Metrics shown belong to the documentation examples.
%%
%[text] ## Time Series Modeler: official documentation interface
%[text] Static screenshot displayed inline for this teaching document; consult the provenance note above.
image(imread(fullfile(project.RootFolder,'assets','screenshots','timeseries_modeler_official.png')));
axis image off;
%%
%[text] ## Visual Anomaly Detector: official documentation interface
%[text] Static screenshot displayed inline for this teaching document; consult the provenance note above.
image(imread(fullfile(project.RootFolder,'assets','screenshots','visual_anomaly_detector_official.png')));
axis image off;
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/visual-inspection/). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`timeSeriesModeler`](https://www.mathworks.com/help/deeplearning/ref/timeseriesmodeler-app.html) | [`timeSeriesModeler`](https://www.mathworks.com/help/deeplearning/ref/timeseriesmodeler-app.html) | Model sensor sequences |
%[text] | [`visualAnomalyDetector`](https://www.mathworks.com/help/visual-inspection/ref/visualanomalydetector-app.html) | [`visualAnomalyDetector`](https://www.mathworks.com/help/visual-inspection/ref/visualanomalydetector-app.html) | Train/calibrate/test visual anomaly detection |
%[text] | [`signalLabeler`](https://www.mathworks.com/help/signal/ref/signallabeler-app.html) | [`signalLabeler`](https://www.mathworks.com/help/signal/ref/signallabeler-app.html) | Label sensor signals |
%[text] | [`which`](https://www.mathworks.com/help/matlab/ref/which.html) | which(appName) | Check app availability |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
