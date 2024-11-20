{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    rosepine-build = {
      url = "git+file:///home/julia/projects/2024/rose-pine-build-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      flake-parts,
      rosepine-build,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        {
          config,
          pkgs,
          lib,
          system,
          ...
        }:
        let
          inherit (pkgs) runCommandNoCC writeShellScriptBin;
          inherit (config) packages;
          build = lib.getExe rosepine-build.packages.${system}.default;
        in
        {
          packages.default = runCommandNoCC "generated" { } ''
            ${build} ${./template.css} -o $out
          '';

          devShells.default = pkgs.mkShell {
            packages = [
              (writeShellScriptBin "build" ''
                rm -rf themes
                mkdir themes
                cp ${packages.default}/* themes
              '')
            ];

          };
        };
    };
}
