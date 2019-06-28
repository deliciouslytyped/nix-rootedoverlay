{pkgs}: rec {
  withp = {
    # for a .withPackages which accumulates plugins
    cumulative = scope: root: selector: root.override (old: { plugins = (old.plugins or []) ++ (selector scope); });
    # for a .withPackages that overrides the plugins to the current argument
    overwrite = scope: root: selector: root.override { plugins = selector scope; }; #TODO check if this overrides /clears the other arguments
    };

  overlays = {
    # Imports all the files in a directory, preferable the files are named 0_... , 1_... , etc
    # Note attrsets are lexically sorted by default
    # TODO maybe this could use a rename
    autoimport = path: builtins.attrValues (pkgs.lib.mapDirFiles import path);
    };

  interface = {
    default = rootf: self: { #TODO document this / that this takes self
      root = rootf self;
      withPackages = withp.cumulative;
      };
    };
  }
