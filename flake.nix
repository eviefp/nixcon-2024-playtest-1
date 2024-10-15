{
  description = "NixCon 2024 - NixOS on garnix: Production-grade hosting as a game";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.05";

  inputs.garnix-lib = {
    url = "github:garnix-io/garnix-lib";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  inputs.purescript-overlay = {
    url = "github:thomashoneyman/purescript-overlay";
  };

  inputs.spago2nix = {
    url = "github:justinwoo/spago2nix";
  };

  outputs =
    inputs@{ nixpkgs
    , garnix-lib
    , ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import "${inputs.nixpkgs}" {
        inherit system;
        overlays = [
          inputs.purescript-overlay.overlays.default
        ];
      };
      backendPackage = pkgs.callPackage ./backend { };
      backend = pkgs.writeShellScriptBin "runBackend" ''
        ${pkgs.lib.getExe pkgs.nodejs} ${backendPackage}/backend.js
      '';
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          inputs.spago2nix.packages."${system}".spago2nix
          nodejs_22
          purs
          spago
          purs-tidy
          purescript-language-server
        ];
      };

      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          garnix-lib.nixosModules.garnix
          ./module.nix
          {
            playerConfig = {
              webserver = backend;
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
