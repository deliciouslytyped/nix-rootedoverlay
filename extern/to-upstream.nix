(self: super: {                                                                                                                                                                                                                                                           
  lib = super.lib // rec {                                                                                                                                                                                                                                                
  # filterMapDir :  ( String -> String -> Bool )
  #              -> ( Path -> String -> a )
  #              -> Path
  #              -> { Path = a }
  # This maps a function `f` over the entries filtered by `filter` in a directory located at `path`. 
  # It doesn't recurse over subdirectories.
  filterMapDir = filter: f: path:
    #Sets are lexically sorted by key
    let files = builtins.readDir path;
        matches = super.lib.filterAttrs filter files;
    in
      builtins.mapAttrs (n: v: f (path + ("/" + n)) v) matches;

  # mapDirFiles :  ( Path -> a )
  #             -> Path
  #             -> { Path = a }
  # This maps a function `f` over the "regular" files in a directory located at `path`.
  # It doesn't recurse over subdirectories.
  mapDirFiles = f: path:
filterMapDir (n: v: v == "regular") (n: v: f n) path;

    };                                                                                                                                                                                                                                                                    
  }) 
