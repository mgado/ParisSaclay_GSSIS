%[text] # Solution 17 — Repair sensor logs and preserve acquisition groups
%[text] **Goal:** Detect the known sensor defect, repair short gaps, resample each acquisition independently, and retain a disjoint final test run. Open the training MATLAB Project in R2026b; MATLAB only for the numerical path; 20 minutes.
%[text] **Answer:** Keep a moving-median threshold of 4 for the deliberately large spike and choose a 0.5-second grid. Interpolation increases sample count; it does not add independent information or remove the need for group-aware splits.
project = requireTrainingProject;
outlierThreshold = 4;
resamplingStep = 0.5;
openSignalLabeler = false;
%%
%[text] ## Step 1: Generate reproducible dirty acquisitions
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
rawMissingCount = nnz(ismissing(rawLogs.temperature))
assert(rawMissingCount==9,"Expected three missing samples per acquisition.");
%%
%[text] ## Step 2: Clean and retime within each acquisition
%[text] **Answer:** The inserted sample 25 must be flagged. Temperature gaps use actual irregular timestamps; the uniform grid is created only after repair. Provenance IDs remain constant because interpolation never crosses an acquisition boundary.
cleanRuns = cell(3,1);
repairCounts = zeros(3,2);
for acquisition = 1:3
    log = runLogs{acquisition};
    originalMissing = ismissing(log.temperature);
    spikeRows = isoutlier(log.temperature,"movmedian",9, ...
        ThresholdFactor=outlierThreshold);
    assert(spikeRows(25),"The injected spike was not detected.");
    log.temperature(spikeRows) = NaN;
    log.temperature = fillmissing(log.temperature,"linear", ...
        SamplePoints=seconds(log.Properties.RowTimes));
    repairCounts(acquisition,:) = [nnz(originalMissing),nnz(spikeRows)];
    targetTimes = seconds((0:resamplingStep:60)') + minutes(3*(acquisition-1));
    cleanRuns{acquisition} = retime(log,targetTimes,"linear");
    assert(all(cleanRuns{acquisition}.acquisitionId==acquisition));
    assert(all(abs(seconds(diff(cleanRuns{acquisition}.Properties.RowTimes))-resamplingStep)<1e-10));
end
cleanLogs = vertcat(cleanRuns{:});
repairReport = array2table(repairCounts, ...
    VariableNames=["OriginalMissing","DetectedOutliers"])
assert(all(isfinite(cleanLogs.temperature)));
assert(all(cleanLogs.temperature>25 & cleanLogs.temperature<46));
%%
%[text] ## Step 3: Compare raw and repaired values
plot(seconds(rawLogs.Properties.RowTimes),rawLogs.temperature,".", ...
    seconds(cleanLogs.Properties.RowTimes),cleanLogs.temperature,"-");
xlabel("Time since first acquisition (s)"); ylabel("Temperature (deg C)");
legend("Raw measurements","Cleaned and retimed"); grid on
%%
%[text] ## Step 4: Keep groups disjoint and save the result
%[text] **Answer:** Each partition now contains 121 rows, but still only one independent acquisition. A row-wise split would exaggerate generalization evidence. Never fit a scaler with validation or test measurements.
trainingRows = cleanLogs.acquisitionId == 1;
validationRows = cleanLogs.acquisitionId == 2;
testRows = cleanLogs.acquisitionId == 3;
assert(~any(trainingRows & validationRows | trainingRows & testRows | validationRows & testRows));
assert(all(trainingRows | validationRows | testRows));
splitCounts = [nnz(trainingRows),nnz(validationRows),nnz(testRows)]
assert(isequal(splitCounts,[121,121,121]));
outputFolder = fullfile(project.RootFolder,"generated","data");
if ~isfolder(outputFolder), mkdir(outputFolder); end
writetimetable(cleanLogs,fullfile(outputFolder,"cleanCoolingLogs.csv"));
%%
%[text] ## Optional: Review the repair label in Signal Labeler
%[text] **Answer:** Launch with no arguments. Select **Import > From Workspace > qualitySignals**. Inspect the repaired region covering 11 to 13 seconds, edit its boundaries if appropriate, and export the reviewed set. Model training should use these reviewed labels rather than blindly trust the injected synthetic labels.
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
%[text] ## Conclusion and troubleshooting
%[text] This repair is justified by the known slowly varying synthetic temperature law and short outages. Real thermal events must be retained, long gaps need explicit treatment, and repair provenance belongs with the data. A finer grid does not create more independent experiments.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/matlab/data-import-and-analysis.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`timetable`](https://www.mathworks.com/help/matlab/ref/timetable.html) | timetable(time,temperature,id) | Retain timestamp and provenance |
%[text] | ismissing / isoutlier | isoutlier(x,"movmedian",9) | Separate dropout and spike evidence |
%[text] | [`fillmissing`](https://www.mathworks.com/help/matlab/ref/fillmissing.html) | fillmissing(x,"linear",SamplePoints=t) | Repair short physical gaps |
%[text] | [`retime`](https://www.mathworks.com/help/matlab/ref/timetable.retime.html) | retime(log,newTimes,"linear") | Resample inside one acquisition |
%[text] | [`labeledSignalSet`](https://www.mathworks.com/help/signal/ref/labeledsignalset.html) | labeledSignalSet(x,definition,SampleRate=Fs) | Prepare reviewable labels |
%[text] | [`signalLabeler`](https://www.mathworks.com/help/signal/ref/signallabeler-app.html) | [`signalLabeler`](https://www.mathworks.com/help/signal/ref/signallabeler-app.html) | Import, review and export labels |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
