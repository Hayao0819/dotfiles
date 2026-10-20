{
  lib,
  stdenv,
  fetchFromGitHub,
  ghidra,
  gradle,
  jdk,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ghidrust";
  version = "unstable-2024-05-19";

  src = fetchFromGitHub {
    owner = "DMaroo";
    repo = "GhidRust";
    rev = "a4c5ebeee4c7506c29191fc5be9fc0cda9934952";
    hash = "sha256-LKbj1qOeMdiEoe9DTjwHQ6qQUv33ExUReEZ3xEyE7Cw=";
  };

  nativeBuildInputs = [
    gradle
    jdk
    unzip
  ];

  __darwinAllowLocalNetworking = true;

  preBuild = ''
    echo -e '\nrootProject.name = "ghidrust"' >> settings.gradle
    export XDG_CONFIG_HOME="$(mktemp -d)"
  '';

  gradleBuildTask = "buildExtension";
  gradleFlags = [ "-PGHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/ghidra/Ghidra/Extensions
    unzip -d $out/lib/ghidra/Ghidra/Extensions dist/*.zip

    for i in $out/lib/ghidra/Ghidra/Extensions/*; do
      touch "$i/.dbDirLock"
    done

    runHook postInstall
  '';

  meta = {
    description = "Rust binary analysis extension for Ghidra";
    homepage = "https://github.com/DMaroo/GhidRust";
    license = lib.licenses.asl20;
    platforms = ghidra.meta.platforms;
  };
})
