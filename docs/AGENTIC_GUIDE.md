# Agentic engineering with MATLAB and Simulink

Use an agent to inspect an engineering problem, select the relevant skills, make a small change and obtain actual MATLAB or Simulink evidence. Work in a personal exercise copy when changing files.

## Check the toolkit connection

1. Open the training MATLAB Project in R2026b and run [setup_check](../setup_check.m).
2. Configure the official [MATLAB toolkit](https://github.com/matlab/matlab-agentic-toolkit) and [Simulink toolkit](https://github.com/matlab/simulink-agentic-toolkit) for your agent and operating system.
3. If setup is needed, follow the official Agentic Toolkit Installer instructions. After installing it in MATLAB, run `setupAgenticToolkit("install")` and select the relevant skills and agent connection.
4. Restart or reconnect your agent as required by that setup.
5. Ask the agent to call a MATLAB tool that evaluates `socEstimate(3.55,1,25)` with the Project open. The expected output is **0.5**.
6. Ask it to inspect the generated SOC model using a Simulink tool. Check the returned model information rather than treat opening a skill document as connection evidence.

A MATLAB-side product check and an agent-to-tool round trip test different prerequisites. Resolve the missing connection or product before using that path.

## Understand tools, skills and agents

A **tool** executes a bounded action, such as evaluating MATLAB, inspecting a model or running tests. A **skill** supplies reusable instructions for a workflow. An **agent** chooses actions, reads their results and revises its work.

Read the installed MATLAB testing, requirements and embedded-AI skills. Ask the agent to explain which one applies to the task. Skill names can vary between installed catalogs; use those actually available in your connection.

## Make and verify one engineering improvement

Use [socEstimate](../src/socEstimate.m) and [TestBatteryWorkflow](../tests/TestBatteryWorkflow.m) as the starting point. Add a meaningful temperature-domain test while preserving volts, amperes, Celsius and SOC-fraction units.

Suggested prompt:

> Inspect socEstimate and TestBatteryWorkflow in my exercise copy. Explain the input units and expected saturation behaviour. Add one meaningful temperature-domain test. Derive its expected result, run it with the MATLAB toolkit, and report the changed file, test input, observed output and test result.

For a concrete check, the synthetic sensor law gives SOC **0.5** for voltage **3.59 V**, current **1 A** and temperature **45 degrees Celsius**. Explain the chosen tolerance and which property the test covers.

Review the edit before accepting it. Ask for the exact test output, not a statement that the test should pass. Compare your result with the solution and explain whether the new test covers a boundary, a nominal value or an invalid-input condition.

## Create a personal custom skill

Use your agent's supported skill-creation workflow and personal skill location. Give it the following body for `SKILL.md`:

```markdown
---
name: engineering-teaching-check
description: Explain and verify a small MATLAB engineered-system change.
---
Read the requirement and implementation before changing code.
State physical units, operating bounds and the expected observation.
Use clear English explanations and a few visible MATLAB APIs.
Make a focused change and run a meaningful check.
Retain actual output and explain what it establishes.
Distinguish passed execution, missing prerequisites and guided UI actions.
Do not infer target execution from a host prediction or compilation.
```

Repeat the same engineering task with and without the skill. Compare the unit explanation, edit size, test relevance, execution evidence and recovery instructions. The skill changes repeatable behaviour; it does not provide missing products or hardware access.

## Apply an embedded-AI skill

Choose a deployment target and ask the installed embedded-AI skill to plan the SOC estimator's route. Require the board/OS/compiler, supported operators, memory limits and test strategy. Identify unknown prerequisites before attempting deployment.

Ask it to separate host code generation and equivalence checks from actual processor execution. A successful host prediction is useful evidence, but it does not measure the target's execution time or demonstrate PIL.

## Record the engineering result

Keep the requirement, changed file, exact command, observed output and interpretation with your exercise notes. Use [MATLAB tests](https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html), [Simulink Test](https://www.mathworks.com/help/sltest/) and [requirements verification](https://www.mathworks.com/help/slrequirements/verify-requirements.html) when they fit the task.
