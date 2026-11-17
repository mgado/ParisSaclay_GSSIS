function archive = packageTraining
%PACKAGETRAINING Create a clean project-owned local training archive.
%   ARCHIVE = packageTraining packages declared student files and verifies
%   that the Project, catalog and sources can be extracted. Generated
%   outputs and files outside the declared training folders are excluded.
project = requireTrainingProject;
root = char(project.RootFolder);
rootFiles = ["README.md","ParisSaclay_GSSIS.prj","buildfile.m", ...
    "demoAgenda.m","openExercise.m","runExercise.m","setup_check.m", ...
    "exerciseCatalog.json",".gitignore",".gitattributes","THIRD_PARTY_NOTICES.md"];
folders = ["src","tests","workshops","solutions","docs", ...
    "assets","python","resources","licenses"];
relativeFiles = rootFiles;
for folder = ["codegen","requirements","tests","models"]
    seedFolder = fullfile(root,'generated',folder);
    if ~isfolder(seedFolder)
        mkdir(seedFolder);
    end
    seedFile = fullfile(seedFolder,'.gitkeep');
    if ~isfile(seedFile)
        seedHandle = fopen(seedFile,'w');
        assert(seedHandle>=0,'ParisSaclay:SeedWrite','Cannot create runtime path seed.');
        fclose(seedHandle);
    end
    relativeFiles(end+1) = fullfile('generated',folder,'.gitkeep');
end
for folder = folders
    listing = dir(fullfile(root,folder,"**","*"));
    for item = listing'
        if item.isdir || endsWith(item.name,[".slmx",".asv",".slxc",".mexw64"])
            continue
        end
        if strcmpi(item.name,'PROVENANCE.md') || ...
                ismember(string(item.name),["VALIDATION.md","fallback_plan.md"])
            continue
        end
        if contains(lower(item.name),["w22","audiencewordcloud","wordcloud"]) || ...
                ismember(lower(string(item.name)),["opening_polls.md","presenter_prompts_fr.md"])
            continue
        end
        if contains(item.name,[".slx.r",".mdl.r"]) || endsWith(item.name,[".autosave",".m~"])
            continue
        end
        absolute = fullfile(item.folder,item.name);
        relative = extractAfter(string(absolute),strlength(string(root))+1);
        components = split(replace(relative,"\","/"),"/");
        if any(components=="polls")
            continue
        end
        if any(ismember(components,["slprj","sccprj",".buildtool"]))
            continue
        end
        assert(~any(ismember(lower(components), ...
            [".git",".claude",".codex",".agents",".vc","plan", ...
             "agents.md","claude.md","gemini.md"])), ...
            'ParisSaclay:PrivateArtifact','Unexpected private artifact: %s',relative);
        relativeFiles(end+1) = relative;
    end
end
relativeFiles = unique(relativeFiles);
assert(all(isfile(fullfile(root,relativeFiles))), ...
    'ParisSaclay:MissingPackageFile','A declared student file is missing.');
outputFolder = fullfile(root,'generated','packages');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
archive = fullfile(outputFolder,'ParisSaclay_GSSIS_training.zip');
zip(archive,cellstr(relativeFiles),root);
inspectionFolder = tempname(outputFolder);
extracted = unzip(archive,inspectionFolder);
assert(isfile(fullfile(inspectionFolder,'ParisSaclay_GSSIS.prj')));
assert(isfile(fullfile(inspectionFolder,'exerciseCatalog.json')));
assert(isfile(fullfile(inspectionFolder,'src','socEstimate.m')));
manifest = struct('FileCount',numel(relativeFiles), ...
    'ExtractedCount',numel(extracted),'Files',relativeFiles);
manifestFile = fullfile(outputFolder,'manifest.json');
fid = fopen(manifestFile,'w');
assert(fid>=0,'ParisSaclay:ManifestWrite','Cannot write package manifest.');
cleanup = onCleanup(@() fclose(fid));
fwrite(fid,jsonencode(manifest,PrettyPrint=true),'char');
disp(archive);
end
