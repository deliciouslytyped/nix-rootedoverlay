# An example showcasing some additional functionality
{mkShell, callPackage}:
let rooted = callPackage ./extern/rooted.nix {};
    inherit (rooted.lib) interface overlays;
in rec {
  myroot = rooted.mkRoot {
    interface = interface.default (self: self.textRoot);
    layers = overlays.autoimport2 ./layers;
    };

  # nix-shell -A example
  # Expected output:
  # ```
  #   I am the root
  #   hello
  #   goodbye
  #   hello again.
  # ```
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
