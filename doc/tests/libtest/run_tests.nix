{testlib ? let pkgs = import <nixpkgs> {}; in pkgs.callPackage ../../../extern/nix-expr-testlib/testlib.nix {}}:
let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  inherit (testlib) drvSetEq;
in
with (pkgs.callPackage ./prereqs_tests.nix {});
#TODO separate tests and test data
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

    interfaceSet = (root._interface.withPackages != null) && (root._interface.root != null);
    #TODO test bootstrap phases separately (check _interface NOT set?)

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
    wPFunctionality =
      let
        a = root.withPackages (p: [ p.testPackageA ]);
        #TODO withMorePackages
        b = a.withPackages (p: [ p.testPackageB ]);
      in
        #Well, this works as long as theyre strings
        (builtins.readFile b) == (lib.concatStringsSep "\n" (with (packageSet {} {}); [ testPackageA testPackageB ])) + "\n";

    # extend works

    # wPwPFunctionality #Test needs at least two plugins
    # exExFunctionality
    # exwPExwPFunctionality

    # overridableCore

    #TODO checking internal version consistency

#    root.withPackages (p: ["a"])

    };
    ignore = [ "exwPexwPAttr" "wPwPAttr" ]; #TODO failing tests
in {
  inherit tests root;
  #TODO accessing actuall test returned objects is a pain in the butt
  result = builtins.trace (testlib.runAll (tests root) ignore) null;
  }
