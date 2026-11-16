function soc = socEstimate(voltage,current,temperature)
%SOCESTIMATE Compute an illustrative bounded battery state-of-charge.
%   SOC = socEstimate(V,I,T) inverts the teaching voltage law, then bounds
%   the result between zero and one. Units: volts, amperes, Celsius.
%   This analytic baseline is used for host code-generation verification.
%#codegen
soc = (voltage - 3 + 0.05*current - 0.002*(temperature-25))/1.2;
soc = min(max(soc,0),1);
end
