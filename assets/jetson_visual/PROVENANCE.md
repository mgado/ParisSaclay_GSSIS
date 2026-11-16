# Jetson visual asset provenance

- `cocoSmallYOLO.mat`: supplied trained YOLOX detector from the instructor's
  Expo object-detection reference, unchanged copy (33,659,407 bytes).
- `src/cocoSmallYOLO.m`: original small source entry function, unchanged copy.
- `LICENSE_MATHWORKS.txt`: original MathWorks license, retained with source/model.
- `expo_gpu_preview.png`: historical Expo GPU PIL frame1 illustration; not a
  current execution result or independent ground-truth accuracy label.

The existing gateway/generated-source tree is not shipped as a portable runtime
without qualification. Source and model remain Project-owned; a new build is
needed when path/configuration changes invalidate reuse. Old source performance
and saved screenshots are never reported as current hardware readiness.
- sample_car_frame.jpg: first unannotated MJPEG video frame extracted without pixel changes from the supplied amalfiDrive.avi. It is suitable for host/PIL detector checks, unlike the annotated historical preview. The original video is unchanged.
