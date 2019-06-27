# An example, constructing the package set from some slightly structured overlays.
# a minimal example showcasing extended functionality, overlays from files conventions, config with modules
{mkShell, callPackage}:
let
  rooted = callPackage ./extern/rooted.nix {};  
in rec {
  myroot = rooted.mkRoot {
    interface = rooted.lib.interface.default (self: self.textRoot);
    layers = rooted.lib.overlays.autoimport ./layers;
    };

  # nix-shell -A example
  example = mkShell {
    shellHook = ''
      exec ${myroot.withPackages (p: with p; [ hello goodbye ])}
      '';
    };
  }
