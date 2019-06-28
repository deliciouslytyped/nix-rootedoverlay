#TODO enforce sha256
let
  importJSON = path: builtins.fromJSON (builtins.readFile path);
in
  import (builtins.fetchGit (importJSON ./nixpkgs-pinned.json)) { overlays = [
    (import ./to-upstream.nix)
    ];}

#TODO lazy dirmap in the sense that it only imports files you actually use, and not the whole directory -> probably unsafe stuff
#dirMap = f: dir: builtins.mapAttrs (name: type: ) (builtins.readDir dir)
