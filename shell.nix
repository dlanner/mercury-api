{ mkDerivation, aeson, base, hpack, lib, monad-logger, persistent
, persistent-postgresql, text, yaml, yesod
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
}
