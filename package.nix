{
  lib,
  stdenv,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  esbuild,
  nwjs,
}:

stdenv.mkDerivation {
  pname = "lycosa";
  version = "0.1.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src/icon.png
      ./src/package.json
      ./src/zoom.ts
    ];
  };
  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    esbuild
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "lycosa";
      desktopName = "Lycosa";
      comment = "Configure the AULA HERO 84 HE keyboard";
      exec = "lycosa";
      icon = "lycosa";
      categories = [ "Utility" ];
    })
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/lycosa $out/bin

    cp -r src/package.json src/icon.png $out/share/lycosa/
    esbuild src/zoom.ts --bundle --format=iife --outfile=$out/share/lycosa/zoom.js

    install -Dm644 src/icon.png $out/share/icons/hicolor/512x512/apps/lycosa.png

    makeWrapper ${lib.getExe nwjs} $out/bin/lycosa \
      --add-flags "$out/share/lycosa"

    runHook postInstall
  '';

  meta = {
    mainProgram = "lycosa";
    description = "NW.js wrapper for the AULA HERO 84 HE WebHID configuration page";
    homepage = "https://github.com/puiyq/lycosa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puiyq ];
    platforms = lib.platforms.linux;
  };
}
