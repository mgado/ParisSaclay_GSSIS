classdef TestBatteryWorkflow < matlab.unittest.TestCase
    %TESTBATTERYWORKFLOW Verify estimator limits, units and held-out behavior.
    methods (Test)
        function nominalKnownSOC(testCase)
            observed = socEstimate(3.55,1,25);
            testCase.verifyEqual(observed,0.5,AbsTol=1e-12);
        end
        function lowerLimit(testCase)
            testCase.verifyEqual(socEstimate(2,0,25),0);
        end
        function upperLimit(testCase)
            testCase.verifyEqual(socEstimate(5,0,25),1);
        end
        function temperatureCompensation(testCase)
            testCase.verifyEqual(socEstimate(3.62,0,35),0.5,AbsTol=1e-12);
        end
        function syntheticBaselineAccuracy(testCase)
            data = makeBatteryData(17,300);
            predicted = socEstimate(data.voltage,data.current,data.temperature);
            testCase.verifyLessThan(sqrt(mean((predicted-data.soc).^2)),0.005);
        end
        function reproducibleData(testCase)
            testCase.verifyEqual(makeBatteryData(17,20),makeBatteryData(17,20));
        end
        function dataPreservesRandomState(testCase)
            initialState = rng;
            makeBatteryData(99,20);
            testCase.verifyEqual(rng,initialState);
        end
        function neuralHeldOutRequirement(testCase)
            [~,metrics] = trainSOCNetwork;
            testCase.verifyLessThan(metrics.rmse,0.03);
            testCase.verifyEqual(metrics.numTest,120);
        end
        function catalogSelectorRejectsUnknown(testCase)
            testCase.verifyError(@() openExercise("unknown"), ...
                'ParisSaclay:UnknownExercise');
        end
    end
end
