{ inputs, ... }:
{
  additions =
    final: _prev:
    import ../pkgs {
      inherit (final) pkgs;
    };

  modifications =
    _final: prev:
    let
      patchGnomeExtension =
        {
          extension,
          patches,
        }:
        extension.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            ${
              patches
              |> builtins.map (
                { file, replacements }:
                replacements
                |> builtins.map (r: ''
                  substituteInPlace "$out/share/gnome-shell/extensions/${extension.extensionUuid}/${file}" \
                    --replace-fail "${r.from}" "${r.to}"
                '')
                |> builtins.concatStringsSep "\n"
              )
              |> builtins.concatStringsSep "\n"
            }
          '';
        });
    in
    {
      gnomeExtensions = prev.gnomeExtensions // {
        disable-3-finger-gestures-redux = patchGnomeExtension {
          extension = prev.gnomeExtensions.disable-3-finger-gestures-redux;
          patches = [
            {
              file = "extension.js";
              replacements = [
                {
                  from = "Main.overview._swipeTracker._touchpadGesture,";
                  to = "// Main.overview._swipeTracker._touchpadGesture,";
                }
                {
                  from = "Main.wm._workspaceAnimation._swipeTracker._touchpadGesture,";
                  to = "// Main.wm._workspaceAnimation._swipeTracker._touchpadGesture,";
                }
                {
                  from = "Main.overview._overview._controls._workspacesDisplay._swipeTracker._touchpadGesture,";
                  to = "// Main.overview._overview._controls._workspacesDisplay._swipeTracker._touchpadGesture,";
                }
                {
                  from = "Main.overview._overview._controls._appDisplay._swipeTracker._touchpadGesture,";
                  to = "Main.overview._overview._controls._appDisplay._swipeTracker._touchpadGesture,";
                }
              ];
            }
          ];
        };
      };
    };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
    };
  };

  os-prober-fix = _final: prev: {
    os-prober = prev.os-prober.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        substituteInPlace common.sh \
          --replace-fail 'lsblk --nodeps --noheading --output FSTYPE -- "$1"' \
                         'lsblk --nodeps --noheading --output FSTYPE -- "$1" 2>/dev/null'
      '';
    });
  };

  ipu7-packages =
    final: _prev:
    let
      ipu7-pkgs = import inputs.nixpkgs-ipu7 {
        system = final.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      inherit (ipu7-pkgs)
        ipu7-camera-bins
        ipu7-camera-hal-ipu7x
        ipu7-camera-hal-ipu75xa
        ;
      inherit (ipu7-pkgs.gst_all_1)
        icamerasrc-ipu7x
        icamerasrc-ipu75xa
        ;
    };
}
