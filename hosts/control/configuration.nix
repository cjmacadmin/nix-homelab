{ ... }: {
  networking.hostName = "control";
  # Example control-plane role; configure k3s only after supplying token,
  # networking, storage, backups, and an approved firewall policy.
  # services.k3s = { enable = true; role = "server"; tokenFile = "/run/secrets/k3s-token"; };
}
