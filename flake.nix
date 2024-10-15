{
  description = "NixCon 2024 - NixOS on garnix: Production-grade hosting as a game";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.garnix-lib = {
    url = "github:garnix-io/garnix-lib";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , garnix-lib
    , ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          garnix-lib.nixosModules.garnix
          ./module.nix
          {
            playerConfig = {
              webserver = (import nixpkgs { inherit system; }).hello;
              githubLogin = "eviefp";
              githubRepo = "nixcon-2024-playtest-1";
              sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBLUMCHFgEo647k0NSAzVybQLndXxPdVyOaN4ua9DF2 me@eevie.ro";
            };
          }
        ];
      };

      # checks = import ./checks.nix { inherit nixpkgs self; };
    };
}
