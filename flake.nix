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
          jq
          unzip
          wget
        ];
        mozid-script = pkgs.writeShellScriptBin mozid-name (builtins.readFile ./mozid.sh);

        firefox-base = "https://addons.mozilla.org/firefox/downloads/file";
        thunderbird-base = "https://addons.thunderbird.net/thunderbird/downloads/latest";
      in
      rec {
        defaultPackage = packages.mozid;
        packages.mozid = pkgs.symlinkJoin {
          name = mozid-name;
          paths = [ mozid-script ] ++ mozid-dependencies;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${mozid-name} --prefix PATH : $out/bin";
        };

        lib =
          let
            mozid =
              base: extension:
              ''${pkgs.runCommand "lib${mozid-name}" {
                buildInputs = mozid-dependencies;
                env = {
                  inherit base extension;
                };
              } "${mozid-script}/bin/${mozid-name} @$base @$extension > $out"}'';
          in
          {
            inherit mozid;
            mozid-firefox = mozid firefox-base;
            mozid-thunderbird = mozid thunderbird-base;
          };

        devShells.default = pkgs.mkShell { buildInputs = mozid-dependencies; };
      }
    );
}
