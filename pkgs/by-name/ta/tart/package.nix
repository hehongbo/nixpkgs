{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  # Softnet support ("--net-softnet") is disabled by default as it requires
  # passwordless-sudo when installed through nix. Alternatively users may install
  # softnet through other means with "setuid"-bit enabled.
  # See https://github.com/cirruslabs/softnet#installing
  enableSoftnet ? false,
  softnet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tart";
  version = "2.28.1";

  src = fetchurl {
    url = "https://github.com/cirruslabs/tart/releases/download/${finalAttrs.version}/tart.tar.gz";
    hash = "sha256-rV5hAJk46e9PAdEo8Qc6/17WqZ9aihj5+A1nLp3fJro=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    # ./tart.app/Contents/MacOS/tart binary is required to be used in order to
    # trick macOS to pick tart.app/Contents/embedded.provision profile for elevated
    # privileges that Tart needs
    mkdir -p $out/bin $out/Applications
    cp -r tart.app $out/Applications/tart.app
    makeWrapper $out/Applications/tart.app/Contents/MacOS/tart $out/bin/tart \
      --prefix PATH : ${lib.makeBinPath (lib.optional enableSoftnet softnet)}
    install -Dm444 LICENSE $out/share/tart/LICENSE

    runHook postInstall
  '';

  meta = with lib; {
    description = "macOS VMs on Apple Silicon to use in CI and other automations";
    homepage = "https://tart.run";
    license = licenses.fairsource09;
    maintainers = with maintainers; [
      emilytrau
      aduh95
    ];
    mainProgram = "tart";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
})
