{ config, lib, ... }:
let cfg = config.example.remoteBuilder;
in {
  options.example.remoteBuilder = {
    enable = lib.mkEnableOption "distributed builds on a separately provisioned Linux builder";
    hostName = lib.mkOption { type = lib.types.str; default = "builder.example.invalid"; };
    sshUser = lib.mkOption { type = lib.types.str; default = "nixremote"; };
    sshKey = lib.mkOption { type = lib.types.str; default = "/etc/nix/builder_ed25519"; };
  };
  config = lib.mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.buildMachines = [{
      inherit (cfg) hostName sshUser sshKey;
      systems = [ "x86_64-linux" ];
      protocol = "ssh-ng";
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = [ ]; # Advertise only features verified on the builder.
    }];
    nix.settings.builders-use-substitutes = true;
  };
}
