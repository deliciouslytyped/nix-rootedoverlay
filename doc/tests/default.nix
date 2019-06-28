#TODO implement tests
{ pkgs ? import ../../extern/nixpkgs-pinned.nix }:
  pkgs.stdenv.mkShell {
    buildInputs = [];
    }
