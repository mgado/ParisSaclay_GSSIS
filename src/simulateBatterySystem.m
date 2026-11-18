function result = simulateBatterySystem(scenario,reserveStop)
%SIMULATEBATTERYSYSTEM Run the coupled battery, AI and reserve supervisor.
%   RESULT = simulateBatterySystem(SCENARIO,RESERVESTOP) runs a 600-second
%   mission. SCENARIO is "nominal", "variable" or "voltageBias". RESERVESTOP
%   is the controller's estimated-SOC cutoff, expressed as a fraction.
%   RESULT contains the simulation trace and a one-row requirements table.
%   The synthetic 1-Ah plant is a teaching model. Its true SOC is a test
%   reference; the running supervisor receives the delayed neural estimate.
%   Example: result = simulateBatterySystem("voltageBias",0.28);
%   See also Simulink.SimulationInput, sim, timeseries, trapz.
arguments
    scenario (1,1) string {mustBeMember(scenario,["nominal","variable","voltageBias"])} = "nominal"
    reserveStop (1,1) double {mustBeGreaterThan(reserveStop,0),mustBeLessThan(reserveStop,1)} = 0.2
end
project = requireTrainingProject;
modelName = 'BatterySystemClosedLoop';
modelFile = fullfile(project.RootFolder,'assets','system_integration','models',[modelName '.slx']);
assert(isfile(modelFile),'ParisSaclay:SystemModelMissing','The system exercise model is missing.');
if ~bdIsLoaded(modelName)
    open_system(modelFile);
end
assert(strcmp(get_param(modelName,'FileName'),modelFile), ...
    'ParisSaclay:SystemModelConflict','A different model with this name is open.');
time = (0:600)';
requestedCurrent = 2*ones(size(time));
ambient = 25*ones(size(time));
voltageBias = 0.001*sin(time/17);
if scenario == "variable"
    requestedCurrent = 1.5 + 2*(time>=80) + 2.5*(time>=160) ...
        - 4*(time>=240) + 0.5*(time>=360);
    ambient = ambient + 10*(time>=80) + 5*(time>=260);
elseif scenario == "voltageBias"
    voltageBias = voltageBias + 0.12*(time>=60);
end
inputs = Simulink.SimulationData.Dataset;
inputs = inputs.addElement(timeseries(requestedCurrent,time),'RequestedCurrent');
inputs = inputs.addElement(timeseries(ambient,time),'AmbientTemperature');
inputs = inputs.addElement(timeseries(voltageBias,time),'VoltageSensorBias');
simulation = Simulink.SimulationInput(modelName);
simulation = simulation.setExternalInput(inputs);
simulation = simulation.setVariable('reserveStop',reserveStop,Workspace=modelName);
simulation = simulation.setModelParameter('StopTime','600');
try
    output = sim(simulation);
catch exception
    error('ParisSaclay:SystemSimulationFailed','System scenario %s failed: %s',scenario,exception.message);
end
values = zeros(numel(time),10);
for index = 1:10
    signal = output.yout.getElement(index).Values;
    assert(isequal(signal.Time(:),time),'ParisSaclay:SystemTime','Unexpected output time grid.');
    values(:,index) = reshape(double(signal.Data),[],1);
end
assert(all(isfinite(values),'all'),'ParisSaclay:SystemNonfinite','A system output is nonfinite.');
trace = array2table(values,VariableNames={'TrueSOC','EstimatedSOC','Current','Temperature', ...
    'Voltage','RequestedCurrent','ReserveTrip','Ambient','VoltageBias','ControllerEstimate'});
trace.Time = time;
socRMSE = sqrt(mean((trace.EstimatedSOC-trace.TrueSOC).^2));
reservePassed = min(trace.TrueSOC)>=0.15;
thermalPassed = max(trace.Temperature)<=45;
currentPassed = all(trace.Current>=-1e-10 & trace.Current<=min(trace.RequestedCurrent,4)+1e-10);
tripRows = trace.ReserveTrip>0.5;
protectionPassed = all(abs(trace.Current(tripRows))<=1e-10) ...
    && all(diff(trace.ReserveTrip)>=0) ...
    && all(abs(trace.Current(trace.ControllerEstimate<=reserveStop))<=1e-10);
energyWh = trapz(time,trace.Voltage.*trace.Current)/3600;
systemPassed = reservePassed && thermalPassed && currentPassed && protectionPassed;
summary = table(scenario,reserveStop,min(trace.TrueSOC),max(trace.Temperature),socRMSE, ...
    energyWh,reservePassed,thermalPassed,currentPassed,protectionPassed,socRMSE<=0.03,systemPassed, ...
    VariableNames={'Scenario','ReserveStop','MinimumTrueSOC','PeakTemperature','SOCRMSE', ...
    'DeliveredWh','ReservePassed','ThermalPassed','CurrentPassed','ProtectionPassed', ...
    'AccuracyPassed','SystemPassed'});
result = struct('Trace',trace,'Summary',summary);
end
