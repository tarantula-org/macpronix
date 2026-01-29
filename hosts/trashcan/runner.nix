{ pkgs, pkgs-unstable, ... }:

{
  services.github-runners = {
    trashcan-worker = {
      enable = true;
      
      # [DYNAMIC] This line is managed by the macpronix CLI
      url = "https://github.com/tarantula-org";
      
      tokenFile = "/etc/secrets/github-runner-token";
      replace = true;
      package = pkgs-unstable.github-runner;
      extraPackages = with pkgs; [ git docker nodejs ];
    };
  };
}