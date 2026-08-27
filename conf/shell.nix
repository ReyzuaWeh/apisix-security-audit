{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    protobuf
    protoc-gen-grpc-web
    protoc-gen-js
    nodejs-slim

    # auto tls
    acme-sh
    curl
  ];

  shellHook = ''
    PROMPT_DIRTRIM=1
    echo "Temporary environment active! Some dependencies may have installed temporary"
  '';
}