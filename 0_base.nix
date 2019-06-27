{pkgs, lib, interface}:
self: {
  # Don't pollute the namespace (for e.g. tab completion)
  nixpkgs = pkgs;

  # Thus we can take dependencies from both pkgs and our overlay nevertheless.
  # Packages from our set take precedence on collision. #TODO maybe I can solve this somehow. What would an unwanted collision look like?
  callPackage = lib.callPackageWith ( self.nixpkgs // self );

  _interface = interface self; #needs to be extended # api; # root, withpackages
  }
