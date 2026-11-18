%[text] # 16 — Engineer with builtin and custom skills — Solution
%[text] **Goal:** Use an agent to make and verify one small engineering improvement.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: MATLAB; connected agent; official toolkits. Estimated time: 25 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(16,true). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable baseline plus agent exercise. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Ask the agent to add an input-domain test for the analytic sensor, preserve units and original files, execute the focused test, and produce a measured result. Then repeat using a custom teaching skill.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Worked reasoning:** A useful agent result links the requirement, code diff and actual test output. A custom skill improves repeatable teaching behavior; it does not supply missing board access, credentials or proof of execution.
project = requireTrainingProject;
%%
%[text] ## Establish known behavior
%[text] The analytic baseline clips output but does not validate sensor plausibility. Decide the requirement first: reject invalid input, flag it, or estimate with a degraded-mode policy.
nominal = socEstimate(3.55,1,25)
upperLimit = socEstimate(5,0,25)
assert(abs(nominal-0.5)<1e-12 && upperLimit==1);
%%
%[text] ## Use the appropriate builtin skill
%[text] Request the official MATLAB testing skill for unit tests, requirement-draft skill for traceability, and embedded-AI deployment skill for a target plan. Insist on tools and evidence for execution claims. The agent should propose meaningful boundaries and preserve the test suite.
request = "Using the MATLAB testing skill, add a temperature-domain test in an isolated copy, run it, and report the requirement, input units and observed result."
disp(request)
%%
%[text] ## Create a custom skill in your own workspace
%[text] AGENTIC_GUIDE.md provides a copyable skill body. Students create it in their personal agent workspace, not in the clean distribution. It asks for English learner instructions, French teaching prompts, visible APIs, and actual checks.
disp("Compare the generic answer with the custom skill: did it explain units, expected observation, and real verification evidence?");
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require a configured compatible target. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://github.com/matlab/simulink-agentic-toolkit). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text] Project setup uses [requireTrainingProject](../src/requireTrainingProject.m), a training helper using MATLAB Project APIs.
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [`runtests`](https://www.mathworks.com/help/matlab/ref/runtests.html) | runtests(testFile) | Execute proposed changes | MATLAB |
%[text] | [`assertSuccess`](https://www.mathworks.com/help/matlab/ref/matlab.unittest.testresult.assertsuccess.html) | assertSuccess(results) | Require measured test success | MATLAB |
%[text] | [`checkcode`](https://www.mathworks.com/help/matlab/ref/checkcode.html) | checkcode(source) | Inspect code issues | MATLAB |
%[text] | [`socEstimate`](../src/socEstimate.m) | socEstimate(V,I,T) | Small engineering target | Training helper (MATLAB) |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
