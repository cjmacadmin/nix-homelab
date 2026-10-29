# Example inventory, not a record of real hosts or addresses.
{
  nixos = {
    builder = { system = "x86_64-linux"; role = "builder"; };
    control = { system = "x86_64-linux"; role = "control"; };
    worker = { system = "x86_64-linux"; role = "worker"; };
    worker-2 = { system = "x86_64-linux"; role = "worker"; };
    worker-3 = { system = "x86_64-linux"; role = "worker"; };
    devops = { system = "x86_64-linux"; role = "devops"; };
    monitoring = { system = "x86_64-linux"; role = "monitoring"; };
  };
  darwin = {
    laptop = { system = "aarch64-darwin"; role = "workstation"; };
  };
}
