{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "tektoncd-cli";
  version = "0.41.1";

  src = fetchFromGitHub {
    owner = "tektoncd";
    repo = "cli";
    rev = "v${version}";
    sha256 = "sha256-AxE7Dom40xL+f2VXz9zlAZYFfW/iCbR9EdHfuCu8z7M=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/tektoncd/cli/pkg/cmd/version.clientVersion=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  subPackages = [ "cmd/tkn" ];

  preCheck = ''
    # some tests try to write to the home dir
    export HOME="$TMPDIR"

    # run all tests
    unset subPackages

    # the tests expect the clientVersion ldflag not to be set
    unset ldflags

    # remove tests with networking
    rm pkg/cmd/version/version_test.go
  '';

  postInstall = ''
    installManPage docs/man/man1/*

    installShellCompletion --cmd tkn \
      --bash <($out/bin/tkn completion bash) \
      --fish <($out/bin/tkn completion fish) \
      --zsh <($out/bin/tkn completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/tkn --help
    $out/bin/tkn version | grep "Client version: ${version}"
    runHook postInstallCheck
  '';

  meta = {
    homepage = "https://tekton.dev";
    changelog = "https://github.com/tektoncd/cli/releases/tag/v${version}";
    description = "Provides a CLI for interacting with Tekton - tkn";
    longDescription = ''
      The Tekton Pipelines cli project provides a CLI for interacting with
      Tekton! For your convenience, it is recommended that you install the
      Tekton CLI, tkn, together with the core component of Tekton, Tekton
      Pipelines.
    '';
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      jk
      mstrangfeld
      vdemeester
    ];
    mainProgram = "tkn";
  };
}
