%[text] # 10 — Link requirements, tests and model evidence — Solution
%[text] **Goal:** Create a persistent test case and trace its purpose to the requirement set.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: Simulink Test; Requirements Toolbox; Simulink; Simulink Check for project result tracking. Estimated time: 35 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(10,true). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable plus Test Manager walkthrough. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Create a model test linked to SOC-001, add a custom error threshold, run it, and inspect verification status in Requirements Editor. Compare MIL, SIL, PIL and HIL evidence categories.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Worked reasoning:** A test linked to SOC-001 must calculate held-out RMSE to verify that requirement; a zero-input smoke simulation cannot. Select the right test level and retain actual results. Target hardware is needed for PIL and HIL.
project = requireTrainingProject;
%%
%[text] ## Create a persistent model test
%[text] A linked test artifact establishes traceability. It becomes verification evidence only after it runs with meaningful criteria and the result is assessed.
modelFile = ensureSOCModel;
modelFolder = fileparts(modelFile);
addPath(project,modelFolder);
addFile(project,modelFile);
open_system(modelFile);
testFolder = fullfile(project.RootFolder,'generated','tests');
if ~isfolder(testFolder), mkdir(testFolder); end
addPath(project,testFolder);
testFilePath = fullfile(testFolder,'BatterySystemTests.mldatx');
testFile = sltest.testmanager.TestFile(testFilePath);
existingCases = getAllTestCases(testFile);
defaultCase = existingCases(strcmp({existingCases.Name},'New Test Case 1'));
if ~isempty(defaultCase), remove(defaultCase); end
testSuite = getTestSuiteByName(testFile,'Battery estimator');
if isempty(testSuite), testSuite = createTestSuite(testFile,'Battery estimator'); end
testCases = getTestCases(testSuite);
if isempty(testCases)
    testCase = createTestCase(testSuite,'simulation','SOC estimator MIL');
else
    testCase = testCases(1);
end
setProperty(testCase,'Model','BatterySOCEstimator','OverrideStopTime',true,'StopTime',19,'OverrideModelOutputSettings',true,'SaveOutput',true);
saveToFile(testFile);
%%
%[text] ## Link verification intent
%[text] The next section creates a held-out sensor trace, maps it to the model, executes an RMSE criterion and updates verification status. Exercise 2 adds richer requirements; a minimal SOC-001 set is created here when needed for independent replay.
requirementFolder = fullfile(project.RootFolder,'generated','requirements');
if ~isfolder(requirementFolder), mkdir(requirementFolder); end
addPath(project,requirementFolder);
requirementFile = fullfile(requirementFolder,'BatteryRequirements.slreqx');
if ~isfile(requirementFile)
    requirementFolder = fileparts(requirementFile);
    if ~isfolder(requirementFolder), mkdir(requirementFolder); end
    requirementSet = slreq.new(requirementFile);
    add(requirementSet,'Id','SOC-001','Summary','Held-out SOC RMSE at most 0.03');
    save(requirementSet);
end
if isfile(requirementFile)
    requirementSet = slreq.load(requirementFile);
    requirements = find(requirementSet,'Type','Requirement','Id','SOC-001');
    if isempty(testCase.Requirements)
        verificationLink = slreq.createLink(testCase,requirements(1));
        verificationLink.Type = 'Verify';
        save(linkSet(verificationLink));
        modelLink = slreq.createLink(get_param('BatterySOCEstimator','Handle'),requirements(1));
        modelLink.Type = 'Implement';
        save(linkSet(modelLink));
    end
end
data = makeBatteryData(42,600);
heldOut = data(data.runId>=9,:);
heldOut = heldOut(1:20,:);
time = (0:19)';
sensorInputs = Simulink.SimulationData.Dataset;
sensorInputs = sensorInputs.addElement(timeseries([heldOut.voltage,heldOut.current,heldOut.temperature],time),'input');
inputFile = fullfile(testFolder,'heldOutSensorTrace.mat');
save(inputFile,'sensorInputs');
testInputs = getInputs(testCase);
ownedInputs = testInputs(strcmp({testInputs.FilePath},inputFile));
for inputIndex = 1:numel(ownedInputs), remove(ownedInputs(inputIndex)); end
testInput = addInput(testCase,inputFile,1,false);
map(testInput,'Mode',3);
assert(contains(testInput.MappingStatus,'Successfully mapped'),'Input mapping must succeed before the test runs.');
testInput.Active = true;
criteria = getCustomCriteria(testCase);
expectedText = mat2str(heldOut.soc,17);
criteria.Callback = sprintf("values = test.sltest_simout.get('yout').getElement(1).Values; observed = double(squeeze(values.Data)); expected = %s; test.assertEqual(numel(observed),numel(expected)); test.assertEqual(values.Time(:),(0:19)','AbsTol',1e-9); test.assertTrue(all(isfinite(observed))); test.verifyLessThanOrEqual(sqrt(mean((observed-expected).^2)),0.03);",expectedText);
criteria.Enabled = true;
% Native result tracking must start before producing test results.
verificationTag = "ParisSaclaySOC_" + string(getProperty(testCase,'UUID'));
testCase.Tags = unique([string(testCase.Tags),verificationTag]);
saveToFile(testFile);
addFile(project,testFilePath);
addFile(project,requirementFile);
trackingSettings = digitalthread.settings();
trackingSettings.ToolOutputTracking = true;
metricEngine = metric.Engine();
updateArtifacts(metricEngine);
results = sltest.testmanager.run(Tags=verificationTag);
assert(results.NumPassed>=1 && results.NumFailed==0 && results.NumIncomplete==0);
resultFile = fullfile(testFolder,'BatteryVerificationResults.mldatx');
sltest.testmanager.exportResults(results,resultFile);
updateArtifacts(metricEngine);
updateVerificationStatus(requirementSet);
accuracyRequirement = find(requirementSet,'Type','Requirement','Id','SOC-001');
nativeStatus = getVerificationStatus(accuracyRequirement(1),'self')
assert(nativeStatus.passed==1 && nativeStatus.failed==0 && nativeStatus.unexecuted==0);
verificationStatus = getVerificationStatus(requirementSet)
verificationEvidence = struct('RequirementId','SOC-001','ExecutedTestOutcome',char(string(results.Outcome)), ...
    'NativeRequirementStatus',nativeStatus,'ToolboxSummary',verificationStatus);
evidenceFile = fullfile(testFolder,'requirementVerificationEvidence.json');
writelines(string(jsonencode(verificationEvidence,PrettyPrint=true)),evidenceFile);
%%
%[text] The native requirement now reflects the tracked executed test. SOC-002 has no verification link yet and remains none, not unexecuted. To demonstrate failure, temporarily tighten the custom test error limit, save/run/export/refresh, inspect native failed, then restore 0.03 and rerun before finishing.
%[text] ## Run meaningful MATLAB requirement checks
%[text] The included unit suite checks nominal SOC, bounds, temperature units, reproducibility, and a held-out neural accuracy threshold. This is actual host evidence separate from an unassessed Simulink test smoke run.
results = runtests(fullfile(project.RootFolder,'tests','TestBatteryWorkflow.m'));
assertSuccess(results);
%%
%[text] ## Explain test levels
%[text] MIL uses simulated models; SIL executes generated target code on the host; PIL executes code on the target processor; HIL closes the loop with real-time plant simulation and hardware I/O. None can be claimed from merely selecting a dropdown.
levels = ["MIL: simulated model";"SIL: generated code on host";"PIL: target processor execution";"HIL: real-time plant and hardware I/O"]
disp(levels)
%%
%[text] ## UI screenshot guide
%[text] Screenshots below are from the instructor's original 2025 materials. They explain the interface and links; they are not current R2026b execution results. Use the exercise's own generated artifacts for current evidence.
%%
%[text] ## Test Manager: original MIL/SIL equivalence comparison
%[text] Static screenshot displayed inline for this teaching document; consult the provenance note above.
image(imread(fullfile(project.RootFolder,'assets','screenshots','simulink_test_equivalence_legacy.png')));
axis image off;
%%
%[text] ## Original PIL workflow and board view
%[text] Static screenshot displayed inline for this teaching document; consult the provenance note above.
image(imread(fullfile(project.RootFolder,'assets','screenshots','pil_workflow_legacy.png')));
axis image off;
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/sltest/). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [digitalthread.settings](https://www.mathworks.com/help/slcheck/ref/digitalthread.settings.html) | ToolOutputTracking=true | Enable native tool-result tracking before the run |
%[text] | [updateArtifacts](https://www.mathworks.com/help/slcheck/ref/metric.engine.updateartifacts.html) | updateArtifacts(engine) | Analyze current project inputs/results |
%[text] | [exportResults](https://www.mathworks.com/help/sltest/ref/sltest.testmanager.exportresults.html) | exportResults(results,file) | Persist actual tracked Test Manager results |
%[text] | [`TestFile`](https://www.mathworks.com/help/sltest/ref/sltest.testmanager.testfile-class.html) | sltest.testmanager.TestFile(file) | Persistent test artifact |
%[text] | [`createTestCase`](https://www.mathworks.com/help/sltest/ref/sltest.testmanager.testsuite.createtestcase.html) | createTestCase(suite,'simulation',name) | Model test case |
%[text] | [`slreq.createLink`](https://www.mathworks.com/help/slrequirements/ref/slreq.createlink.html) | slreq.createLink(testCase,requirement) | Verification trace |
%[text] | [`assertSuccess`](https://www.mathworks.com/help/matlab/ref/matlab.unittest.testresult.assertsuccess.html) | assertSuccess(results) | Fail on actual unsuccessful tests |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
