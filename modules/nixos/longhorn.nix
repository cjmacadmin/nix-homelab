{ config, lib, pkgs, host, ... }:
{
  # Host-side prerequisites; Longhorn itself is installed into Kubernetes.
  config = lib.mkIf (builtins.elem host.role [ "control" "worker" ]) {
    services.openiscsi = {
      enable = true;
      name = "iqn.2026-01.invalid.example:${config.networking.hostName}";
    };
    boot.supportedFilesystems = [ "nfs" ];
    boot.kernelModules = [ "iscsi_tcp" ];
    environment.systemPackages = with pkgs; [ nfs-utils openiscsi lsscsi sg3_utils util-linux e2fsprogs ];
    systemd.tmpfiles.rules = [
      "d /var/lib/longhorn 0755 root root -"
      "L+ /usr/local/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
    ];
  };
}
