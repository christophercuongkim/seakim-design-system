{
  description = "SeaKim Design System — reproducible developer shell for Flutter/Dart work";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.flutter
            pkgs.git
          ];

          shellHook = ''
            echo "=============================================="
            echo " SeaKim Design System — Flutter dev shell"
            echo "----------------------------------------------"
            echo -n " flutter: "; flutter --version 2>/dev/null | head -n1
            echo -n " dart:    "; dart --version 2>&1 | head -n1
            echo "=============================================="
          '';
        };
      });
}
