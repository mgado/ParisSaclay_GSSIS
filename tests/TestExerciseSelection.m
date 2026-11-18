classdef TestExerciseSelection < matlab.unittest.TestCase
    %TESTEXERCISESELECTION Verify discoverable and legacy exercise selectors.
    methods (Test)
        function allCatalogAliasesResolve(testCase)
            project = requireTrainingProject;
            catalog = jsondecode(fileread(fullfile(project.RootFolder,'exerciseCatalog.json')));
            for item = catalog.Exercises'
                choices = {item.Number,item.Key,item.Keyword,item.Id,item.Name};
                for choice = choices
                    actual = resolveExerciseSelector(choice{1});
                    testCase.verifyEqual(actual.Id,item.Id);
                    testCase.verifyTrue(isfile(fullfile(project.RootFolder,actual.Source)));
                    testCase.verifyTrue(isfile(fullfile(project.RootFolder,actual.Solution)));
                end
            end
        end
        function textIsCaseInsensitiveAndTrimmed(testCase)
            actual = resolveExerciseSelector("  requirements  ");
            testCase.verifyEqual(actual.Number,2);
            actual = resolveExerciseSelector("2-Requirements");
            testCase.verifyEqual(actual.Number,2);
        end
        function unknownSelectorsKeepLegacyError(testCase)
            testCase.verifyError(@() resolveExerciseSelector("unknown"),'ParisSaclay:UnknownExercise');
            testCase.verifyError(@() resolveExerciseSelector(22),'ParisSaclay:UnknownExercise');
            testCase.verifyError(@() openExercise("unknown"),'ParisSaclay:UnknownExercise');
        end
        function invalidTypesAndShapesAreRejected(testCase)
            choices = {NaN,Inf,1+2i,[1 2],[],0,1.5,true,struct('number',2),["A","B"],""};
            for choice = choices
                testCase.verifyError(@() resolveExerciseSelector(choice{1}),'ParisSaclay:InvalidSelector');
            end
        end
        function completionMetadataContainsEveryChoice(testCase)
            project = requireTrainingProject;
            catalog = jsondecode(fileread(fullfile(project.RootFolder,'exerciseCatalog.json')));
            metadata = fileread(fullfile(project.RootFolder,'functionSignatures.json'));
            for item = catalog.Exercises'
                testCase.verifyTrue(contains(metadata,"'"+string(item.Key)+"'"));
                testCase.verifyTrue(contains(metadata,"'"+string(item.Keyword)+"'"));
            end
        end
    end
end
