# Daily takeaways

## Day 1 closing slide

**Before training an AI model, define its engineering contract**

- Turn system needs into measurable requirements: accuracy, operating domain, latency and memory.
- Keep requirements, model interfaces and tests connected.
- Generate representative scenarios; split by experiment, not correlated rows.
- Preserve units, raw data and reproducible cleaning steps.
- Agents can assist the work; executed checks make their output reviewable.

**Remember:** A good dataset and a testable requirement are part of the model.

## Day 2 closing slide

**Choose and verify an AI model for the system it must serve**

- Start with a transparent baseline; add complexity only when it earns its cost.
- Train or import models using a clear, reproducible workflow.
- Use validation to choose the model; reserve the final test for evaluation.
- Compress, then recheck accuracy, units and operating limits.
- Tests, adversarial search and formal bounds answer different questions.

**Remember:** The smallest acceptable model is a system-design choice.

## Day 3 closing slide

**An AI component becomes useful when the whole system can be tested**

- Integrate the estimator in Simulink and replay requirement-driven scenarios.
- Use PIL to run the same algorithm on the processor while MATLAB/Simulink supplies inputs and compares outputs.
- Keep accuracy, execution time and memory evidence separate.
- Choose a ROM from the required output and the available physics or data.
- Use physics and agentic tools to improve the workflow, then verify the change.

**Remember:** A model result, a host test and a hardware result are different evidence.

## Common final slide — What you can now do

**Take this workflow back to your research**

- Give an AI component a measurable engineering contract.
- Prepare independent data and build a baseline you can explain.
- Train or import, compress, and evaluate against that contract.
- Integrate in Simulink, link tests, and compare generated code.
- Build a small ROM or PINN and assess it on independent conditions.
- Ask an engineering agent for a concrete change—and verify the result.

**Your next step:** Choose one research task, one requirement and one check you can run.

