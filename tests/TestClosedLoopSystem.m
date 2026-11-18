classdef TestClosedLoopSystem < matlab.unittest.TestCase
    %TESTCLOSEDLOOPSYSTEM Verify physical balance and AI-dependent system behavior.
    properties
        Nominal
        Variable
        Biased
        Protected
        ProtectedNominal
    end
    methods (TestClassSetup)
        function runSystemScenarios(testCase)
            testCase.Nominal = simulateBatterySystem("nominal",0.2);
            testCase.Variable = simulateBatterySystem("variable",0.2);
            testCase.Biased = simulateBatterySystem("voltageBias",0.2);
            testCase.Protected = simulateBatterySystem("voltageBias",0.28);
            testCase.ProtectedNominal = simulateBatterySystem("nominal",0.28);
        end
    end
    methods (Test)
        function healthyMissionsMeetSystemRequirements(testCase)
            testCase.verifyTrue(testCase.Nominal.Summary.SystemPassed);
            testCase.verifyTrue(testCase.Variable.Summary.SystemPassed);
            testCase.verifyTrue(testCase.Nominal.Summary.AccuracyPassed);
            testCase.verifyEqual(max(testCase.Variable.Trace.Current),4,AbsTol=1e-10);
        end
        function sensorBiasProducesPhysicalReserveViolation(testCase)
            testCase.verifyFalse(testCase.Biased.Summary.ReservePassed);
            testCase.verifyLessThan(testCase.Biased.Summary.MinimumTrueSOC,0.15);
            testCase.verifyGreaterThan(testCase.Biased.Summary.DeliveredWh, ...
                testCase.Nominal.Summary.DeliveredWh);
        end
        function marginProtectsSystemWithoutRepairingAI(testCase)
            testCase.verifyTrue(testCase.Protected.Summary.SystemPassed);
            testCase.verifyFalse(testCase.Protected.Summary.AccuracyPassed);
            testCase.verifyGreaterThan(testCase.Protected.Summary.SOCRMSE,0.05);
        end
        function protectionMarginHasHealthyEnergyCost(testCase)
            testCase.verifyTrue(testCase.ProtectedNominal.Summary.SystemPassed);
            testCase.verifyLessThan(testCase.ProtectedNominal.Summary.DeliveredWh, ...
                testCase.Nominal.Summary.DeliveredWh);
        end
        function plantConservesCharge(testCase)
            trace = testCase.Variable.Trace;
            balance = diff(trace.TrueSOC) + trace.Current(1:end-1)/3600;
            testCase.verifyLessThan(max(abs(balance)),1e-10);
        end
    end
end
