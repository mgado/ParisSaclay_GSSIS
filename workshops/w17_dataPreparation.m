%[text] # 17 — Repair sensor logs without leaking acquisition runs
%[text] **Goal:** Turn dirty, irregular cooling logs into finite, uniformly sampled data while preserving independent acquisition groups.
%[text] **Prerequisites:** Open the training MATLAB Project in R2026b. Numerical lesson: MATLAB. Optional Signal Labeler: Signal Processing Toolbox and MATLAB desktop. Estimated time: 20 minutes.
%[text] **Launch:** Open this file in the Live Editor and run sections in order. Every input is generated here; this exercise does not depend on running an earlier lesson.
%[text] **Your task:** Change the outlier threshold or the resampling step. Count repaired samples, explain the physical repair assumption, and keep acquisition 3 untouched by training.
%[text] **Hint 1:** A short dropout in slowly varying temperature can be linearly interpolated. A long outage or a real thermal event must not be silently repaired.
%[text] **Hint 2:** Clean and retime each acquisition separately. Interpolation across two independent runs fabricates data between experiments.
project = requireTrainingProject;
outlierThreshold = 4;
resamplingStep = 1;
openSignalLabeler = false;
%%
%[text] ## Step 1: Make three dirty acquisitions
%[text] The underlying cooling trend is synthetic. Each acquisition contains timestamp jitter, three missing samples and one deliberately inserted sensor spike. Acquisition IDs are provenance, not predictor values.
rng(17,"twister");
runLogs = cell(3,1);
for acquisition = 1:3
    sampleSeconds = (0:60)' + 0.08*sin((0:60)'/3);
    sampleSeconds([1,end]) = [0;60];
    time = seconds(sampleSeconds) + minutes(3*(acquisition-1));
    temperature = 25 + 20*exp(-0.04*sampleSeconds) + 0.02*randn(61,1);
    temperature(12:14) = NaN;
    temperature(25) = temperature(25) + 20;
    acquisitionId = repmat(acquisition,61,1);
    runLogs{acquisition} = timetable(time,temperature,acquisitionId);
end
rawLogs = vertcat(runLogs{:});
head(rawLogs)
rawMissingCount = nnz(ismissing(rawLogs.temperature))
%%
%[text] ## Step 2: Detect spikes and repair short gaps
%[text] `isoutlier` uses a moving median, so the smooth cooling trend is retained while the injected spike is flagged. The repair log distinguishes original missing samples from values removed as outliers. No test-acquisition information is used to fit a normalization or a model.
cleanRuns = cell(3,1);
repairCounts = zeros(3,2);
for acquisition = 1:3
    log = runLogs{acquisition};
    originalMissing = ismissing(log.temperature);
    spikeRows = isoutlier(log.temperature,"movmedian",9, ...
        ThresholdFactor=outlierThreshold);
    log.temperature(spikeRows) = NaN;
    log.temperature = fillmissing(log.temperature,"linear", ...
        SamplePoints=seconds(log.Properties.RowTimes));
    repairCounts(acquisition,:) = [nnz(originalMissing),nnz(spikeRows)];
    targetTimes = seconds((0:resamplingStep:60)') + minutes(3*(acquisition-1));
    cleanRuns{acquisition} = retime(log,targetTimes,"linear");
end
cleanLogs = vertcat(cleanRuns{:});
repairReport = array2table(repairCounts, ...
    VariableNames=["OriginalMissing","DetectedOutliers"])
assert(all(isfinite(cleanLogs.temperature)),"Cleaning left nonfinite values.");
%%
%[text] ## Step 3: Inspect the repair
%[text] Look for the removed spike and the repaired dropout. Confirm that temperature stays within the physical teaching envelope; an automated outlier flag is a review suggestion, not a reason to erase real anomalies.
plot(seconds(rawLogs.Properties.RowTimes),rawLogs.temperature,".", ...
    seconds(cleanLogs.Properties.RowTimes),cleanLogs.temperature,"-");
xlabel("Time since first acquisition (s)"); ylabel("Temperature (deg C)");
legend("Raw measurements","Cleaned and retimed"); grid on
%%
%[text] ## Step 4: Split by acquisition
%[text] Acquisition 1 is training, 2 is validation, and 3 is final test. Randomly shuffling individual rows would mix strongly correlated measurements from one experiment across partitions.
trainingRows = cleanLogs.acquisitionId == 1;
validationRows = cleanLogs.acquisitionId == 2;
testRows = cleanLogs.acquisitionId == 3;
assert(~any(trainingRows & validationRows | trainingRows & testRows | validationRows & testRows));
splitCounts = [nnz(trainingRows),nnz(validationRows),nnz(testRows)]
outputFolder = fullfile(project.RootFolder,"generated","data");
if ~isfolder(outputFolder), mkdir(outputFolder); end
writetimetable(cleanLogs,fullfile(outputFolder,"cleanCoolingLogs.csv"));
%%
%[text] ## Optional: Review repaired regions in Signal Labeler
%[text] Set `openSignalLabeler` to true to create `qualitySignals` and launch the real app. In Signal Labeler choose **Import > From Workspace**, select `qualitySignals`, inspect the SensorQuality ROI, then adjust its start/end in the label table. Export the reviewed labeled signal set back to the workspace. The app launch is deliberately zero-argument; importing data is a visible student action.
if openSignalLabeler
    assert(exist("signalLabeler","file")~=0,"Signal Processing Toolbox is required.");
    qualityDefinition = signalLabelDefinition("SensorQuality", ...
        LabelType="roi",LabelDataType="categorical",Categories=["repaired","normal"]);
    qualitySignals = labeledSignalSet(cleanRuns{1}.temperature, ...
        qualityDefinition,SampleRate=1/resamplingStep);
    setLabelValue(qualitySignals,1,"SensorQuality",[11,13], ...
        categorical("repaired",["repaired","normal"]));
    signalLabeler
end
%%
%[text] ## Troubleshooting and engineering conclusion
%[text] If genuine events are flagged as spikes, change the window/threshold and document the choice. Do not interpolate long outages without a physical assumption. Keep repaired-value flags alongside production data, and fit learned preprocessing only on the training acquisitions.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/matlab/data-import-and-analysis.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text] Project setup uses [requireTrainingProject](../src/requireTrainingProject.m), a training helper using MATLAB Project APIs.
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [`timetable`](https://www.mathworks.com/help/matlab/ref/timetable.html) | timetable(time,temperature,id) | Measurements tied to timestamps | MATLAB |
%[text] | [`isoutlier`](https://www.mathworks.com/help/matlab/ref/isoutlier.html) | isoutlier(x,"movmedian",9) | Flag local spikes for review | MATLAB |
%[text] | [`fillmissing`](https://www.mathworks.com/help/matlab/ref/fillmissing.html) | fillmissing(x,"linear",SamplePoints=t) | Repair short gaps with an explicit assumption | MATLAB |
%[text] | [`retime`](https://www.mathworks.com/help/matlab/ref/timetable.retime.html) | retime(log,newTimes,"linear") | Put one acquisition on a uniform grid | MATLAB |
%[text] | [`writetimetable`](https://www.mathworks.com/help/matlab/ref/writetimetable.html) | writetimetable(log,file) | Portable cleaned log | MATLAB |
%[text] | [`signalLabeler`](https://www.mathworks.com/help/signal/ref/signallabeler-app.html) | [`signalLabeler`](https://www.mathworks.com/help/signal/ref/signallabeler-app.html) | Review labels in a real app | Signal Processing Toolbox |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
