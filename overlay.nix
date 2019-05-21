# Construct the package set from some ad-hoc / slightly structured layers.
{layers, api, pkgs ? import ./lib/nixpkgs-pinned.nix}: #TODO no default
#TODO alternative: makeRoot -> f_withPackages -> tree
let
  inherit (pkgs) callPackage lib;

  initstack = lib.foldl lib.composeExtensions (builtins.head layers) (builtins.tail layers);

  makeExtensible = rattrs:
    let #TODO think over this, seems evil
      result = lib.fix' (let self = self': initstack self' super; super = rattrs self; in self) // rec {
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
      (builtins.trace (builtins.removeAttrs result [ "nixpkgs" ]) result)._api.root // result;
in
let
  baseLayer = ./layers/0_base.nix;
in
  makeExtensible (callPackage baseLayer { inherit api; }) initstack
