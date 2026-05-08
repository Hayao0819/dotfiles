# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: _prev:
    import ../pkgs {
      flake = inputs.self;
      inherit (final) pkgs;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications =
    final: prev:
    let
      # Helper to patch GNOME extensions with GIRepository search paths
      patchGnomeExtension =
        {
          extension,
          patches,
        }:
        extension.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            ${builtins.concatStringsSep "\n" (
              builtins.map (
                { file, replacements }:
                builtins.concatStringsSep "\n" (
                  builtins.map (r: ''
                    substituteInPlace "$out/share/gnome-shell/extensions/${extension.extensionUuid}/${file}" \
                      --replace-fail "${r.from}" "${r.to}"
                  '') replacements
                )
              ) patches
            )}
          '';
        });
    in
    {
      gnomeExtensions = prev.gnomeExtensions // {
        # Patch disable-3-finger-gestures-redux to only disable app grid swipe
        # Keep overview, workspace switching, and overview workspace gestures enabled
        disable-3-finger-gestures-redux = patchGnomeExtension {
          extension = prev.gnomeExtensions.disable-3-finger-gestures-redux;
          patches = [
            {
              file = "extension.js";
              replacements = [
                {
                  from = "Main.overview._swipeTracker._touchpadGesture,";
                  to = "// Main.overview._swipeTracker._touchpadGesture,  // オーバービュー表示";
                }
                {
                  from = "Main.wm._workspaceAnimation._swipeTracker._touchpadGesture,";
                  to = "// Main.wm._workspaceAnimation._swipeTracker._touchpadGesture,  // ワークスペース切り替え";
                }
                {
                  from = "Main.overview._overview._controls._workspacesDisplay._swipeTracker._touchpadGesture,";
                  to = "// Main.overview._overview._controls._workspacesDisplay._swipeTracker._touchpadGesture,  // オーバービュー内ワークスペース";
                }
                {
                  from = "Main.overview._overview._controls._appDisplay._swipeTracker._touchpadGesture,";
                  to = "Main.overview._overview._controls._appDisplay._swipeTracker._touchpadGesture,  // アプリ一覧表示のみ無効化";
                }
              ];
            }
          ];
        };
      };

      unstable = prev.unstable // {
        gnomeExtensions = prev.unstable.gnomeExtensions // {
          copyous = patchGnomeExtension {
            extension = prev.unstable.gnomeExtensions.copyous;
            patches = [
              {
                file = "lib/misc/db.js";
                replacements = [
                  {
                    from = "gda = (await import('gi://Gda')).default;";
                    to = "imports.gi.GIRepository.Repository.prepend_search_path('${final.libgda6}/lib/girepository-1.0'); gda = (await import('gi://Gda')).default;";
                  }
                ];
              }
              {
                file = "lib/common/sound.js";
                replacements = [
                  {
                    from = "const gsound = (await import('gi://GSound')).default;";
                    to = "imports.gi.GIRepository.Repository.prepend_search_path('${final.gsound}/lib/girepository-1.0'); const gsound = (await import('gi://GSound')).default;";
                  }
                ];
              }
            ];
          };
        };
      };
    };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
    };
  };

  # llm-agents packages (ccstatusline, etc.)
  llm-agents = inputs.llm-agents.overlays.default;

  # Patch os-prober to suppress lsblk stderr warnings for non-existent /dev/mapper devices
  # This fixes the "lsblk: /dev/mapper/no*[0-9]: ブロックデバイスではありません" warnings
  os-prober-fix = final: prev: {
    os-prober = prev.os-prober.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        # Redirect lsblk stderr to /dev/null in common.sh fs_type function
        substituteInPlace common.sh \
          --replace-fail 'lsblk --nodeps --noheading --output FSTYPE -- "$1"' \
                         'lsblk --nodeps --noheading --output FSTYPE -- "$1" 2>/dev/null'
      '';
    });
  };

  # IPU7 camera packages from PR #479283
  # Remove this overlay once the PR is merged into nixpkgs
  ipu7-packages =
    final: prev:
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
      # icamerasrc is in gst_all_1 namespace
      inherit (ipu7-pkgs.gst_all_1)
        icamerasrc-ipu7x
        icamerasrc-ipu75xa
        ;
    };
}
