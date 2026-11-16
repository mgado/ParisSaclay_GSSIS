%[text] # 04 — Train a simple virtual sensor
%[text] **Goal:** Compare an analytic baseline with a one-call machine-learning model.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: Statistics and Machine Learning Toolbox. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(4). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Train a regression tree with a different leaf size, compare validation RMSE, then freeze the choice before evaluating test runs.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Before opening the solution:** Record your parameter change, observed result, and engineering conclusion.
project = requireTrainingProject;
%%
%[text] ## Prepare predictors and independent splits
%[text] Use physical sensor measurements as predictors and synthetic SOC as the response. Tune on run 8; keep runs 9 and 10 for one final evaluation after freezing your choice.
data = makeBatteryData;
trainRows = data.runId <= 7;
validationRows = data.runId == 8;
testRows = data.runId >= 9;
x = [data.voltage,data.current,data.temperature];
%%
%[text] ## Fit a transparent ML model
%[text] Try MinLeafSize 3, 8 and 20 using validation error. The starter leaves final evaluation off; enable it once after freezing the choice. The solution evaluates its prescribed leaf size, rather than choosing it on test error.
minimumLeafSize = 8;
model = fitrtree(x(trainRows,:),data.soc(trainRows),MinLeafSize=minimumLeafSize);
validationPrediction = predict(model,x(validationRows,:));
analytic = socEstimate(data.voltage(validationRows),data.current(validationRows),data.temperature(validationRows));
validationRMSE = [sqrt(mean((validationPrediction-data.soc(validationRows)).^2)),sqrt(mean((analytic-data.soc(validationRows)).^2))]
evaluateFinalTest = false;
if evaluateFinalTest
    learned = predict(model,x(testRows,:));
    finalTestRMSE = sqrt(mean((learned-data.soc(testRows)).^2))
end
%%
%[text] ## Inspect errors
%[text] Use validation plots to tune; a short synthetic run does not establish generalization to real cells, temperatures or aging conditions.
plot(data.soc(validationRows),validationPrediction,'.');
xlabel('Validation reference SOC'); ylabel('Predicted SOC'); grid on;
title('Validation virtual-sensor prediction');
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/stats/regression-and-anova.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`fitrtree`](https://www.mathworks.com/help/stats/fitrtree.html) | fitrtree(X,Y,MinLeafSize=8) | Train simple regression baseline |
%[text] | [`predict`](https://www.mathworks.com/help/stats/regressiontree.predict.html) | predict(model,XTest) | Evaluate held-out data |
%[text] | [`socEstimate`](../src/socEstimate.m) | socEstimate(V,I,T) | Compare physical baseline |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
