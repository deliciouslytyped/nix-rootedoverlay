# A self contained example
{mkShell, callPackage}:
let rooted = callPackage ./extern/rooted.nix {}; in
let  

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
  
    interface = self: {
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
