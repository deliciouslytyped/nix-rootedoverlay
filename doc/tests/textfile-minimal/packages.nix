# A self contained example, constructing the package set from some slightly structured overlays.
{mkShell, callPackage}:
let

  rooted = callPackage ./lib/rooted.nix {};
  
  utils = self: super: {
    lib = {
      gen = super.nixpkgs.lib.concatStringsSep "\n";
      };

    config = {
      iam = "the root";
      };
    };

  basePackages = self: super: {
    textRoot = 
      super.nixpkgs.makeOverridable ({plugins ? []}:
        super.nixpkgs.writeShellScript "theroot" ''
          cat << EOF
          ${super.lib.gen (["I am ${self.config.iam}"] ++ plugins)}
          EOF
          '') {};
    };

  packages = self: super: {
    hello = "hello";
    goodbye = "goodbye";
    };

in rec {

  myroot = rooted.mkRoot {
  
    interface = self: { #TODO document that this takes the final fixpoint
      root = self.textRoot;
      withPackages = rooted.lib.withp.cumulative;
      };
  
    layers = [ utils basePackages packages ];

    };

  # nix-shell -A example
  example = mkShell {
    shellHook = ''
      exec ${myroot.withPackages (p: with p; [ hello goodbye ])}
      '';
    };
  }

# a minimal example showcasing extended functionality, overlays from files conventions, config with modules
#    layers = map import [
#      ./layers/1_util.nix # functions and stuff
#      ./layers/2_base_packages.nix # The "base" packages, here its textRoot
#      ./layers/3_packages.nix # Plugin packages
#      ];
