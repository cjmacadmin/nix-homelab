{ pkgs, ... }:
let isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  home.stateVersion = "25.11";
  home.packages = with pkgs; [ git jq ripgrep fd fzf sops age vim ];
  home.sessionVariables.EDITOR = "vim";
  programs.git = {
    enable = true;
    settings = { init.defaultBranch = "main"; pull.rebase = true; };
  };
  programs.bash = {
    enable = true;
    shellAliases = {
      gs = "git status --short --branch";
      rebuild = if isDarwin then "sudo darwin-rebuild switch --flake ~/nix-homelab#$(hostname -s)" else "sudo nixos-rebuild switch --flake ~/nix-homelab#$(hostname -s)";
    };
  };
  programs.home-manager.enable = true;
}
