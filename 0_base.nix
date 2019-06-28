#TODO using makeScope might make most of this redundant?
{pkgs, lib, interface}:
self: {
  # Don't pollute the namespace (for e.g. tab completion)
  nixpkgs = pkgs;

  # Thus we can take dependencies from both pkgs and our overlay nevertheless.
  # Packages from our set take precedence on collision.
  callPackage = lib.callPackageWith ( self.nixpkgs // self );

  _interface = interface self;
  }
