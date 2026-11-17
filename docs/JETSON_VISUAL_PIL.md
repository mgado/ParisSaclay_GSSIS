# Jetson Thor image and camera PIL

Open the camera PIL Live Script from the Project browser and use Run Section.
It exposes a short path: capture a frame, resize it, execute YOLOX through the
processor-in-the-loop gateway, and display the returned detections.

## Prerequisites

Use the products listed in the lesson: GPU Coder/Embedded Coder, Deep Learning
Toolbox, Computer Vision Toolbox, Image Processing Toolbox and NVIDIA target
support. Use a reachable configured Thor with compatible CUDA/cuDNN. Enter its
current address and private Vault login, or reuse an existing board object.

The Project includes the detector MAT-file and a small visible compiler entry
function. A generated gateway must match the model, input shape, target
configuration, generated sources and runtime weight files. Build the selected
configuration when it is absent or has changed.

## Choose the camera location

- **Host camera:** `videoinput` and `getsnapshot` acquire on the computer.
- **Target USB camera:** `webcam(board,...)` and `snapshot` acquire on Thor and
  return the frame to MATLAB. Inspect `board.WebcamList` and use an available
  camera/resolution.

In both prototype paths MATLAB resizes the image to **640-by-640 RGB uint8**,
the PIL gateway executes detector code on Thor, and MATLAB displays annotations.
The target-camera path transfers the image through MATLAB before sending it
back for inference. This is interactive PIL prototyping, not a standalone
low-latency camera application.

## Follow the direct API loop

The selected lesson includes the complete camera setup and a finite loop.
The central operations are:

```matlab
networkFrame = imresize(frame,[640 640]);
[boxes,scores,labelIds,classNames,inferenceFPS] = ...
    cocoSmallYOLO_pil(networkFrame);
textLabels = compose('%s %.2f',string(classNames(labelIds)),scores);
annotatedFrame = insertObjectAnnotation(networkFrame,'rectangle', ...
    boxes,textLabels);
```

Keep box coordinates in the resized image's coordinate system. Change the
scene, inspect detections, and repeat with the same generated code. The included
`sample_car_frame.jpg` supports an image-only check before camera acquisition.

## Expected result

A current PIL run returns finite boxes/scores with consistent lengths and
updates the displayed frame. The outcome becomes `passed` only when the
requested frames actually execute through the target gateway. A static image,
host detector or available source file does not prove current Thor execution.

Detection accuracy requires independent labels; numerical host/target agreement
is a different check. PIL round-trip time includes transfer and processing.
The detector's inference-FPS output is a separate measure.

## Troubleshooting

- **No connection:** check power, network/address, SSH and private login.
- **No camera:** inspect the camera list and supported formats; verify which
  device is attached to the host versus Thor.
- **Image mismatch:** use the fixed RGB uint8 input size and matching box scale.
- **Missing gateway/weights:** generate the selected build and keep required
  runtime files with its executable. Do not copy a gateway by itself.
- **Target runtime error:** keep the actual message and check compatible
  CUDA/cuDNN, runtime paths and model operators before continuing.

## Official references

- [NVIDIA PIL workflow](https://www.mathworks.com/help/coder/nvidia/ug/Processor-in-the-Loop-Execution-on-NVIDIA-Targets.html)
- [jetson](https://www.mathworks.com/help/coder/nvidia/ref/jetson.html)
- [Target webcam](https://www.mathworks.com/help/coder/nvidia/ref/nvidiaio.image.webcam.html)
- [Target snapshot](https://www.mathworks.com/help/coder/nvidia/ref/nvidiaio.image.webcam.snapshot.html)
- [videoinput](https://www.mathworks.com/help/imaq/videoinput.html)
- [getsnapshot](https://www.mathworks.com/help/imaq/imaqdevice.getsnapshot.html)
- [coder.gpuConfig](https://www.mathworks.com/help/gpucoder/ref/coder.gpuconfig.html)
- [YOLOX detector](https://www.mathworks.com/help/vision/ref/yoloxobjectdetector.html)
- [insertObjectAnnotation](https://www.mathworks.com/help/vision/ref/insertobjectannotation.html)
