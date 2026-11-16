function output = predictPiSOC(networkFile,input)
%PREDICTPISOC Run the supplied projected battery network for code generation.
%   OUTPUT = predictPiSOC(NETWORKFILE,INPUT) accepts a compile-time constant
%   network MAT-file and time-by-feature single sensor data. The source
%   Expo example uses the same coder.loadDeepLearningNetwork/predict route.
%   See also coder.loadDeepLearningNetwork, predict, codegen.
%#codegen
persistent network cachedFile
if isempty(cachedFile)
    cachedFile = networkFile;
end
if isempty(network) || ~isequal(cachedFile,networkFile)
    network = coder.loadDeepLearningNetwork(networkFile);
    cachedFile = networkFile;
end
output = predict(network,input);
end
