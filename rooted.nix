#TODO checkcollider? / "checkcollider isnt that great because you should key by a key to begin with"
#TODO ?change root nomenclature to basePackage?
{pkgs ? import ./extern/nixpkgs-pinned.nix}: 
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
  applyLayer = base: newStack: self: #TODO why do i need both applylayer and flattenstack
    let
      super = base self;
      next = newStack self super;
    in
      super // next; #TODO is this correct

  getBasePackage = obj: obj._interface.root;

  base = interface: pkgs.callPackage ./0_base.nix { inherit interface; };

  bootstrap = {layers, interface}: (applyLayer (base interface) (flattenStack layers)); #TODO pass as first argument to makeextensible

  makeExtensible = rattrs:
    let
      #TODO more cleaning
      extension = rattrs: rec {
        #TODO makeExtensible has wrong signature
        extend = overlay: makeExtensible (lib.extends overlay rattrs); #TODO is lib.extends the correct semantics for this? should be fine since we shouldnt have the bootstrap problem anymore...
        withPackages = selector:
          extend (self: super: { #TODO why is this in _interface, why isnt is just part of the overlay?? #TODO what about optional implementation of methods
            _interface = super._interface // {
              root = super._interface.withPackages super super._interface.root selector;
              };
            });
        };
      #TODO once applyLayer works I could probably just fold the stack in instead of doing a flattenstack step.
      #TODO figure out the appropriate side to associate // on.
      result = lib.fix' rattrs // (extension rattrs);
    in
      #make the result set "hang" off the base package. #TODO something something leaky abstractions? -> TODO derive the structure from types
      (getBasePackage result) // result;
    
in rec {
  mkRoot = {layers, interface}@args: makeExtensible (bootstrap args);

  lib = {
    #some default implementations

    withp = {
      cumulative = scope: root: selector: root.override (old: { plugins = (old.plugins or []) ++ (selector scope); });
      overwrite = scope: root: selector: root.override { plugins = selector scope; }; #TODO check if this overrides /clears the other arguments
      };

    overlays = {
    ##TODO sorted mapdirs? - or mapdirs iterates in lexical order? - make a high level and a low level mapdir
      #TODO unfuck this, todo sort
      autoimport = path: builtins.attrValues (pkgs.lib.mapDirFiles import path);
      };

    interface = {
      default = rootf: self: { #TODO document that this takes the final fixpoint
        root = rootf self;
        withPackages = lib.withp.cumulative;
        };
      };
    };
  }
