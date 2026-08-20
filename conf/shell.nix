{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.protobuf
    pkgs.protoc-gen-grpc-web
    pkgs.protoc-gen-js
    pkgs.nodejs-slim
  ];

  shellHook = ''
    PROMPT_DIRTRIM=1
    echo "Temporary environment active! Some dependencies may have installed temporary"
  '';
}