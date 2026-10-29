{ ... }: {
  # Determinate Nix (or another external installer) owns the Nix daemon.
  nix.enable = false;
  system.primaryUser = "operator";
  users.users.operator.home = "/Users/operator";
  system.stateVersion = 6;
}
