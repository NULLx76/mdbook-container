{
  description = "an container for mdbook with the toc plugin";
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
          default = mdbook-toc;
          container = pkgs.dockerTools.buildLayeredImage {
            name = "mdbook-container";
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
            version = "0.11.0";

            src = pkgs.fetchFromGitHub {
              owner = "badboy";
              repo = pname;
              rev = version;
              sha256 = "sha256-ORJV2+Uh8GwXU+EWUQ2ls+AcplYbpYhl6hvCuFdKpTk=";
            };

            cargoSha256 = "sha256-s+xlrHaynHTMmm7rfjYrWNlIJRHO0QTjMlcV+LjqHNs=";
          };
        };
      });
}
