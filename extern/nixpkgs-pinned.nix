#TODO enforce sha256
let
  importJSON = path: builtins.fromJSON (builtins.readFile path);
in
  import (builtins.fetchGit (importJSON ./nixpkgs-pinned.json)) { overlays = [
    #TODO upstream this
    (self: super: {
      lib = super.lib // rec { 
        mapDir = filter: f: path:
          let
            files = super.lib.filterAttrs filter (builtins.readDir path);
          in
            builtins.mapAttrs (n: v: f (path + ("/" + n)) v) files;

        mapDirFiles = f: path:
          mapDir (n: v: v == "regular") (n: v: f n) path; #TODO pretty sure theres a map filter like tihs somewhere in lib

        mapDirFilesRec = null; #TODO composable mapdirs and mapdirfiles?
        };
      })
    ];}

#TODO lazy dirmap in the sense that it only imports files you actually use, and not the whole directory -> probably unsafe stuff
#dirMap = f: dir: builtins.mapAttrs (name: type: ) (builtins.readDir dir)
