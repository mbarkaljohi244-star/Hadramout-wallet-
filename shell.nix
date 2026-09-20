{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [
    pkgs.flutter
    pkgs.android-tools
    pkgs.jdk17
  ];
}
