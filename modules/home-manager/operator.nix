{ pkgs, ... }: {
  home.stateVersion = "25.11";
  home.packages = with pkgs; [ git jq ripgrep ];
  programs.git.enable = true;
  programs.bash.enable = true;
}
