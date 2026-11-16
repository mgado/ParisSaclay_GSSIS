# Reference exercises and further practice

These public resources were used in the previous training and remain useful for deeper practice. The short workshops delivered with this project form the basic path. Choose a reference exercise only after checking its release, products, downloads, runtime and hardware requirements.

Some original links below are pinned to **R2025a**. They are preserved so previous participants can find the same material. For R2026b work, prefer the matching page in installed MATLAB Help or switch the documentation release selector to R2026b before copying commands.

## Prepare before the training

Required preparation:

- [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted)
- [Simulink Onramp](https://matlabacademy.mathworks.com/details/simulink-onramp/simulink)

Recommended preparation:

- [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning)
- [Deep Learning Onramp](https://matlabacademy.mathworks.com/details/deep-learning-onramp/deeplearning)
- [MATLAB Coder Onramp](https://matlabacademy.mathworks.com/details/matlab-coder-onramp/ormc)
- [System Composer Onramp](https://matlabacademy.mathworks.com/details/system-composer-onramp/orsc)

## End-to-end battery SOC workflow

The battery state-of-charge virtual sensor is the main story of this training. The public examples below provide a larger version of the same lifecycle.

| Workflow step | Reference | Recommended use |
|---|---|---|
| Requirements | [Define Requirements for Battery State of Charge Estimation](https://www.mathworks.com/help/deeplearning/ug/define-requirements-for-battery-state-of-charge-estimation.html) | Extend exercise 2 with the full requirement set and traceability workflow |
| Complete workshop | [AI with Model-Based Design Workshop](https://github.com/mathworks/AI-with-MBD-Workshop) | Selected advanced training/integration tasks; check the repository README and dataset requirements first |
| Training | [Train Network for Battery State of Charge Estimation](https://www.mathworks.com/help/deeplearning/ug/train-network-for-battery-state-of-charge-estimation.html) | Extend exercises 4–5 with the reference sequence-estimation model |
| Compression | [Compress Network for Battery State of Charge Estimation](https://www.mathworks.com/help/deeplearning/ug/compress-network-for-battery-state-of-charge-estimation.html) | Extend exercise 7 and re-evaluate compressed-model accuracy |
| Robustness | [Test Network for Battery State of Charge Estimation](https://www.mathworks.com/help/deeplearning/ug/test-network-for-battery-state-of-charge-estimation.html) | Extend exercise 8 with reference operating conditions and failure investigation |
| Integration | [Integrate AI Network into Simulink for Battery State of Charge Estimation — original R2025a link](https://www.mathworks.com/help/releases/R2025a/deeplearning/ug/integrate-ai-network-into-simulink-for-battery-state-of-charge-estimation.html) | Extend exercises 9–10 using the larger system model |
| Deployment | [Deploy Model for Battery State of Charge Estimation — original R2025a link](https://www.mathworks.com/help/releases/R2025a/deeplearning/ug/deploy-model-for-battery-state-of-charge-estimation.html) | Extend exercise 11 after checking the selected target and build products |

## Data preparation and annotation

Choose the app that matches the data modality. For the battery story, time-series preparation and Signal Labeler are the most direct extensions; image/video/scene labelers illustrate how the same data-management principles transfer to perception.

- [Get Started with Image Labeler](https://www.mathworks.com/help/vision/ug/get-started-with-the-image-labeler.html)
- [Use Signal Labeler](https://www.mathworks.com/help/signal/ug/use-signal-labeler.html)
- [Get Started with Video Labeler](https://www.mathworks.com/help/vision/ug/get-started-with-the-video-labeler.html)
- [Get Started with Ground Truth Labeler](https://www.mathworks.com/help/driving/ug/get-started-with-the-ground-truth-labeler.html)

Connect these optional activities to exercises 3 and 17: document labeling rules, preserve raw data, record preprocessing, and keep evaluation scenarios independent from training.

## MATLAB and Python interoperability

- [Ways to Call Python from MATLAB](https://www.mathworks.com/help/matlab/matlab_external/ways-to-call-python-from-matlab.html)

Start with the numeric exchange in exercise 6. Then select one supported model route. Calling Python, importing a model into MATLAB, and generating code directly from a third-party model are different workflows with different dependencies. Check Python compatibility and conversion/code-generation support before proceeding.

## Physics-informed AI and ROM extensions

- [Physics-Informed Neural Networks with MATLAB: live-coding session](https://github.com/matlab-deep-learning/physics-informed-neural-networks-with-matlab-live-coding-session)

Use this as an advanced continuation of exercises 14 and 18. A physics-constrained parameter fit, a neural network trained with a differential-equation loss, and a neural operator predicting spatial fields solve different problems. Explain the required inputs, training information and held-out checks before choosing a method.

For full-field ROM practice, begin with exercises 13 and 19. Distinguish reconstruction of known snapshots from predicting a new field from an unseen input. Derive maximum temperature, average temperature and hotspot location from the predicted field, then compare with an independent reference.

## AI verification extension

- [AI Verification Workshop](https://github.com/mathworks/ai-verification-workshop)
- [AI Verification Library for Deep Learning Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/118735-ai-verification-library-for-deep-learning-toolbox)

Recommended selected exercises: adversarial examples first, then local robustness on ACAS Xu. Global verification is an advanced continuation and can require more computation and external assets. Read the current workshop README before running setup/download scripts.

Maintain the distinction between tested cases, a found adversarial counterexample, and a formal conclusion over a stated input domain. An unproven outcome is not a verified property, and a bounded neural-network result does not by itself prove the whole engineered system safe.

## Optional hardware and application examples

- [Generate Code for a Quantized Deep Learning Network on Raspberry Pi](https://www.mathworks.com/help/coder/ug/code-generation-for-quantized-deep-learning-network-on-raspberry-pi.html)
- [Highway Lane Following](https://www.mathworks.com/help/driving/ug/highway-lane-following.html)

These were additional examples shared previously. Raspberry Pi deployment is an alternative target-specific exercise, not evidence that the same configuration works on Jetson Thor, STM32F7 or a Qualcomm board. Highway lane following is a separate perception/control application and should follow completion of the battery workflow.

## Suggested advanced selection

For a focused continuation, choose **one** of these paths:

1. **AI virtual sensor:** larger SOC training → compression → robustness → Simulink integration → supported target deployment.
2. **Physics-informed modeling:** simple PINN live-coding → cooling-model physics loss → full-field prediction and held-out error checks.
3. **Verification:** adversarial examples → ACAS Xu local robustness → optional global verification.
4. **Perception data:** Image/Video/Ground Truth Labeler → application-specific model → integration and target constraints.

Preserve the original public links when sharing notes. External repositories and example assets retain their own licenses; verify those terms before redistributing their code or datasets.
