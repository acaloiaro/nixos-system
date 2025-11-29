self: super: let
  inherit (super) stdenv lib;

  patch-bundle-info = super.writeText "patch-bundle-info.py" ''
    import plistlib
    import sys

    plist_path = sys.argv[1]

    # Load existing Info.plist
    with open(plist_path, 'rb') as f:
        pl = plistlib.load(f)

    # These document types are rquired to be considered a browser by System Preferences
    document_types = [
        {
            'CFBundleTypeName': 'HTML Document',
            'CFBundleTypeRole': 'Viewer',
            'LSItemContentTypes': ['public.html', 'public.xhtml']
        }
    ]
    # These URL schemes are rquired to be considered a browser by System Preferences
    url_types = [
        {
            'CFBundleURLName': 'http(s) URLs',
            'CFBundleURLSchemes': ['http', 'https']
        },
        {
            'CFBundleURLName': 'local file URLs',
            'CFBundleURLSchemes': ['file']
        }
    ]

    pl['CFBundleDocumentTypes'] = document_types
    pl['CFBundleURLTypes'] = url_types

    with open(plist_path, 'wb') as f:
        plistlib.dump(pl, f)
  '';
in {
  qutebrowser = super.qutebrowser.overrideAttrs (oldAttrs: {
    # `fixupPhase` uses `desktopToDarwinBundle` to generate an app bundle
    # (qutebrowser.app) from the qutebrowser XDG Desktop specification
    # file (./misc/org.qutebrowser.qutebrowser.desktop). Because
    # `desktopToDarwinBundle` doesn't use the MIME metadata from the .desktop
    # file, it does not generate necessary keys in Info.plist for qutebrowser to
    # be recognized by MacOS  as a valid browser.
    #
    # This postFixup phase adds those keys on MacOS.
    postFixup =
      (oldAttrs.postFixup or "")
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        PLIST="$out/Applications/qutebrowser.app/Contents/Info.plist"
        echo "Injecting browser registration keys into Info.plist"
        python3 ${patch-bundle-info} "$PLIST"
        echo "Info.plist patched successfully."
      '';
  });
}
