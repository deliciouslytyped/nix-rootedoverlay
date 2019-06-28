WARNING: ~~very~~ less broken right now
need more tests
TODO: just ran into a case with gotools where a name collision led to a "hard" to understand problem. my conclusion is withPlugins should not by default accept arbitrary thing (without some explicit wrapper or something)
TODO: when to use this over normal overlays with lib.makeExtensible
TODO: document / make true: .withPackages defaults to being cumulative, can be cleared/overridden with ...? TODO: make this visible somehow ($name? that would end up being  pretty verbose though),

An overcomplicated (simplification pending) sub-packageset overlay system that does everything (...or something...I've been iterating on and breaking this for too long, someone save me...).

Inspired by: `python.withPackages (p: with p; [ ... ])` (without having looked at the implementation yet...)
Made possible by: `makeExtensible` and then massively cannibalized

Terminology:
- If you have an application that takes plugins, I call the application the `root` (and the plugins are the leaves of the tree)
- This library is henceforth ominously referred to as `the system`
#TODO think about this more
- A function (p: [ ... ]) :: List -> List is called a `selector`.
  Note that nothing prevents a Nix selector from including items not part of the original `p`. 
- An attrset that is also a derivation is referred to as an `attrSetDrv`. In practice this means that a derivation has had additional attributes merged into it 
with `//`. #TODO find a better name

API on the attrSetDrv returned by the system:
An attribute starting with a `.` is to be understood as hanging off the top level `root`, or the parent item above it in this list:
- `.extend` behaves similar to `.extend` from `makeExtensible`, namely: applying overlays. Returns a new attrSetDrv.
- `.withPackages` - provides the user-facing `withPackages` function. Returns a new attrSetDrv.
- `.nixpkgs` - a reference to the `nixpkgs` parameter passed to the system. This idea is to prevent cluttering up our own package set's name scope. (so far just for ergonomics reasons.)
- `._api` - a carrier for things the system needs to fulfill it's functionality. This is the attrset passed to the system on initialization.
  - `.withPackages` - provides the system-facing `withPackages` implementation, containing the code that knows how to attach plugins or whatever to the `root`.
  - `.root` - the derivation that's meant to consume the plugins.

Every `.extend` or `.withPackages` call's result is "rooted" - in the sense that there is a derivation designated as the "root" of the tree, and you will always get 
an attrSetDrv with the utility attributes hanging off of it as the result. This means that both `root` and `root.withPackages (p: with p; [ something ])` are 
derivations that can be evaluated. This is primarily a convenience feature in normal use, but also allows importing an existing configuration into another package 
set, while still letting you override it.

Creating your own package set:
TL;DR: pass some `layers`, and `api` with a `.root` and a `.withPackages` taking `scope: root: selector:`, to overlay.nix.

TODO: this is wrong now
Currently, constructing a package set is done in two phases.
In the first, overlays are used to construct the core of the package set from several layers.
In the second step, the core is wrapped to provide the utility functions exposed in the api. #TODO test that core stuff can be properly overridden from the second stage
#TODO not sure if this is quite correct, need to check
The bootstrap step is necessary because `_api.root` is referenced by ...
#TODO rephrase, expand section so people other than me know what I mean
- The bootstrap overlay system (the root must be fed into the rooted generator)
- The final overlay system

Example `withPackages` implementations:
  non-cumulative overrides:
    `withPackages = scope: root: selector: root.override { plugins = (selector scope); };`
  cumulative overrides:
    `withPackages = scope: root: selector: root.override (old: { plugins = (old.plugins or []) ++ (selector scope); });`
TODO/NOTE: additional system support _may_ be added for this with e.g. a withMorePackages or somesuch.


---------------------


Other todo (in rough order of importance):
 - proper tests, tests depend on https://github.com/deliciouslytyped/nix-expr-testlib/ in extern/ use a submodule
 - simplify the code
 - have ".ownpackages" so thats not cluttered by noise either
 - test parametrization over roots
 - decide what to do with passing external things into selectors
 - write an article from my old attempt at deriving these systems,
   hopefully remembering enough about how I got where I am at this point and why
   (don't forget about: the extends root mess, ...?)



"Implementation of the framework" walkthrough:
TODO

MISC:

#TODO move to other repo: "for a more extensive usage example see ..., for an embedded usage example see ..."
The layering (and other directory layout) convention
layers/
  0_base.nix
  1_util.nix
  2_packages.nix
  3_packages/
lib/
  nixpkgs-pinned.nix
  extern/

#########################again
fix:
  A function (p: [ ... ]) :: List -> List is called a selector. Note that nothing prevents a Nix selector from including items not part of the original p.
  Set -> List


`type Selector :: AttrSet -> [ Drv ]`
?? wtf, lazy data types are actually implicit functions?? `type Overlay :: self : AttrSet -> super : AttrSet -> AttrSet`
`root`
- `.extend :: Overlay -> AttrSetDrv`
- `.WithPackages :: Selector -> AttrSetDrv`
- `.nixpkgs :: AttrSet`
- `._api :: AttrSet`
  - `.withPackages :: scope : AttrSet -> root : Root -> selector : Selector -> AttrSetDrv`
  - `.root :: Drv`

root !could have any type because ._api.withPackages should be the only thing that actually tries to access it (?), but normally it would be an overridable derivation taking plugins as an argument
but actually its a Drv because you want the root to be able to evaluate
...can rot have an arbitrary type? can you treat a string as a set?


TODO 
consider using module system for merging (evalmodules)
  <tv> pie_: https://cgit.krebsco.de/stockholm/tree/krebs/5pkgs/simple/flameshot-once/default.nix
  <tv> pie_: https://cgit.krebsco.de/stockholm/tree/krebs/5pkgs/simple/flameshot-once/profile.nix
