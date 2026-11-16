%[text] # 01 — Agentic engineering: setup and evidence
%[text] **Goal:** Check capabilities, learn tool versus skill versus agent, and require execution evidence.
%[text] **Prerequisites:** Open ParisSaclay\_GSSIS.prj in MATLAB R2026b. Products: MATLAB; official MATLAB and Simulink agentic toolkits. Estimated time: 20 minutes.
%[text] **Launch:** Use demoAgenda, then openExercise(1). Run one section at a time in the Live Editor.
%[text] **Workshop mode:** runnable plus agent walkthrough. Numerical sections run on the host; optional desktop, Python and hardware sections require separate prerequisites.
%[text] **Your task:** Ask your connected agent to inspect this project and explain socEstimate; ask it to run one boundary test and report the actual result. Compare a vague prompt with the supplied engineering prompt.
%[text] **Hint 1:** Keep the supplied working defaults for a first run. Change one named parameter, predict the effect, then compare the observation.
%[text] **Hint 2:** Read the API cheat sheet below. Explain why the observed result satisfies—or violates—the stated requirement.
%[text] **Before opening the solution:** Record your parameter change, observed result, and engineering conclusion.
project = requireTrainingProject;
%%
%[text] ## Inspect the MATLAB side
%[text] This checks the MATLAB products and project. It does not establish that an agent can call MATLAB; only an actual tool round trip does that.
status = setup_check;
release = version('-release')
projectFiles = numel(project.Files)
%%
%[text] ## Perform a tool round trip
%[text] In your agent, request: Use the MATLAB toolkit to evaluate socEstimate(3.55,1,25). Return the tool output, expected value 0.5, and whether it matches. If no tool is available, use the official installer instructions in AGENTIC_GUIDE.md.
expected = 0.5;
observed = socEstimate(3.55,1,25)
assert(abs(observed-expected) < 1e-12);
%%
%[text] ## Skills change engineering behavior
%[text] A skill supplies reusable instructions; tools execute actions. Read the existing toolkit's testing, requirements and embedded-AI skills. A skill's existence is not evidence that code executed.
prompt = "Inspect inputs, explain units, propose a boundary test, execute it, and attach the observed output."
disp(prompt)
%%
%[text] ## Troubleshooting and next step
%[text] If a prerequisite is missing, keep the numerical baseline and read the optional workflow; record it as unavailable, not passed. Hardware runs require the instructor's target-specific configuration. Reopen the project if file or function resolution fails.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://github.com/matlab/matlab-agentic-toolkit). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: APIs to remember
%[text:table]
%[text] | API | Minimal use | Engineering purpose |
%[text] | --- | --- | --- |
%[text] | [`setup_check`](../setup_check.m) | [`setup_check`](../setup_check.m) | Installed product evidence |
%[text] | [`socEstimate`](../src/socEstimate.m) | socEstimate(V,I,T) | Tool round-trip target |
%[text] | [`assert`](https://www.mathworks.com/help/matlab/ref/assert.html) | assert(condition) | Check actual evidence |
%[text:table]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
