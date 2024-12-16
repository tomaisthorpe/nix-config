{
  config,
  ...
}: {

  # Enable OpenGL
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    nvidiaSettings = true;


   package = config.boot.kernelPackages.nvidiaPackages.production; 
  };
}
