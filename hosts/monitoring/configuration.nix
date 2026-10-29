{ ... }: {
  networking.hostName = "monitoring";
  services.uptime-kuma = { enable = true; settings = { HOST = "127.0.0.1"; PORT = "3001"; }; };
  services.qemuGuest.enable = true;
}
