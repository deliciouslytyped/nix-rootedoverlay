{callPackage ? (import ./extern/nixpkgs-pinned.nix).callPackage }:
  callPackage ./packages.nix {}
