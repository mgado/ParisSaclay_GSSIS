# Expo SOC asset provenance

These assets were supplied by the instructor for local training reuse. They
originate from the Expo Embedded AI with Raspberry Pi reference. Runtime data,
network and model files are copied into this Project; no external source path,
legacy startup script or hardcoded credential is needed.

- `data/projected_quantized_net.mat`: current projected/quantized network.
- `data/quantized_net.mat`: unprojected comparison network, retained for source diagnostics.
- `data/scalers.mat`: training input/output normalization.
- `data/test_data_scaled.mat`: measured raw and scaled XTest/YTest arrays.
- `models/SoC_Target.slx`: adapted wrapper; unused Terminator replaced with
  root SOC Outport for numerical comparison, original source unchanged.
- `models/SoC_LSTM_Projected_Quantized_target.slx`: preserved old target template.
  It does not match the current projected network layer classes; not a passing baseline.
- `models/SoC_LSTM_Projected_Quantized.slx`: matching layer-index candidate,
  saved for host/GRT. Requires current MIL rehearsal and Pi64/ERT target setup.
- `models/main.sldd`, `models/main_LSTM.sldd`: source model design dictionaries.

The reference README states R2026a testing. The old target template failed the
current R2026b host check; this cannot be labeled successful PIL. Current status
and prerequisites are described in PIL_HARDWARE_GUIDE.md. Model backups, build
caches and generated hardware outputs are excluded from the student package.
## Prepared R2026b runtime
The student runtime uses projected_net.mat (socNetProjected) and the true PiSOCAIReference model, prepared from the floating-point source subsystem with a portable network path. Wrapper input wiring is Temperature, Voltage, Current. The obsolete mismatched target, old subsystem templates and incompatible legacy quantized artifact are retained in the development archive rather than shipped as runnable student dependencies. Original Expo reference files remain unchanged.
