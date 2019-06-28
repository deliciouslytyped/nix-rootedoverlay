{pkgs}: rec {
  withp = {
    cumulative = scope: root: selector: root.override (old: { plugins = (old.plugins or []) ++ (selector scope); });
    overwrite = scope: root: selector: root.override { plugins = selector scope; }; #TODO check if this overrides /clears the other arguments
    };

  overlays = {
    #Note attrsets are lexically sorted by default
    autoimport = path: builtins.attrValues (pkgs.lib.mapDirFiles import path);
    };

  interface = {
    default = rootf: self: { #TODO document that this takes self
      root = rootf self;
      withPackages = withp.cumulative;
      };
    };
  }
