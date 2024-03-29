{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    virsh-json = {
      url = "github:a-h/virshjson";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xc = {
      url = "github:joerdav/xc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-generators, virsh-json, xc, ... }:
    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages.x86_64-linux = {
        iso = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = [
            # Pin nixpkgs to the flake input, so that nixpkgs#hello comes from the
            # flake inputs.nixpkgs.url.
            ({ ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
            # Use Nix 2.19 instead of 2.18.1.
            ({ ... }: { nix.package = nixpkgs.legacyPackages.x86_64-linux.nixVersions.nix_2_19; })
            # Apply the rest of the config.
            ./configuration.nix
          ];
          format = "qcow";
        };
      };

      # `nix develop` provides a shell containing development tools.
      devShell = forAllSystems ({ system, pkgs }:
        pkgs.mkShell {
          buildInputs = [
            pkgs.jq
            pkgs.libvirt
            pkgs.virt-manager
            xc.packages.${system}.xc
            virsh-json.packages.${system}.default
          ];
        });
    };
}
