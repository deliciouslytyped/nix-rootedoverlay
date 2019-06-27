self: super:
  super.nixpkgs.lib.mapDirFiles (path: super.callPackage path {}) ./4_packages
