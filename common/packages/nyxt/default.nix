{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  runCommand,
  ...
}: let
  pname = "nyxt";
  version = "4.0.0";

  sources = {
    x86_64-linux = {
      url = "https://github.com/atlas-engineer/nyxt/releases/download/${version}/Linux-Nyxt-x86_64.tar.gz";
      hash = "sha256-v+x6K5svLA3L+IjEdTjmJEf3hvgwhwrvqAcelpY1ScQ=";
    };
    # Universal binary — same tarball for both Darwin architectures
    aarch64-darwin = {
      url = "https://github.com/atlas-engineer/nyxt/releases/download/${version}/macOS-Nyxt.app.tar.gz";
      hash = "sha256-dPreLCz8FDQ0kWIxu/JU087I9vWAYBa5gxe7+BzWmts=";
    };
    x86_64-darwin = {
      url = "https://github.com/atlas-engineer/nyxt/releases/download/${version}/macOS-Nyxt.app.tar.gz";
      hash = "sha256-dPreLCz8FDQ0kWIxu/JU087I9vWAYBa5gxe7+BzWmts=";
    };
  };

  inherit (stdenv.hostPlatform) system;
  source = sources.${system} or (throw "nyxt: unsupported system ${system}");

  tarball = fetchurl {inherit (source) url hash;};

  meta = {
    description = "A browser for hackers";
    homepage = "https://nyxt-browser.com";
    license = lib.licenses.bsd3;
    mainProgram = "nyxt";
    platforms = builtins.attrNames sources;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };

  darwinPkg = stdenv.mkDerivation {
    inherit pname version meta;

    src = tarball;

    nativeBuildInputs = [makeWrapper];

    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cd $out/Applications
      tar xzf $src

      makeWrapper $out/Applications/Nyxt.app/Contents/MacOS/nyxt $out/bin/nyxt

      runHook postInstall
    '';
  };

  linuxSrc = runCommand "${pname}-${version}.AppImage" {} ''
    tar xzf ${tarball}
    cp Nyxt-x86_64.AppImage $out
    chmod +x $out
  '';

  appimageContents = appimageTools.extractType2 {
    inherit pname version;
    src = linuxSrc;
  };

  linuxPkg = appimageTools.wrapType2 {
    inherit pname version meta;
    src = linuxSrc;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/nyxt.desktop \
        $out/share/applications/nyxt.desktop
      install -m 444 -D ${appimageContents}/nyxt.png \
        $out/share/pixmaps/nyxt.png
    '';
  };
in
  if stdenv.hostPlatform.isDarwin
  then darwinPkg
  else linuxPkg
