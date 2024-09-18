{ pkgs, ... }: {
  # OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ rocmPackages.clr.icd ];
  };
}
