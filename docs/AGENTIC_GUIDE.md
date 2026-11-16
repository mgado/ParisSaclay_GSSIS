# Agentic engineering exercise

## Toolkit readiness

1. In MATLAB R2026b, verify the needed products with `setup_check`.
2. Install/configure the official MathWorks MATLAB and Simulink agentic toolkits
   using their documented Agentic Toolkit Installer if they are not available.
3. In your coding agent, ask for an actual MATLAB tool call:
   `socEstimate(3.55,1,25)` with the training Project open.
4. Require the executed output and compare it with **0.5**.
5. Ask the agent to inspect a model with the Simulink toolkit; opening a skill
   document alone does not prove a successful model tool connection.

Official sources:
https://github.com/matlab/matlab-agentic-toolkit and
https://github.com/matlab/simulink-agentic-toolkit.

## Builtin skill versus tool

A **tool** executes a bounded action: evaluate MATLAB, inspect a model, run a
test. A **skill** supplies reusable workflow instructions. An **agent** chooses
actions, reads results and revises its work. Their roles are different.

Read the official MATLAB testing, requirements and embedded-AI deployment
skills. Ask the agent which skill applies before it edits the isolated exercise
copy. The exact skill name can differ between installed catalogs.

## A small engineering task

Requirement: the SOC estimator must preserve the intended temperature units
and saturation behavior. Request an additional test at a temperature boundary.
Use a personal copy so classmates and the reference solutions are unaffected.

Suggested prompt:

> Inspect socEstimate and TestBatteryWorkflow. Explain volts, amperes, Celsius
> and SOC fraction. Add one meaningful boundary test in my isolated copy. Run
> it with the MATLAB toolkit. Report the requirement, exact edit, executed result
> and any remaining limitation. Do not claim board timing or deployment.

Compare the proposal with `openExercise(16,true)`. A good answer contains a
meaningful test and actual result, not merely a statement that it should pass.

## Create a personal custom skill

Use your agent's supported skill-creation workflow and personal skill location.
The distribution deliberately does not ship agent configuration folders.
Copy this body into your own `SKILL.md` through that workflow:

```markdown
---
name: engineering-teaching-check
description: Explain and verify a small MATLAB engineered-system change.
---
Read the requirement and current implementation before changing code.
State physical units, operating bounds, and the expected observation.
Keep learner instructions in English and presenter explanations in French.
Prefer a few visible MATLAB APIs over hidden helper layers.
Run a focused meaningful check and retain actual output.
Separate passed execution, unavailable prerequisites and UI walkthroughs.
Never infer hardware deployment from a host prediction or compilation.
```

Repeat the same task with and without the skill. Compare unit explanations,
reproducibility, test evidence and recovery instructions. A custom skill improves
repeatable behavior; it does not provide missing products or device access.

## Embedded-AI skill challenge

Ask the official embedded-AI deployment skill to plan the same estimator for
Jetson Thor, STM32F7 and the instructor's Qualcomm board. Require it to identify
board/OS/toolchain/operator/memory prerequisites and actual validation steps.
The Qualcomm model must be identified before claiming support.
