{ ... }: {
  networking.hostName = "builder";
  # Provide real hardware config, SSH host key, build-only account and trust
  # policy locally before enabling or connecting any clients.
}
