{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          docker = pkgs.dockerTools.buildLayeredImage {
            name = "mdbook-plus";
            contents = [
              (pkgs.buildEnv {
                name = "mdbook-env";
                paths = with pkgs; [ busybox mdbook mdbook-toc ];
              })
            ];
            config.Cmd = [ "${pkgs.mdbook}/bin/mdbook" ];
          };
          mdbook-toc = pkgs.rustPlatform.buildRustPackage rec {
            pname = "mdbook-toc";
            version = "0.10.0";

            src = pkgs.fetchFromGitHub {
              owner = "badboy";
              repo = pname;
              rev = version;
              sha256 = "sha256-/MPxuzqgWKyLP1fn/WoA2cKlV0TiVidt+YpNqY96sxE=";
            };

            cargoSha256 = "sha256-JFqkeea6o5Wzpe+2Fp+UYjBOh/e3vX1pZzCfxxfAYmU=";
          };
        };
      });
}
