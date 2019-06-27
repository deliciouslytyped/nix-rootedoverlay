self: super: {
  lib = {
    gen = super.nixpkgs.lib.concatStringsSep "\n";
    };

  config = {
    iam = "the root";
    };
  }
