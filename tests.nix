{testlib ? let pkgs = import <nixpkgs> {}; in pkgs.callPackage ./extern/nix-expr-testlib/testlib.nix {}}:
let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  inherit (testlib) drvSetEq;
in

#Setup
let
  packageSet = (self: super: {
    testPackageA = "a winner is you";
    });

  emptyOverlay = (self: super: {});

  api = self: {
    root = lib.makeOverridable ({ plugins ? [] }@args: pkgs.hello // args ) {};
    withPackages = scope: root: selector: root.override { plugins = (selector scope); };
    };

  root = import ./overlay.nix { inherit api; layers = [ packageSet ]; };
  testOverlay = (self: super: { wat = 1; });
in

#Tests
let
  inherit (lib) isDerivation;
  tests = root: {
    isRootDrv = isDerivation root;
    isWithPDrv = isDerivation (root.withPackages (p: []));
    isExtendDrv = isDerivation (root.extend emptyOverlay);

    nixpkgsSet = builtins.hasAttr "nixpkgs" root;
    usableNixpkgs = builtins.hasAttr "callPackage" root.nixpkgs;
    hangingLeaves = builtins.hasAttr "testPackageA" root;

    apiSet = (root._api.withPackages != null) && (root._api.root != null);
    #TODO test bootstrap phases separately (check _api NOT set?)

    #This test is kind of pointless because drvSetEq can't test equality of functions.
    extendableExtendAttr = drvSetEq ((root.extend emptyOverlay).extend emptyOverlay) root;
    wPwPAttr = drvSetEq ((root.withPackages (p: [])).withPackages (p: [])) root;
    exwPexwPAttr =
      let
        a = root.extend emptyOverlay;
        b = a.withPackages (p: []);
        c = b.extend emptyOverlay;
        d = c.withPackages (p: []);
      in
        drvSetEq d root;

    # withPackages works
    # extend works

    # wPwPFunctionality
    # exExFunctionality
    # exwPExwPFunctionality

    # overridableCore

    #TODO checking internal version consistency

    };
    ignore = [ "exwPexwPAttr" "wPwPAttr" ]; #TODO failing tests
in {
  inherit tests root;
  result = builtins.trace (testlib.runAll (tests root) ignore) null;
  }
