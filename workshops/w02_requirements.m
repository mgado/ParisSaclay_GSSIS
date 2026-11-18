%[text] # 02 — Define measurable AI requirements
%[text] **Goal:** Turn vague accuracy and safety goals into traceable requirements.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: Requirements Toolbox. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(2). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Replace a vague goal with a threshold, operating domain, unit and verification method. Add SOC-003 for voltage input validity; link it to the implementation.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Before opening the solution:** Record your parameter change, observed result, and engineering conclusion.
project = requireTrainingProject;
%%
%[text] ## Create or reopen the requirement set
%[text] For teaching, SOC error is measured on held-out acquisition runs. RMSE at most 0.03 means three percentage points of SOC, not three percent relative error.
requirementFolder = fullfile(project.RootFolder,'generated','requirements');
if ~isfolder(requirementFolder), mkdir(requirementFolder); end
requirementFile = fullfile(requirementFolder,'BatteryRequirements.slreqx');
if isfile(requirementFile)
    requirementSet = slreq.load(requirementFile);
else
    requirementSet = slreq.new(requirementFile);
    accuracyRequirement = add(requirementSet,'Id','SOC-001', ...
        'Summary','Held-out SOC RMSE at most 0.03', ...
        'Description','Evaluate independent runs 9 and 10 over SOC 0.05 to 0.95.');
    rangeRequirement = add(requirementSet,'Id','SOC-002', ...
        'Summary','Bounded analytic SOC baseline', ...
        'Description','For finite voltage/current/temperature inputs, output is between 0 and 1.');
    implementationLink = slreq.createLink(fullfile(project.RootFolder,'src','socEstimate.m'),rangeRequirement);
    implementationLink.Type = 'Implement';
    save(requirementSet);
    save(linkSet(implementationLink));
end
disp(requirementSet)
%%
%[text] ## Inspect in Requirements Editor
%[text] Set openEditor true during the taught UI activity. Select SOC-001, inspect its description and links, then add a requirement through the interface. The screenshot pack illustrates the actual editor captured on the validation machine.
openEditor = false;
if openEditor, slreq.editor; end
%%
%[text] ## Verify the accuracy requirement
%[text] A requirement is not verified merely by a green model. Execute the metric and retain evidence. Exercise 10 links the Simulink test artifact; MATLAB unit tests assert the accuracy threshold.
[~,metrics] = trainSOCNetwork;
accuracyEvidence = metrics.rmse
assert(accuracyEvidence <= 0.03);
%%
%[text] ## UI screenshot guide
%[text] The images illustrate the interface and links. Values shown are examples; use your generated artifacts to assess this exercise.
%%
%[text] ## Requirements Editor: measurable requirement and verification links
%[text] Example interface view. Menu names and displayed values can differ from your session.
image(imread(fullfile(project.RootFolder,'assets','screenshots','requirements_editor.png')));
axis image off;
%%
%[text] ## Follow a verification link into Test Manager
%[text] Example interface view. Menu names and displayed values can differ from your session.
image(imread(fullfile(project.RootFolder,'assets','screenshots','requirements_test_link.png')));
axis image off;
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require a configured compatible target. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/slrequirements/). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text] Project setup uses [requireTrainingProject](../src/requireTrainingProject.m), a training helper using MATLAB Project APIs.
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [`slreq.new`](https://www.mathworks.com/help/slrequirements/ref/slreq.new.html) | slreq.new(file) | Create requirement set | Requirements Toolbox |
%[text] | [`add`](https://www.mathworks.com/help/slrequirements/ref/slreq.reqset.add.html) | add(reqSet,'Id','SOC-001',...) | Author measurable requirement | Requirements Toolbox |
%[text] | [`slreq.createLink`](https://www.mathworks.com/help/slrequirements/ref/slreq.createlink.html) | slreq.createLink(source,requirement) | Trace implementation or verification | Requirements Toolbox |
%[text] | [`slreq.editor`](https://www.mathworks.com/help/slrequirements/ref/slreq.editor.html) | [`slreq.editor`](https://www.mathworks.com/help/slrequirements/ref/slreq.editor.html) | Review requirements in UI | Requirements Toolbox |
%[text] | [`socEstimate`](../src/socEstimate.m) | `socEstimate(V,I,T)` | Evaluate the provided analytic SOC baseline | Training helper (MATLAB) |
%[text] | [`trainSOCNetwork`](../src/trainSOCNetwork.m) | `[net,metrics] = trainSOCNetwork` | Train the provided compact SOC reference | Training helper (Deep Learning Toolbox) |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
