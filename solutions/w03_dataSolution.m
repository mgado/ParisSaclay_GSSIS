%[text] # 03 — Manage data and prevent leakage — Solution
%[text] **Goal:** Inspect units, split independent acquisition runs, and isolate final test data.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: MATLAB. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(3,true). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Change the train/validation/test run allocation while keeping groups disjoint. Add one outlier and decide whether to remove it or record it as an out-of-domain case.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Worked reasoning:** The supplied split contains 420 training, 60 validation and 120 test observations, with disjoint run IDs. Estimate normalization only from training data; never choose architecture using the final test metric.
project = requireTrainingProject;
%%
%[text] ## Inspect synthetic measurements
%[text] The voltage law is deliberately simple: V = 3 + 1.2 SOC - 0.05 I + 0.002(T-25) plus small sensor noise. It supports a reproducible short lesson, not a claim about real battery chemistry.
data = makeBatteryData(42,600);
head(data)
summary(data)
%%
%[text] ## Split by acquisition run
%[text] Adjacent measurements in real logs are correlated. Split entire acquisition runs before fitting normalization or training. Runs 8 are validation; runs 9 and 10 remain untouched for final evaluation.
trainRows = data.runId <= 7;
validationRows = data.runId == 8;
testRows = data.runId >= 9;
assert(~any(trainRows & testRows));
splitCounts = [nnz(trainRows),nnz(validationRows),nnz(testRows)]
%%
%[text] ## Explore voltage and label coverage
%[text] Look for coverage gaps before choosing a network. Record units and data provenance with each dataset.
scatter(data.voltage,data.soc,12,data.temperature,'filled');
xlabel('Voltage (V)'); ylabel('State of charge (fraction)');
colorbar; title('Synthetic SOC coverage; color is temperature (C)');
%%
%[text] ## Export a portable data artifact
%[text] This writes only generated teaching outputs. The original material remains untouched.
outputFolder = fullfile(project.RootFolder,'generated','data');
if ~isfolder(outputFolder), mkdir(outputFolder); end
writetable(data,fullfile(outputFolder,'batteryMeasurements.csv'));
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/matlab/data-import-and-analysis.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`table`](https://www.mathworks.com/help/matlab/ref/table.html) | table(V,I,T,SOC) | Named columns with known units |
%[text] | [`summary`](https://www.mathworks.com/help/matlab/ref/double.summary.html) | summary(data) | Inspect coverage and values |
%[text] | [`writetable`](https://www.mathworks.com/help/matlab/ref/writetable.html) | writetable(data,file) | Exchange data |
%[text] | [`logical indexing`](https://www.mathworks.com/help/matlab/math/array-indexing.html) | data(trainRows,:) | Group-aware partition |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
