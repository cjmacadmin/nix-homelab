{ host, ... }: {
  networking.hostName = host.name;
  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://control.example.invalid:6443";
    tokenFile = "/run/secrets/k3s-token";
    extraFlags = "--node-label=node-type=worker";
  };
  services.qemuGuest.enable = true;
}
