self: super:
let
  lib = super.nixpkgs.lib;
  dropSuffix = n: v: lib.nameValuePair (lib.removeSuffix ".nix" n) v;
  importPackage = path: super.callPackage path {};
in
  lib.mapAttrs' dropSuffix (lib.mapDirFiles importPackage ./4_packages)
