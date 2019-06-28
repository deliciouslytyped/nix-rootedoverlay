#TODO consider how to do overrides of the very top level definition, such as injecting additional overlays? - shouldnt be necessary though because thats exactly what .extend and such do, unless for some reason youd need to inject something in the middle of the bootstrap??? - which is to say, does .extend let you rewrite the bootstrap?
#TODO: look into makeScope, It might remove some stuff from 0_base
#TODO something something leaky abstractions? -> TODO derive the structure from types
#TODO checkcollider? / "checkcollider isnt that great because you should key by a key to begin with"
#TODO consider moving interfacec to a layer instead of injecting it into base
#TODO !!!??? why does fixp // extender make it look like the extension and the bootstrap are totally unrelated?? if they are, that aint right!?
#TODO i really probably shouldnt need more than one fixpoin / recursion
#TODO optional interface methods?
#TODO does being on the inside or outside of the fixpoint change anything? / can extender be moved into a layer? / 0_base
{pkgs ? import ./extern/nixpkgs-pinned.nix}: 
let
  inherit (pkgs) lib;
  inherit (lib) foldl composeExtensions fix' extends;
  inherit (lib) mapDirFiles;

  # Turn a list of overlays into to a single overlay
  flattenStack = layers: foldl composeExtensions (self: super: {}) layers;

  updateRoot = selector:
    (self: super: { 
      _interface = super._interface // {
        root = super._interface.withPackages super super._interface.root selector;
        };
      });

  base = interface: pkgs.callPackage ./0_base.nix { inherit interface; };

  bootstrap = {layers, interface}:
    let 
      stack = extends (flattenStack layers) (base interface);
    in
      makeExtensible stack;

  # extend injects an overlay at each step and fix caps it off with fix' after a recursive call
  makeExtensible = recset:
    let
      fixp = fix' recset;
    in
      fixp._interface.root // ( # This makes the returned object usable as a derivation #TODO warn if extender has any attributes that will mess up derivations (?)
        # merge the new attributes onto the fix point 
        fixp // (extender recset)
        );

  #how to make these two mutually recursive funcitons actually comprehensible?
  extender = recset: rec {
    extend = overlay:
      let extended = extends overlay recset; #Merge the overlay into the recursive set, return the next fix point after a recursive call
      in makeExtensible extended;
    withPackages = selector: extend (updateRoot selector);
    };


in rec {

  mkRoot = bootstrap;

  #some default implementations
  lib = pkgs.callPackage ./lib.nix {};
  }
