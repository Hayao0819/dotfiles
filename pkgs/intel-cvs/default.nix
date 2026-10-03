# Intel Vision Services (CVS) kernel module for Lunar Lake cameras
# Required for ov02c10 and other MIPI sensors to be powered on
# Source: https://github.com/intel/vision-drivers
{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation rec {
  pname = "intel-cvs";
  version = "unstable-2025-11-12";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "vision-drivers";
    rev = "a8d772f";
    hash = "sha256-zOvCZKGwOGT9kcJiefzx/duHqR0V8PYhNbqsMHkH1r4=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KERNELRELEASE=${kernel.modDirVersion}"
  ];

  buildPhase = ''
    runHook preBuild
    make $makeFlags all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D intel_cvs.ko \
      $out/lib/modules/${kernel.modDirVersion}/misc/intel_cvs.ko
    runHook postInstall
  '';

  meta = with lib; {
    description = "Intel Computer Vision Services driver for Lunar Lake cameras";
    homepage = "https://github.com/intel/vision-drivers";
    license = licenses.gpl2Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
