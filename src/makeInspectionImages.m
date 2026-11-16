function datasets = makeInspectionImages
%MAKEINSPECTIONIMAGES Create small illustrative battery-cover image datasets.
%   DATASETS = makeInspectionImages returns train/calibration/test image
%   datastores. Images are synthetic fixed-pose teaching assets, not real
%   inspection measurements. The defect class contains an artificial mark.
%   See also imageDatastore, imwrite.
project = requireTrainingProject;
previousState = rng;
restore = onCleanup(@() rng(previousState));
rng(29);
root = fullfile(project.RootFolder,'generated','inspection');
partitions = ["train","calibration","test"];
for partition = partitions
    classes = "normal";
    if partition ~= "train"
        classes = ["normal","defect"];
    end
    for label = classes
        folder = fullfile(root,partition,label);
        if ~isfolder(folder)
            mkdir(folder);
        end
        for sample = 1:12
            imageData = 35 + 2*randn(128);
            imageData(25:105,30:98) = 170 + 2*randn(81,69);
            if label == "defect"
                row = 45 + randi(30);
                column = 45 + randi(25);
                imageData(row:row+7,column:column+7) = 55;
            end
            imageData = uint8(max(0,min(255,imageData)));
            filename = fullfile(folder,sprintf('cover%02d.png',sample));
            imwrite(imageData,filename);
        end
    end
end
datasets.Train = imageDatastore(fullfile(root,'train'), ...
    IncludeSubfolders=true,LabelSource='foldernames');
datasets.Calibration = imageDatastore(fullfile(root,'calibration'), ...
    IncludeSubfolders=true,LabelSource='foldernames');
datasets.Test = imageDatastore(fullfile(root,'test'), ...
    IncludeSubfolders=true,LabelSource='foldernames');
end
