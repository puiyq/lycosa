{
  lib,
  stdenv,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  esbuild,
  electron,

  zoomFactor ? "1",
}:

stdenv.mkDerivation {
  pname = "lycosa";
  version = "0.2.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src/icon.png
      ./src/package.json
      ./src/main.ts
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

  env.NODE_ENV = "production";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/lycosa $out/bin

    cp -r src/package.json src/icon.png $out/share/lycosa/
    esbuild src/main.ts --bundle --platform=node --format=cjs --external:electron --outfile=$out/share/lycosa/main.js

    install -Dm644 src/icon.png $out/share/icons/hicolor/512x512/apps/lycosa.png

    makeWrapper ${lib.getExe electron} $out/bin/lycosa \
     --set LYCOSA_ZOOM_FACTOR "${zoomFactor}" \
      --add-flags "$out/share/lycosa"

    runHook postInstall
  '';

  meta = {
    mainProgram = "lycosa";
    description = "Electron wrapper for the AULA HERO 84 HE WebHID configuration page";
    homepage = "https://github.com/puiyq/lycosa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puiyq ];
    platforms = lib.platforms.linux;
  };
}
