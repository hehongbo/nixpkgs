{
  stdenv,
  fetchFromGitHub,
  lib,
  rustPlatform,
  curl,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "snarkos";
  version = "2.2.7";

  src = fetchFromGitHub {
    owner = "AleoHQ";
    repo = "snarkOS";
    rev = "v${version}";
    sha256 = "sha256-+z9dgg5HdR+Gomug03gI1zdCU6t4SBHkl1Pxoq69wrc=";
  };

  cargoHash = "sha256-riUOxmuXDP5+BPSPu5+cLBP43bZxAqvVG/k5kvThSAs=";

  # buildAndTestSubdir = "cli";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    rustPlatform.bindgenHook
  ];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  OPENSSL_DIR = "${lib.getDev openssl}";

  # TODO check why rust compilation fails by including the rocksdb from nixpkgs
  # Used by build.rs in the rocksdb-sys crate. If we don't set these, it would
  # try to build RocksDB from source.
  # ROCKSDB_INCLUDE_DIR="${rocksdb}/include";
  # ROCKSDB_LIB_DIR="${rocksdb}/lib";

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    curl
  ];

  # some tests are flaky and some need network access
  # TODO finish filtering the tests to enable them
  doCheck = !stdenv.hostPlatform.isLinux;
  # checkFlags = [
  #   # tries to make a network access
  #   "--skip=rpc::rpc::tests::test_send_transaction_large"
  #   # flaky test
  #   "--skip=helpers::block_requests::tests::test_block_requests_case_2ca"
  # ];

  meta = with lib; {
    description = "Decentralized Operating System for Zero-Knowledge Applications";
    homepage = "https://snarkos.org";
    license = licenses.asl20;
    maintainers = with maintainers; [ happysalada ];
    platforms = platforms.unix;
    mainProgram = "snarkos";
  };
}
