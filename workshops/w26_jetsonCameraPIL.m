%[text] # 26 — Jetson Thor camera AI with a short MATLAB PIL loop
%[text] **Goal:** Connect to Thor, acquire a frame from its USB camera, run the real YOLOX detector on the processor and display detections from MATLAB. The main path contains direct camera, resize, PIL and annotation commands; it does not use tracking, pose-estimation or application helpers.
%[text] **Prerequisites:** MATLAB R2026b, GPU Coder/Embedded Coder, Deep Learning Toolbox, Computer Vision Toolbox, Image Processing Toolbox and NVIDIA target support; a reachable configured Thor with compatible CUDA/cuDNN and USB camera. Use the included model and entry function. All hardware/build actions are opt-in; an unavailable target is not a passed PIL result.
%[text] **Launch:** openExercise(26), then Run Section. Read [NVIDIA target PIL](https://www.mathworks.com/help/coder/nvidia/ug/Processor-in-the-Loop-Execution-on-NVIDIA-Targets.html) and [Jetson connection](https://www.mathworks.com/help/coder/nvidia/ref/jetson.html). Check the target connection, build and required runtime weights before using the loop.
%[text] **Your task:** Point the target camera at a person or car, run ten PIL frames, and explain where acquisition, resizing, neural inference and display execute. Compare a repeated run without regenerating the model.
project = requireTrainingProject;
runHardware = false;
runBuildPIL = false;
maximumFrames = 10;
cameraIndex = 1;
cameraMode = "host"; % "target" selects a USB camera attached to Thor.
thorAddress = "";
userSecretName = "RTMPoseThorUserName";
passwordSecretName = "RTMPoseThorPassword";
existingBoard = [];
demoOutcome = struct('Status','unavailable','Summary','Jetson camera PIL has not executed.','Evidence',struct('PILExecuted',false));
assetFolder = fullfile(project.RootFolder,'assets','jetson_visual');
buildFolder = fullfile(project.RootFolder,'generated','codegen','jetson_visual');
addPath(project,assetFolder);
%%
%[text] ## Step 1: Inspect the model and tiny compiler entry point
%[text] cocoSmallYOLO.m is the visible compiler entry function using coder.loadDeepLearningNetwork: load the local YOLOX detector, call detect, return boxes/scores/classes and an inference-only smoothed FPS. A compiler requires a function entry point; this file is visible and contains no hidden camera, tracking or deployment layers. Model and license are included. Reuse a generated build only when its model and configuration are unchanged.
entryFile = fullfile(project.RootFolder,'src','cocoSmallYOLO.m');
assert(isfile(entryFile) && isfile(fullfile(assetFolder,'cocoSmallYOLO.mat')));
%%
%[text] ## Step 2: Connect to Thor and its USB camera
%[text] The recorded source address is 192.168.7.1; verify that it is the current Thor address. Store/reuse the private Vault credentials; never put their values in this shared file. The default host camera uses videoinput/getsnapshot, validated on the integrated camera. Set cameraMode to target for documented Jetson webcam/snapshot acquisition, which transfers the image to MATLAB. The PIL call then sends the resized image back for target inference: this is a convenient prototyping loop, not a standalone low-latency camera application.
if runHardware
    if isempty(existingBoard)
        assert(strlength(thorAddress)>0,'Set the current Thor address after checking its network connection.');
        assert(isSecret(userSecretName) && isSecret(passwordSecretName),'Configure the private Thor Vault credentials before this section.');
        board = jetson(thorAddress,getSecret(userSecretName),getSecret(passwordSecretName));
    else
        board = existingBoard;
        thorAddress = string(board.DeviceAddress);
    end
    setupCodegenContext(board);
    if cameraMode=="target"
        cameraNames = board.WebcamList
        assert(~isempty(cameraNames),'No target USB camera was reported.');
    else
        hostCameraInfo = imaqhwinfo('winvideo');
        assert(~isempty(hostCameraInfo.DeviceIDs),'No host camera was reported.');
    end
end
%%
%[text] ## Step 3: Build once or reuse matched generated code
%[text] Build when the model, entry point or target configuration changes. Reuse only a matching generated build, and keep its required network weights alongside the target runtime. A gateway file alone is insufficient.
if runHardware && runBuildPIL
    if ~isfolder(buildFolder), mkdir(buildFolder); end
    configuration = coder.gpuConfig('lib','ecoder',true);
    configuration.DeepLearningConfig = coder.DeepLearningConfig(TargetLibrary='cudnn');
    configuration.VerificationMode = 'PIL';
    configuration.GpuConfig.ComputeCapability = '11.0';
    configuration.GpuConfig.EnableMemoryManager = true;
    configuration.Hardware = coder.hardware('NVIDIA Jetson');
    configuration.Hardware.DeviceAddress = thorAddress;
    configuration.Hardware.Username = getSecret(userSecretName);
    configuration.Hardware.Password = getSecret(passwordSecretName);
    configuration.Hardware.BuildDir = '/tmp/parissaclay_jetson_visual';
    configuration.GenerateReport = false;
    codegen('cocoSmallYOLO','-config',configuration,'-args',{zeros(640,640,3,'uint8')},'-d',buildFolder);
end
if runHardware
    gatewayFolder = fullfile(buildFolder,'pil');
    assert(isfile(fullfile(gatewayFolder,['cocoSmallYOLO_pil.' mexext])),'Build the matching PIL gateway and provide its required runtime weights first.');
    addPath(project,gatewayFolder);
end
%%
%[text] ## Step 4: Camera, processor inference and display — directly
%[text] This is the complete visible loop. The actual YOLOX code executes through the generated PIL gateway on Thor. Resizing and annotations execute in MATLAB. Display coordinates match the resized 640-by-640 frame. Each frame's round trip includes image transfers and inference; it is not pure GPU inference time.
if runHardware
    camera = [];
    try
        if cameraMode=="target"
            camera = webcam(board,cameraIndex,'640x480');
            networkFrame = imresize(snapshot(camera),[640 640]);
        else
            camera = videoinput('winvideo',cameraIndex);
            camera.ReturnedColorSpace = 'rgb';
            networkFrame = imresize(getsnapshot(camera),[640 640]);
        end
        displayImage = imageshow(networkFrame);
        title(displayImage.Parent,'Current Jetson Thor PIL detections');
        roundTripSeconds = zeros(maximumFrames,1);
        detectionCounts = zeros(maximumFrames,1);
        for frameNumber = 1:maximumFrames
            if cameraMode=="target", networkFrame = imresize(snapshot(camera),[640 640]); else, networkFrame = imresize(getsnapshot(camera),[640 640]); end
            started = tic;
            [boxes,scores,labelIds,classNames,inferenceFPS] = cocoSmallYOLO_pil(networkFrame);
            roundTripSeconds(frameNumber) = toc(started);
            assert(size(boxes,1)==numel(scores) && all(isfinite(boxes),'all') && all(isfinite(scores)));
            if iscategorical(labelIds)
                textLabels = compose('%s %.2f',string(labelIds),scores);
            else
                assert(all(labelIds>=1 & labelIds<=numel(classNames)));
                textLabels = compose('%s %.2f',string(classNames(labelIds)),scores);
            end
            annotatedFrame = insertObjectAnnotation(networkFrame,'rectangle',boxes,textLabels);
            displayImage.Data = annotatedFrame;
            detectionCounts(frameNumber) = size(boxes,1);
            drawnow;
        end
        delete(camera);
        demoOutcome = struct('Status','passed','Summary','Current camera frames processed by the Thor PIL detector.','Evidence',struct('PILExecuted',true,'Frames',maximumFrames,'DetectionCounts',detectionCounts,'MedianPILRoundTripSeconds',median(roundTripSeconds),'LastInferenceFPS',inferenceFPS));
    catch exception
        if ~isempty(camera), delete(camera); end
        demoOutcome = struct('Status','failed','Summary',exception.message,'Evidence',struct('PILExecuted',false,'ErrorIdentifier',exception.identifier));
        rethrow(exception);
    end
end
demoOutcome
%%
%[text] ## Example detector output and troubleshooting
%[text] The image shows example detector output. Run the current frame through the PIL gateway to obtain your own result; a host-only prediction is not processor-in-the-loop execution.
image(imread(fullfile(assetFolder,'detector_example.png')));
axis image off;
%[text] If target setup fails, check reachability, Vault credentials, camera availability and CUDA/cuDNN compatibility. If inference starts then fails, verify the generated weights and exact loader/runtime path mapping. Preserve original generated sources; rebuild only the matched copied/staged tree. This loop intentionally omits tracking and pose estimation to keep the teaching path small.
%%
%[text] ## Documentation and further reading
%[text] [Main documentation for this area](https://www.mathworks.com/help/coder/nvidia/ug/Processor-in-the-Loop-Execution-on-NVIDIA-Targets.html). Use the linked API names in the cheat sheet below to check syntax, examples and release history.
%%
%[text] ## Cheat sheet: camera and target APIs
%[text] **Origin:** Product and add-on names identify shipped MathWorks functionality. Training helper means code provided with this training; example data and generated interfaces are labelled separately. See the [helper reference](../docs/TRAINING_HELPERS.md).
%[text] Project setup uses [requireTrainingProject](../src/requireTrainingProject.m), a training helper using MATLAB Project APIs.
%[text:table]
%[text] | API | Minimal syntax | Purpose | Origin |
%[text] | --- | --- | --- | --- |
%[text] | [jetson](https://www.mathworks.com/help/coder/nvidia/ref/jetson.html) | `jetson(address,user,password)` | Connect host to the board | MATLAB Coder NVIDIA support package |
%[text] | [setupCodegenContext](https://www.mathworks.com/help/coder/nvidia/ref/setupcodegencontext.html) | `setupCodegenContext(board)` | Establish supported target build context | MATLAB Coder NVIDIA support package |
%[text] | [webcam](https://www.mathworks.com/help/coder/nvidia/ref/nvidiaio.image.webcam.html) | `webcam(board,1,'640x480')` | Open a target USB camera | MATLAB Coder NVIDIA support package |
%[text] | [snapshot](https://www.mathworks.com/help/coder/nvidia/ref/nvidiaio.image.webcam.snapshot.html) | `snapshot(camera)` | Target acquisition, image transferred to MATLAB | MATLAB Coder NVIDIA support package |
%[text] | [imresize](https://www.mathworks.com/help/matlab/ref/imresize.html) | `imresize(frame,[640 640])` | Host preprocessing | MATLAB |
%[text] | [coder.gpuConfig](https://www.mathworks.com/help/gpucoder/ref/coder.gpuconfig.html) | `coder.gpuConfig('lib','ecoder',true)` | CUDA/PIL build configuration | GPU Coder + Embedded Coder |
%[text] | [codegen](https://www.mathworks.com/help/coder/ref/codegen.html) | Generate the fixed image entry point | Produce target code and gateway | MATLAB Coder + GPU Coder + Embedded Coder |
%[text] | [`codebuild`](https://www.mathworks.com/help/coder/build-configuration.html) | `codebuild(buildFolder)`; consult installed help | Rebuild matched generated sources | MATLAB Coder (GPU builds: GPU Coder) |
%[text] | [detect: YOLOX methods](https://www.mathworks.com/help/vision/ref/yoloxobjectdetector.html) | `detect(detector,image)` inside the entry function | Neural inference on Thor through PIL | Computer Vision Toolbox |
%[text] | [insertObjectAnnotation](https://www.mathworks.com/help/vision/ref/insertobjectannotation.html) | Draw returned boxes/classes | Host annotations | Computer Vision Toolbox |
%[text] | [imageshow](https://www.mathworks.com/help/images/ref/imageshow.html) | Create/update the image viewer | Host display | Image Processing Toolbox |
%[text] | [NVIDIA PIL workflow](https://www.mathworks.com/help/coder/nvidia/ug/Processor-in-the-Loop-Execution-on-NVIDIA-Targets.html) | Read before first build | Distinguish prototype PIL from standalone deployment | Workflow reference (NVIDIA support package) |
%[text] | [`cocoSmallYOLO`](../src/cocoSmallYOLO.m) | `cocoSmallYOLO(frame)` | Provide the supplied detector compiler entry point | Training helper (MATLAB Coder + Computer Vision Toolbox + Deep Learning Toolbox) |
%[text] | [`cocoSmallYOLO_pil`](https://www.mathworks.com/help/coder/ref/codegen.html) | `cocoSmallYOLO_pil(frame)` | Execute the generated target detector PIL interface | Generated PIL interface (GPU Coder + Embedded Coder + NVIDIA support package) |
%[text] | [videoinput](https://www.mathworks.com/help/imaq/videoinput.html) | `videoinput("winvideo",cameraIndex)` | Create the default host-camera acquisition object | Image Acquisition Toolbox |
%[text] | [getsnapshot](https://www.mathworks.com/help/imaq/imaqdevice.getsnapshot.html) | `frame = getsnapshot(camera)` | Acquire one frame from the host camera | Image Acquisition Toolbox |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
