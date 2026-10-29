{ pkgs, ... }: {
  networking.hostName = "devops";
  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    settings = {
      server = { HTTP_ADDR = "127.0.0.1"; HTTP_PORT = 3000; DOMAIN = "git.example.invalid"; ROOT_URL = "https://git.example.invalid/"; };
      service.DISABLE_REGISTRATION = true;
    };
  };
  services.qemuGuest.enable = true;
  environment.systemPackages = with pkgs; [ sqlite ];
}
