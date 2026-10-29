{ pkgs, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.firewall.enable = true;
  # Opening management interfaces requires an explicit network and firewall policy.
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = { PasswordAuthentication = false; KbdInteractiveAuthentication = false; PermitRootLogin = "no"; };
  };
  services.tailscale.enable = true;
  users.users.operator = {
    isNormalUser = true;
    description = "Infrastructure operator";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ ];
  };
  time.timeZone = "Etc/UTC";
  environment.systemPackages = with pkgs; [ git vim curl jq ];
  system.stateVersion = "25.11";
  # Evaluation fixture only. Replace with generated host hardware configuration.
  boot.loader.grub.enable = false;
  fileSystems."/" = { device = "/dev/disk/by-label/REPLACE_ME"; fsType = "ext4"; };
}
