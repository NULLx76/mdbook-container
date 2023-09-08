{
  description = "an container for mdbook with various plugins";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let inherit (flake-utils.lib) eachSystem system;
    in eachSystem [ system.x86_64-linux ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = container;
          container = pkgs.dockerTools.buildLayeredImage {
            name = "mdbook-container";
            tag = "0.4.0";
            contents = [
              (pkgs.buildEnv {
                name = "mdbook-env";
                paths = with pkgs; [ busybox mdbook mdbook-toc mdbook-katex ];
              })
            ];
            config.Cmd = [ "${pkgs.mdbook}/bin/mdbook" ];
          };
          mdbook-toc = pkgs.rustPlatform.buildRustPackage rec {
            pname = "mdbook-toc";
            version = "0.14.1";

            src = pkgs.fetchFromGitHub {
              owner = "badboy";
              repo = pname;
              rev = version;
              sha256 = "sha256-F0dIqtDEOVUXlWhmXKPOaJTEuA3Tl3h0vaEu7VsBo7s=";
            };

            cargoSha256 = "sha256-gbBX6Hj+271BA9FWmkZdyR0tMP2Lny7UgW0o+kZe9bU=";
          };
        };
      });
}
