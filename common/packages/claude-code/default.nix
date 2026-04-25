{
  lib,
  stdenv,
  fetchzip,
  bubblewrap,
  makeBinaryWrapper,
  patchelf,
  procps,
  socat,
  ...
}: let
  version = "2.1.119";

  # Upstream switched at 2.1.113+ from a JS bundle run under bun to one native
  # binary per platform shipped as an optionalDependency. We fetch that
  # platform-specific package directly. Hashes are populated by update.sh —
  # the # <system> markers on each line are sed targets.
  sources = {
    aarch64-darwin = {
      pkg = "claude-code-darwin-arm64";
      hash = "sha256-faK1JsyiXNnDY3BbtP70Dyk8EirUbR14uK66tIXDG6Y="; # aarch64-darwin
    };
    x86_64-darwin = {
      pkg = "claude-code-darwin-x64";
      hash = "sha256-x38Q7to9tmLjj1i2L8HZf3QB/njfmnmtXBoUnqBi44M="; # x86_64-darwin
    };
    aarch64-linux = {
      pkg = "claude-code-linux-arm64";
      hash = "sha256-RkKTMRFpNnveae1VqkmPxzB5XGSXu4aveGjpNt23L+4="; # aarch64-linux
      interpreter = "ld-linux-aarch64.so.1";
    };
    x86_64-linux = {
      pkg = "claude-code-linux-x64";
      hash = "sha256-fVe3LUhRbfqbTeutDKOGzhj1XTQu6pONYXE8RS+AkDM="; # x86_64-linux
      interpreter = "ld-linux-x86-64.so.2";
    };
  };

  inherit (stdenv.hostPlatform) system;
  source = sources.${system} or (throw "claude-code: unsupported system ${system}");

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/${source.pkg}/-/${source.pkg}-${version}.tgz";
    inherit (source) hash;
  };

  extraPath = lib.makeBinPath (
    [procps]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      bubblewrap
      socat
    ]
  );
in
  stdenv.mkDerivation {
    pname = "claude-code";
    inherit version src;

    nativeBuildInputs =
      [makeBinaryWrapper]
      ++ lib.optionals stdenv.hostPlatform.isLinux [patchelf];

    dontBuild = true;
    dontConfigure = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -D -m 0755 claude $out/libexec/claude-code/claude

      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        patchelf --set-interpreter "${stdenv.cc.libc}/lib/${source.interpreter}" \
          $out/libexec/claude-code/claude
      ''}

      makeBinaryWrapper $out/libexec/claude-code/claude $out/bin/claude-code \
        --set DISABLE_AUTOUPDATER 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --unset DEV \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --prefix PATH : ${extraPath}

      ln -s claude-code $out/bin/claude

      runHook postInstall
    '';

    passthru.updateScript = ./update.sh;

    meta = {
      description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
      homepage = "https://github.com/anthropics/claude-code";
      license = lib.licenses.unfree;
      mainProgram = "claude-code";
      platforms = builtins.attrNames sources;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
