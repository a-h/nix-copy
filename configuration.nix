{ config, pkgs, ... }: {
  # Enable the OpenSSH server.
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };
  users.users = {
    adrian = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "password";
      packages = [
        pkgs.vim
      ];
    };
  };
  system.stateVersion = "23.11";
}
