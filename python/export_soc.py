"""Export an exact small synthetic SOC model; requires PyTorch, no download."""
from pathlib import Path
import torch

model = torch.nn.Linear(3, 1).eval()
with torch.no_grad():
    model.weight.copy_(torch.tensor([[1 / 1.2, 0.05 / 1.2, -0.002 / 1.2]]))
    model.bias.copy_(torch.tensor([(-3 + 0.002 * 25) / 1.2]))
example = torch.tensor([[3.55, 1.0, 25.0]])
exported = torch.export.export(model, (example,))
destination = Path(output_path)
destination.parent.mkdir(parents=True, exist_ok=True)
torch.export.save(exported, str(destination))
print({"path": str(destination), "expected_output": model(example).detach().tolist()})
