{ ... }: {
  networking.hostName = "devops";
  # The Forgejo HTTP listener stays on loopback; add private ingress and
  # persistence/backups deliberately. A CI runner is a separate service.
  # example.remoteBuilder.enable = true; # only after provisioning and testing
}
