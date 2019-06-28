#TODO would probably help to draw a diagram for this stuff...
#TODO consider how to do overrides of the very top level definition, such as injecting additional overlays? - shouldnt be necessary though because thats exactly what .extend and such do, unless for some reason youd need to inject something in the middle of the bootstrap??? - which is to say, does .extend let you rewrite the bootstrap?
#TODO: look into makeScope, It might remove some stuff from 0_base
#TODO something something leaky abstractions? -> TODO derive the structure from types
#TODO checkcollider? (check if plugins collide) / "checkcollider isnt that great because you should key by a key to begin with"
#TODO consider moving interfacec to a layer instead of injecting it into base
#TODO !!!??? why does fixp // extender make it look like the extension and the bootstrap are totally unrelated?? if they are, that aint right!?
#TODO i really probably shouldnt need more than one fixpoin / recursion
#TODO optional interface methods?
#TODO does being on the inside or outside of the fixpoint change anything? / can extender be moved into a layer? / 0_base
#TODO warn if extender has any attributes that will mess up derivations (?) (makeextensible)
#TODO should extender use (/ what would it look like) __unfix__ / would it make it clearer?
{pkgs ? import ./extern/nixpkgs-pinned.nix}: 
let
  inherit (pkgs.lib) foldl composeExtensions fix' extends
                     mapDirFiles;

  # Use the generic internal interface to update the packages applied to the root
  updateRoot = selector:
    (self: super: { 
      _interface = super._interface // {
        root = super._interface.withPackages super super._interface.root selector;
        };
      });

  # The bottom layer of the overlay system.
  # `interface` is stored in 0_base
  # (but it's (self -> Set), so it's only accessible after fix' is used)
  base = interface: pkgs.callPackage ./0_base.nix { inherit interface; };

  # Build the first extensible root
  bootstrap = {layers, interface}:
    let
      # Compose a list of overlays into to a single overlay
      flattenStack = layers: foldl composeExtensions (self: super: {}) layers;

      #Compose everything into a single self-referential set.
      recset = extends (flattenStack layers) (base interface);
    in
      makeExtensible recset;

  makeExtensible = recset:
    let
      fixp = fix' recset;
    in
      fixp._interface.root // ( # This makes the returned object usable as a derivation
        # merge the new attributes onto the fix point. TODO: explain why the attributes are fine being outside the fix point.
        fixp // (extender recset)
        );

  # extend injects an overlay, and ties off the recset - using fix' in the mutually recursive call to makeExtensible
  # So note that makeExtensible returns a fix point, while extend builds on top of the set/function before its fix'ed and then fix'es it through the call to makeExtensible. 
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
