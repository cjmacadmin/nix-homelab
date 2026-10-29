{ lib, host, pkgs, ... }:
{
  # Cluster nodes share operator tools; service specifics live with each host.
  environment.systemPackages = lib.optionals (builtins.elem host.role [ "control" "worker" ]) (with pkgs; [ kubectl kubernetes-helm k9s ]);
}
