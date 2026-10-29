{ lib, host, ... }:
let is = role: host.role == role;
in {
  # Role configuration intentionally stops short of provisioning credentials,
  # cluster networking, TLS, persistence, or public ingress.
  services.k3s.enable = lib.mkDefault false;
  services.forgejo = lib.mkIf (is "devops") {
    enable = true;
    database.type = "sqlite3";
    settings.server.HTTP_ADDR = "127.0.0.1";
    settings.service.DISABLE_REGISTRATION = true;
  };
  services.uptime-kuma = lib.mkIf (is "monitoring") {
    enable = true;
    settings.HOST = "127.0.0.1";
  };
  # Dedicated Linux builder: receiving daemon is privileged, not a sandbox.
  nix.settings.max-jobs = lib.mkIf (is "builder") 4;
  nix.settings.cores = lib.mkIf (is "builder") 8;
  nix.gc = lib.mkIf (is "builder") { automatic = true; dates = "daily"; options = "--delete-older-than 7d"; };
}
