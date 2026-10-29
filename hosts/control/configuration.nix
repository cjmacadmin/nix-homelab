{ ... }: {
  networking.hostName = "control";
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    tokenFile = "/run/secrets/k3s-token";
    extraFlags = "--disable=traefik --disable=servicelb --node-taint=CriticalAddonsOnly=true:NoExecute";
  };
  services.qemuGuest.enable = true;
}
