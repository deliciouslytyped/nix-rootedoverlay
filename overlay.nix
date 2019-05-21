# Construct the package set from some ad-hoc / slightly structured layers.
{layers, api, pkgs ? import ./lib/nixpkgs-pinned.nix}: #TODO no default
#TODO alternative: makeRoot -> f_withPackages -> tree
let
  inherit (pkgs) callPackage lib;
#TODO cant use ${extenderName} in a rec on the right side
#  extenderName = "extend";

  #Two stage overlay setup. First stage makes _api.root exist, second stage starts returning the full structure.
  makeExtensibleBootstrap = lib.makeExtensible;

  makeExtensible = rattrs:
    let #TODO think over this, seems evil
      result = lib.fix' rattrs // rec {
        extend = overlay: makeExtensible (lib.extends overlay rattrs);
        #TODO: accumulator + withMorePackages
        withPackages = selector: extend (self: super: { #TODO WARN NOTE: laziness means errors here could be delayed till much later, which can be confusing
          _api = super._api // {
            root = super._api.withPackages super super._api.root selector; #TODO check the self on this
            currentPackages = selector super; #TODO this is wrong as it stands currently, it only shows the last withP but there could be implicit packages in the mutated root
            };
          });
        };
    in
      result._api.root // result;
in
let
  baseLayer = ./layers/0_base.nix;
#  mkBase = makeExtensible (callPackage baseLayer { inherit api; });
  mkBase = makeExtensibleBootstrap (callPackage baseLayer { inherit api; });
  extend = layer: layer.extend;

  bootstrap = lib.foldl extend mkBase layers;
in
  makeExtensible (self: bootstrap) #TODO how to turn it inside-out
