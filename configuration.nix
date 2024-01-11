{ pkgs, ... }: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
    };
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
  nix = {
    settings = {
      trusted-users = [ "root" "@wheel" ];
    };
  };
  system.stateVersion = "23.11";
}
