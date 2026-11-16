function [bboxes, scores, labels, classNames, fpsOut] = cocoSmallYOLO(currFrame) %#codegen
%cocoSmallYOLO Detect objects with the local YOLOX model for image PIL.
%   [BOXES,SCORES,LABELS,NAMES,FPS] = cocoSmallYOLO(FRAME) accepts
%   a 640-by-640-by-3 uint8 frame. Model data must be on the Project path.
%   See also coder.loadDeepLearningNetwork, detect, codegen.
% Copyright 2025 The MathWorks, Inc.
persistent fps;
if isempty(fps)
    fps = 1;
end
persistent yoloModel;
if isempty(yoloModel)
    yoloModel = coder.loadDeepLearningNetwork("cocoSmallYOLO.mat");
end

tic1 = tic;
[bboxes,scores,labels] = detect(yoloModel,currFrame,Threshold = 0.5);
newt = toc(tic1);
classNames = yoloModel.ClassNames;
fps = .9*fps + .1*(1/newt);
fpsOut = fps;
end
