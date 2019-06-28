# An example showcasing some additional functionality
{mkShell, callPackage}:
let rooted = callPackage ./extern/rooted.nix {};  
in rec {
  myroot = rooted.mkRoot {
    interface = rooted.lib.interface.default (self: self.textRoot);
    layers = rooted.lib.overlays.autoimport ./layers;
    };

  # nix-shell -A example
  example = mkShell {
    shellHook = ''
      exec ${
        ((
        myroot
          .withPackages (p: with p; [ hello goodbye ]) )
          .extend (self: super: { again = "hello again."; }) )
          .withPackages (p: [ p.again ])
        }
      '';
    };
  }
