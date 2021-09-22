{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, aeson, base, hpack, lib, monad-logger
      , persistent, persistent-postgresql, text, yaml, yesod
      }:
      mkDerivation {
        pname = "api";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [
          aeson base monad-logger persistent persistent-postgresql text yaml
          yesod
        ];
        libraryToolDepends = [ hpack ];
        executableHaskellDepends = [
          aeson base monad-logger persistent persistent-postgresql text yaml
          yesod
        ];
        testHaskellDepends = [
          aeson base monad-logger persistent persistent-postgresql text yaml
          yesod
        ];
        prePatch = "hpack";
        homepage = "https://github.com/dlanner/mercury-api#readme";
        license = lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
