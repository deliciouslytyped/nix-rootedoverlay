import (builtins.fetchGit {
  name = "nixos-unstable";
  url = "https://github.com/nixos/nixpkgs/";
  rev = "07b42ccf2de451342982b550657636d891c4ba35";
#  sha256 = "";
}) { overlays = [
  ]; }
