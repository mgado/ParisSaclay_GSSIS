function plan = buildfile
%BUILDFILE Check sources and run the training's meaningful test suite.
%   buildtool runs Code Analyzer checks then MATLAB unit tests.
%   Optional hardware, PyTorch and app walkthroughs are checked separately.
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask
project = requireTrainingProject;
plan = buildplan;
plan("check") = CodeIssuesTask(fullfile(project.RootFolder,"src"));
plan("test") = TestTask(fullfile(project.RootFolder,"tests"));
plan("test").Dependencies = "check";
plan("package") = matlab.buildtool.Task(Actions=@packageTask, ...
    Dependencies="test",Description="Create and inspect a clean local training archive.");
plan.DefaultTasks = "test";
end

function packageTask(~)
packageTraining;
end
