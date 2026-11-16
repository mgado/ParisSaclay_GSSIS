function output = invokeSOCModel(modelFile,input)
%INVOKESOCMODEL Invoke a PyTorch exported program for direct code generation.
%   Pass MODELFILE as coder.Constant at compile time. INPUT keeps the
%   exported PyTorch shape; the supplied linear example expects 1-by-3.
%#codegen
model = loadPyTorchExportedProgram(modelFile);
output = invoke(model,input);
end
