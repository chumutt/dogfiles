{ inputs, config, lib, pkgs, userSettings, systemSetting, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
      inputs.hyprgrass.packages.${pkgs.system}.default
    ];
    xwayland = { enable = true; };
    systemd.enable = true;
  };
}
