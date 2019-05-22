#TODO ?change root nomenclature to basePackage?
{pkgs ? import ./lib/nixpkgs-pinned.nix}: 
let
  inherit (pkgs) lib;
in
let
  emptyOverlay = self: super: {};

  # Turn a list of layers into a single layer
  #TODO not sure about foldl or foldr so i just use the neutral element https://stackoverflow.com/questions/47495835/sufficient-conditions-for-foldl-and-foldr-equivalence , should otherwise be associative
  flattenStack = layers: lib.foldl lib.composeExtensions emptyOverlay layers;

  #Apply a layer without tying the knot, so that 0_base doesn't explode until the layer that provides the base package is added #TODO think about whether this could happen again across later layers and how to deal with it
  # base :: self -> Set
  # newStack :: self -> super -> Set
  # applyStack :: base -> newStack -> (self -> Set)
  #TODO you probably want a drawn diagram
  applyLayer = base: newStack: self:
    let
      super = base self;
      self' = newStack self super;
    in
      self';

  getBasePackage = obj: obj._api.root;

  base = api: pkgs.callPackage ./layers/0_base.nix { inherit api; };

  makeExtensible = {layers, api}:
    let
      rattrs = (applyLayer (base api) (flattenStack layers));
/* It's erroring before it even touches this
      #TODO more cleaning
      extension = rattrs: rec {
        
        };
*/
      extension = a: {};
      #TODO once applyLayer works I could probably just fold the stack in instead of doing a flattenstack step.
      #TODO figure out the appropriate side to associate // on.
      result = lib.fix' rattrs // (extension rattrs);
    in
      #make the result set "hang" off the base package. #TODO something something leaky abstractions? -> TODO derive the structure from types
      (getBasePackage result) // result;
    
in
  makeExtensible
