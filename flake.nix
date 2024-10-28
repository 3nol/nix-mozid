{
  description = "Nix functions for retrieving Mozilla add-on IDs.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        mozid-name = "mozid";
        mozid-dependencies = with pkgs; [
          curl
          gnugrep
          unzip
        ];
        mozid-package = pkgs.symlinkJoin {
          name = mozid-name;
          paths = [
            (pkgs.writeShellScriptBin mozid-name (builtins.readFile ./mozid.sh))
          ] ++ mozid-dependencies;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${mozid-name} --prefix PATH : $out/bin";
        };
        mozid-wrapper =
          name: arg:
          let
            mozid-name-name = "${mozid-name}-${name}";
          in
          builtins.toString (
            pkgs.writeShellScriptBin mozid-name-name ''
              ${mozid-package}/bin/${mozid-name} ${arg} $@
            ''
          )
          + "/bin/"
          + mozid-name-name;
      in
      {
        # Publish script with dependencies as package.
        packages.mozid = mozid-package;

        # For every default '$base_url' created a wrapped derivation as app.
        apps = {
          mozid-firefox = {
            type = "app";
            program = mozid-wrapper "firefox" "https://addons.mozilla.org/firefox/downloads/file";
          };
          mozid-thunderbird = {
            type = "app";
            program = mozid-wrapper "thunderbird" "https://addons.thunderbird.net/thunderbird/downloads/latest";
          };
        };

        # Just for fun, made it into a non-functional library function (because of sandbox).
        lib.mozid =
          base: extension:
          builtins.readFile ''${pkgs.runCommand "lib${mozid-name}" {
            buildInputs = mozid-dependencies;
            env = {
              inherit base extension;
            };
          } "echo -n `${mozid-package}/bin/${mozid-name} @$base @$extension` > $out"}'';

        # For developing the 'mozid.sh' script.
        devShells.default = pkgs.mkShell { buildInputs = mozid-dependencies; };
      }
    );
}
