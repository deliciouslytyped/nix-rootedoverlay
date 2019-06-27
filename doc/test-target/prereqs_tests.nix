{lib, runCommand}: rec {
  packageSet = (self: super: {
    testPackageA = "a winner is you";
    testPackageB = "wololo";
    });

  emptyOverlay = (self: super: {});

  mockRoot = { plugins ? [] }: runCommand "mockRoot" {} ''
      cat > $out <<END
      ${lib.concatStringsSep "\n" plugins}
      END
      '';

  api = self: {
    root = lib.makeOverridable mockRoot {};
    withPackages = scope: root: selector: root.override (a: { plugins = (a.plugins or []) ++ (selector scope); });
    #TODO override per discussion with joepie
    };

  root = (import ../../overlay.nix {}) { inherit api; layers = [ packageSet ]; };
  testOverlay = (self: super: { wat = 1; });
}
