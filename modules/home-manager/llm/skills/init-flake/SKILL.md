---
name: init-flake
description: Initialize a Nix flake for any project to set up a reproducible development environment with nix develop. Use when a project needs flake.nix, devShell, or Nix-based development setup.
argument-hint: <project-directory>
disable-model-invocation: true
allowed-tools: WebSearch, WebFetch(domain:github.com), WebFetch(domain:nix.dev), WebFetch(domain:wiki.nixos.org), Bash(nix flake *), Bash(nix develop *), Bash(ls *), Bash(git *), Read, Edit, Write, Glob, Grep
---

# Initialize Nix Flake

Set up a Nix flake for the project at: **$ARGUMENTS**

## 1. Project Analysis

Inspect the target directory to determine the tech stack:

- Check for language-specific manifest files (package.json, Cargo.toml, pyproject.toml, go.mod, Gemfile, pom.xml, mix.exs, CMakeLists.txt, *.cabal, deno.json, etc.)
- Identify build tools and dependency managers in use
- Note any existing Nix files (flake.nix, shell.nix, default.nix)

If a flake.nix already exists, ask the user before overwriting.

## 2. Generate flake.nix

Create a flake.nix tailored to the detected stack. Use this base structure:

```nix
{
  description = "Development environment for <project>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # language runtime, build tools, LSP, linters
          ];
          shellHook = ''
            echo "dev shell ready"
          '';
        };
      }
    );
}
```

### Language-specific packages

| Stack | Typical packages |
|-------|-----------------|
| Node.js | nodejs, pnpm or yarn, nodePackages.typescript |
| Python | python3, uv or python3Packages.pip |
| Rust | rustc, cargo, rust-analyzer, clippy, rustfmt |
| Go | go, gopls, gotools |
| C/C++ | gcc or clang, cmake, gnumake, pkg-config |
| Ruby | ruby, bundler |
| Java | jdk, maven or gradle |
| Haskell | ghc, cabal-install, haskell-language-server |
| Elixir | elixir, erlang |
| Deno | deno |

For mixed-language projects, combine the relevant packages.

## 3. direnv integration (optional)

Ask the user if they want direnv support. If yes:

- Create `.envrc` containing `use flake`
- Remind them to run `direnv allow`

## 4. Update .gitignore

Append these entries if missing:

```
# Nix
result
result-*
.direnv/
```

## 5. Validate

Run validation to ensure the flake is correct:

```bash
cd "$ARGUMENTS" && nix flake check --extra-experimental-features 'nix-command flakes'
```

Then test the dev shell:

```bash
cd "$ARGUMENTS" && nix develop --extra-experimental-features 'nix-command flakes' --command echo "Shell works!"
```

## Notes

- Ask the user if they need additional tools or libraries
- Include language servers for IDE integration where appropriate
- For projects with native dependencies, add the required system libraries
- Use `--extra-experimental-features` flag so it works on systems without flakes enabled globally
