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

    #TODO Alternatively this is overcomplicated and just paste the code in by hand?
    #TODO is there any way to simplify this more
    autoimport2 = path:
      let
        name = n: builtins.elemAt (builtins.split "_" (builtins.baseNameOf n)) 2;
        any = (_: _: true);

        autoimport = n:
          if (pkgs.lib.hasPrefix "autopackages" (name n))
            then (packageImporter n)
            else (import n);

        packageImporter = path: (_: super:
          let
            inherit (pkgs.lib) nameValuePair removeSuffix mapAttrs' mapDirFiles;
            dropSuffix = n: v: nameValuePair (removeSuffix ".nix" n) v;
            importPackage = path: super.callPackage path { inherit super; }; # allows an autoimport to be a patch, should this accept self as well or does the recursion stuff start ending up too tangled? a strict structure is easier to understand.
          in
            mapAttrs' dropSuffix (mapDirFiles importPackage path)
          );
      in
        builtins.attrValues (pkgs.lib.filterMapDir any (n: v: autoimport n) path);

    };

  interface = {
    default = rootf: self: { #TODO document this / that this takes self
      root = rootf self;
      withPackages = withp.cumulative;
      };
    };
  }
