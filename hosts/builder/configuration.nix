{ pkgs, ... }: {
  networking.hostName = "builder";
  nix.settings = { max-jobs = 4; cores = 8; trusted-users = [ "root" "nixremote" ]; };
  nix.gc = { automatic = true; dates = "daily"; options = "--delete-older-than 7d"; };
  users.users.nixremote = {
    isNormalUser = true;
    description = "Remote Nix builder access";
    openssh.authorizedKeys.keys = [ ];
  };
  environment.systemPackages = with pkgs; [ htop ];
  services.qemuGuest.enable = true;
}
