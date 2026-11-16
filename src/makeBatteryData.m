function data = makeBatteryData(seed,numObservations)
%MAKEBATTERYDATA Create reproducible illustrative battery observations.
%   DATA = makeBatteryData(SEED,N) returns a table of current, temperature,
%   terminal voltage, state of charge, and independent acquisition groups.
%   The algebraic voltage law is synthetic teaching data, not a cell model.
arguments
    seed (1,1) double = 42
    numObservations (1,1) double {mustBeInteger,mustBePositive} = 600
end
previousState = rng;
restore = onCleanup(@() rng(previousState));
rng(seed);
soc = 0.05 + 0.9*rand(numObservations,1);
current = 4*rand(numObservations,1);
temperature = 15 + 30*rand(numObservations,1);
voltage = 3 + 1.2*soc - 0.05*current + 0.002*(temperature-25);
voltage = voltage + 0.002*randn(numObservations,1);
runId = repelem((1:10)',ceil(numObservations/10));
runId = runId(1:numObservations);
data = table(current,temperature,voltage,soc,runId);
end
