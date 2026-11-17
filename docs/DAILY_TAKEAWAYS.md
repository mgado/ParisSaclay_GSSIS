# Daily takeaways

## Day 1 - Make the problem testable

- Turn system needs into measurable accuracy, operating-domain and resource requirements.
- Keep requirements, interfaces and tests connected.
- Split independent experiments rather than correlated rows.
- Preserve units, raw data and reproducible cleaning decisions.
- Use engineering agents for actions you can inspect and check.

**Remember:** The dataset and the requirement are part of the AI model.

## Day 2 - Choose an acceptable model

- Start with a baseline you can explain.
- Train or import through a clear, reproducible workflow.
- Use validation to select settings and final test data to evaluate them.
- Compress, then recheck accuracy, units and operating limits.
- Distinguish evaluated cases, adversarial counterexamples and formal bounds.

**Remember:** Smaller is useful only when the relevant requirements still hold.

## Day 3 - Compare implementations and modeling methods

- Integrate in Simulink and run requirement-driven tests.
- Keep model, generated-host-code, SIL and target-PIL comparisons distinct.
- Separate numerical accuracy, timing, memory and target configuration.
- Choose a ROM from the output required and the physics/data available.
- Check a PINN or predictive field model on independent conditions.
- Ask an agent for a focused engineering change and verify its result.

**Remember:** A model result, a host result and a hardware result establish different evidence.

## Take the workflow into your research

1. Choose a concrete task and define one measurable requirement.
2. Prepare independent data and a baseline you can explain.
3. Train or import, evaluate and improve against that requirement.
4. Integrate or implement the candidate and run a meaningful check.
5. Record the operating conditions, result and remaining limitation.

**Your next step:** Select one research task, one requirement and one check you can run.
