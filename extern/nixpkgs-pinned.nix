#TODO enforce sha256
let
  importJSON = path: builtins.fromJSON (builtins.readFile path);
in
  import (builtins.fetchGit (importJSON ./nixpkgs-pinned.json)) { overlays = [
    (import ./to-upstream.nix)
    ];}
