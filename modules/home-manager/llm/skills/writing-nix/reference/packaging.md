# Packaging

Packages live in `pkgs/<name>/default.nix`, auto-`callPackage`'d, with the
function header listing dependencies explicitly.

## finalAttrs over rec (the going-forward default)

```nix
# Good: finalAttrs lets self-references survive overrideAttrs. Overriding
# `version` correctly updates a `src` built from it.
{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "tool";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "you";
    repo = "tool";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AAAA...="; # SRI, algorithm-agnostic
  };

  meta = with lib; {
    description = "...";
    license = licenses.mit;
  };
})
```

```nix
# Outdated: rec. Overriding `version` here does NOT update `src.rev`, because
# `rec` captured the original `version`.
stdenv.mkDerivation rec {
  version = "1.4.0";
  src = fetchFromGitHub { rev = "v${version}"; ... };
}
```

This repo's newest package (`pkgs/sgx-sdk`) already uses `finalAttrs:` + SRI
`hash`; older ones still use `rec` + `sha256`. Match the newest. `with lib;`
scoped to the `meta` block is accepted local style.

## Hashes

Use SRI `hash = "sha256-...";`, not legacy base32 `sha256 = "0x...";`. To get a
hash: set it to `lib.fakeHash`, build, and read the real hash from the mismatch
error. Fetchers are fixed-output derivations — the output hash is what makes
network access pure and reproducible.

## callPackage, override, overrideAttrs

- **`callPackage ./pkg.nix { }`** auto-supplies the function's named args from the
  package set; pass overrides in the `{ }`.
- **`override`** changes the *function arguments* (swap a dependency:
  `pkg.override { withX = true; }`).
- **`overrideAttrs`** changes the *mkDerivation attrset* (patch `src`, flags,
  phases). Prefer it in almost all cases; `overrideDerivation` is outdated.

```nix
# In an overlay: patch an existing package's phases.
pkg.overrideAttrs (oldAttrs: {
  postInstall = (oldAttrs.postInstall or "") + ''
    wrapProgram $out/bin/pkg --set FOO bar
  '';
})
```

## buildInputs vs nativeBuildInputs

- **`nativeBuildInputs`** — tools that run on the *build* machine: compilers,
  `pkg-config`, code generators, `makeWrapper`.
- **`buildInputs`** — libraries linked into the output, run on the *host* machine.

They coincide for a native build but a wrong split silently breaks
cross-compilation — review for it.

## Script packages and overlays

- `writeShellApplication { name; runtimeInputs = [ ... ]; text = ''...''; }` for a
  shell script with its PATH dependencies wired in (used by `pkgs/roulette`).
- Overlays in `overlays/default.nix` are named (`additions`, `modifications`,
  `unstable-packages`), signature `final: prev:` (or `_final: prev:` when `final`
  is unused).
