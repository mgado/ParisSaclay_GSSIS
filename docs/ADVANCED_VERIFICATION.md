# Advanced AI verification exercises

Two independent native Live Script pairs extend the earlier affine-bound lesson into a trained model, newly supported R2026b verification features, and an adapted version of the supplied adversarial workshop. Open the MATLAB training Project first; use the catalog entry or open the named student/solution file.

## Exercise 23: Trained SOC, output bounds and regression OOD

The script trains an actual SOC regression network from synthetic battery measurements. The network contains `softplusLayer`, whose support in `estimateNetworkOutputBounds` and `verifyNetworkRobustness` is new in R2026b; the activation layer itself predates R2026b.

The numerical requirement is local: for a fixed true SOC and a declared sensor-uncertainty box, every prediction shall remain within 0.03 absolute SOC of that reference. This is different from global held-out RMSE. A conservative interval wholly inside the limit certifies this property for the box. An interval extending outside it is inconclusive unless a concrete violating input is established. Eight corner predictions are empirical checks, not the basis of the universal certificate.

The optional stronger computation uses `alphaCROWNOptions(MaxEpochs=5,ExecutionEnvironment="cpu")` passed as `Algorithm=options`. Alpha-CROWN options are R2026a; the newly supported softplus layer is the R2026b extension. The optional branch has a finite optimizer budget and reports its measured time.

The regression OOD branch uses the documented HBOS method and an intermediate feature layer. Training-domain numeric matrices and intentionally shifted matrices calibrate the detector. R2026b adds ordinary numeric input data, explicit `InputDataFormats`, batch size and execution-environment options to this workflow. A distribution flag is not a formal safety verdict. Expected behaviour is reported as actual nominal-ID and shifted-OOD fractions rather than hardcoding all observations to succeed.

Runs 1?7 train the neural estimator; run 8 supplies validation operating points. Final test acquisitions 9?10 are reserved while the learner changes widths, uncertainty budgets and bound settings. The script saves the actual network, uncertainty domain, bounds and OOD observations in `generated/verification/trainedSOCVerification.mat`.

## Exercise 24: Short adapted adversarial workshop

This adapts the supplied MathWorks AI Verification Workshop Part1 without editing the original source. It trains a small modern CNN on 800 shipped digit-training observations for three CPU epochs with `trainnet` and cross-entropy. There is no `trainNetwork`, legacy output layer, network download or unbounded search-until-success loop.

The script chooses correctly classified test inputs, then runs at most one student or two solution attack calls. Attempt 1 is FGSM; a second attempt uses the documented BIM options with ten iterations. The exact declared pixel perturbation budget is clipped to valid [0,1] inputs. A returned example is tied to its original input through `iX` and its measured perturbation is checked. When no example is found, the result remains `noneFound` and visualization does not index an empty array.

Finally, `verifyNetworkRobustness` evaluates one complete input box and records its actual `verified`, `unproven`, or `violated` result. The formal result is retained separately from `overallVerdict`. If adversarial search returns an example for that same first input, the script rechecks its exact bounds and actual predicted label: a validated counterexample proves violation of the property even when the formal solver is inconclusive. A counterexample for another image does not change the verdict for the first box. Without that validated witness, the overall verdict retains the formal solver result. It does not promise a particular verdict. `findAdversarialExamples` and `adversarialOptions` are R2026a APIs; their presence should not be described as newly introduced R2026b functionality. Current formal support for the terminal softmax and additional layer types is documented in the relevant release histories.

The classroom distinction is:

- Test accuracy measures a finite held-out sample.
- Successful adversarial search returns an actual counterexample; unsuccessful bounded search is inconclusive.
- Formal verification evaluates the stated region, preserving a three-way verdict and the domain to which it applies.

The learned digit network and actual observations are saved in `generated/verification/digitVerification.mat`. These examples do not establish closed-loop system safety or hardware robustness outside their explicitly defined domains.

## Matching solutions and expected observations

| Exercise | Student starting point | Worked solution |
|---|---|---|
| 23 | 60 training optimizer iterations; base uncertainty scale | 100 iterations; double uncertainty; use observed bounds/flags to decide the verdict |
| 24 | Pixel budget 0.05; at most one FGSM call | Pixel budget 0.1; at most two calls, FGSM then finite BIM if needed |

The solution scripts include the complete executable operations. They remain truthful when a bound is inconclusive or no adversarial example is found. Additional products or layer compatibility failures must be reported as unavailable/failed execution, not as a successful verification.

## Runtime verification status

These sources were authored from current official public syntax and inspected for native Live Script structure. This document does not claim that a new MATLAB run has completed. The main validation session must execute both pairs, inspect their observed results, and add actual runtime/metric evidence to the delivery validation report. Optional stronger bounds can be rehearsed separately; they are disabled by default.

## Attribution and license

The adversarial exercise derives from `initial_material/ai-verification/ai-verification-workshop-main/Part1_GettingStarted.m`. The original source remains unchanged. Its copyright/redistribution conditions and disclaimer are retained in `assets/verification/LICENSE.txt`. The shortened modern training, safe empty-result handling and bounded search are adaptations for this training.

## Official documentation

- [Main AI verification area](https://www.mathworks.com/help/deeplearning/verification.html)
- [Output bounds and R2026b layer-support history](https://www.mathworks.com/help/deeplearning/ref/estimatenetworkoutputbounds.html)
- [Formal robustness and result semantics](https://www.mathworks.com/help/deeplearning/ref/verifynetworkrobustness.html)
- [Alpha-CROWN options and optimizer budget](https://www.mathworks.com/help/deeplearning/ref/alphacrownoptions.html)
- [Regression OOD discriminator and R2026b numeric-input additions](https://www.mathworks.com/help/deeplearning/ref/networkdistributiondiscriminator.html)
- [In-distribution decisions](https://www.mathworks.com/help/deeplearning/ref/isinnetworkdistribution.html)
- [Adversarial search, returned indices and absence-of-example interpretation](https://www.mathworks.com/help/deeplearning/ref/findadversarialexamples.html)
- [Adversarial options and BIM iteration limit](https://www.mathworks.com/help/deeplearning/ref/adversarialoptions.html)
- [Original AI Verification Workshop](https://github.com/mathworks/ai-verification-workshop)

## Current rehearsal
TrainedSoftplusSOCbounds/OOD and bounded digit-adversarialexerciseexecuted onR2026b. SoftplusvalidationRMSE0.0030; selectedboxbound0.00758absoluteSOCerror certifiedunder0.03; nominalIDfraction0.95 andshiftedOODfraction1.0. Digitclassifierafter1600images/sixepochsachieved0.652 ontheshorttestsubset;FGSMfound8counterexamples; formalstatusunproven. These are teaching-specific empirical/proof outcomes, not general model-performance guarantees. SIL25actualgeneratedneuralhostcode executed32samplesmaxdiff2.98e-8; changedtrace5.96e-8. Thor26 stillneeds currentconnection/camera rehearsal.
