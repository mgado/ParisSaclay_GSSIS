# Simple Jetson Thor camera AI

Exercise 26 keeps the main Live Script small: connect to Thor, open its USB
camera, take a snapshot, resize, call the generated detector PIL gateway, and
display the returned boxes/classes. It uses the actual supplied YOLOX detector,
not an untrained substitute. No tracking, keypoint, application or overlay
helper layer is used.

## Runtime assets

- `assets/jetson_visual/cocoSmallYOLO.mat`: supplied trained YOLOX model.
- `src/cocoSmallYOLO.m`: original short compiler entry point, visible to students.
- `assets/jetson_visual/LICENSE_MATHWORKS.txt`: retained source license.
- `assets/jetson_visual/expo_gpu_preview.png`: historical illustration only.
- The generated PIL gateway, sources and weights belong under a separately
  rehearsed local `generated/codegen/jetson_visual` tree and are not shared source.

A compiler requires a function entry point. The supplied function loads the
model, calls `detect`, and returns detections/classes and an inference-only FPS
estimate. Camera, preprocessing, target execution and display remain visible
in the Live Script. The model filename resolves through the Project-owned
asset path; no external source folder is hardcoded in the student script.

## Where the work executes

`webcam(board,...)` and `snapshot(camera)` acquire on the target and return the
frame to MATLAB. MATLAB resizes it; the generated `cocoSmallYOLO_pil` transfers
the fixed image for neural inference on Thor. MATLAB draws the result.

This provides convenient interactive prototyping from MATLAB. The image makes
two trips through the host, so this is not a standalone low-latency camera app.
A later native camera application moves acquisition/preprocessing/display into
the target executable; do not conflate those execution models.

## First build versus reuse

The instructor may reuse a **matched** generated source/gateway/weight tree
when algorithm and target configuration are unchanged. A gateway alone is not
self-contained. The prior Expo build required a Windows-to-Linux generated
weight-loader repair followed by `codebuild` and PIL executable relinking.
That existing runtime mapping must be qualified before a current run.

Changing the model/entry point or its path/configuration can require a fresh
build. The student source exposes the direct `coder.gpuConfig`, `coder.hardware`
and `codegen` APIs. The runtime still must be tested; do not treat files or old
validation results as a new passing deployment. Preserve original reference
trees and perform any rebuild/path repair on the owned staged copy.

## Connection and camera

The source Thor address is `192.168.7.1`. Verify the current reachable address;
power alone does not establish a network connection. Existing secure source
configuration names the Vault keys `RTMPoseThorUserName` and
`RTMPoseThorPassword`. Their presence and actual connection need checking on
the presentation machine. Never copy legacy hardcoded credential values.

Inspect `board.WebcamList`, choose the intended USB camera, and use a reported
resolution. The default example uses camera index 1 at 640x480 and resizes to
the detector's 640x640 input. A PC camera branch can use Image Acquisition
Toolbox `videoinput`/`getsnapshot`, but PC inference or image acquisition alone
cannot be labeled Thor PIL.

## Evidence and limits

The historical Expo R2026b validation matched 55/55 host car/person detections
at IoU>=0.5, with about 0.881-second median PIL round trip and 19.9-second first
PIL initialization. Those are previous source measurements, not current
exercise timing or hardware readiness. Current `demoOutcome` becomes passed
only after the requested camera frames are processed through the actual PIL
gateway and finite/shape checks pass. Validate recognition against independent
labels separately from host/target equivalence.

## Official documentation

- [NVIDIA processor-in-the-loop](https://www.mathworks.com/help/coder/nvidia/ug/Processor-in-the-Loop-Execution-on-NVIDIA-Targets.html)
- [Jetson connection](https://www.mathworks.com/help/coder/nvidia/ref/jetson.html)
- [Target webcam](https://www.mathworks.com/help/coder/nvidia/ref/nvidiaio.image.webcam.html)
- [Snapshot](https://www.mathworks.com/help/coder/nvidia/ref/nvidiaio.image.webcam.snapshot.html)
- [Code-generation context](https://www.mathworks.com/help/coder/nvidia/ref/setupcodegencontext.html)
- [GPU configuration](https://www.mathworks.com/help/gpucoder/ref/coder.gpuconfig.html)
- [YOLOX detector](https://www.mathworks.com/help/vision/ref/yoloxobjectdetector.html)

## French explanation

« La caméra appartient à la carte, mais MATLAB pilote l'expérience. La même
image entre dans le réseau exécuté sur Thor, puis les résultats reviennent pour
l'affichage. C'est un prototype PIL simple. Une application autonome évite ces
allers-retours; ce n'est pas encore ce que nous mesurons ici. »

## Local sample and connection configuration
The included sample_car_frame.jpg is the unannotated first frame from the supplied driving video, for host/PIL testing. The old GPU preview is already annotated and is only historical guidance. The script target address starts empty: set the actual current address, or supply an existingBoard object explicitly. Source IP192.168.7.1 is not a promised current connection. No target IDs or credential values are hardcoded in the runnable script.
