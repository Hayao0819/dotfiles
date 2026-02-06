---
description: Initialize a flake.nix for a project to enable nix develop
argument-hint: <project-directory>
allowed-tools: WebSearch, WebFetch(domain:github.com), WebFetch(domain:nixos.wiki), WebFetch(domain:nix.dev), Bash(nix flake check:*), Bash(nix develop:*), Bash(nix flake init:*), Read, Edit, Write, Glob, Grep, Bash(ls:*), Bash(cat:*)
---

# Initialize Flake for Project

You are initializing a Nix flake for the project at: **$ARGUMENTS**

## Step 1: Analyze the Project

1. Navigate to the project directory and identify:
   - Programming language(s) used (check for package.json, Cargo.toml, pyproject.toml, go.mod, etc.)
   - Existing dependency files
   - Build tools required

2. Check for existing files:
   ```bash
   ls -la "$ARGUMENTS"
   ```

3. Look for project configuration files to determine the tech stack:
   - `package.json` → Node.js/JavaScript/TypeScript
   - `Cargo.toml` → Rust
   - `pyproject.toml` / `requirements.txt` / `setup.py` → Python
   - `go.mod` → Go
   - `Gemfile` → Ruby
   - `pom.xml` / `build.gradle` → Java
   - `*.cabal` / `stack.yaml` → Haskell
   - `mix.exs` → Elixir
   - `CMakeLists.txt` / `Makefile` → C/C++

## Step 2: Create flake.nix

Based on the detected project type, create an appropriate `flake.nix`:

### Template Structure

```nix
{
  description = "Development environment for <project-name>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Add packages here based on project type
          ];

          shellHook = ''
            echo "Development environment loaded!"
          '';
        };
      }
    );
}
```

### Common Package Sets by Language

- **Node.js**: `nodejs`, `nodePackages.npm`, `nodePackages.pnpm`, `yarn`
- **Python**: `python3`, `python3Packages.pip`, `python3Packages.virtualenv`
- **Rust**: `rustc`, `cargo`, `rust-analyzer`, `clippy`
- **Go**: `go`, `gopls`, `gotools`
- **Ruby**: `ruby`, `bundler`
- **C/C++**: `gcc`, `clang`, `cmake`, `gnumake`
- **Java**: `jdk`, `maven`, `gradle`

## Step 3: Add .envrc (Optional)

If the user wants direnv integration, create `.envrc`:

```bash
use flake
```

And remind them to run `direnv allow`.

## Step 4: Create .gitignore entries

Add to `.gitignore` if not present:
```
# Nix
result
result-*
.direnv/
```

## Step 5: Validate

Test the flake:

```bash
cd "$ARGUMENTS" && nix flake check
```

Then verify the development shell works:

```bash
cd "$ARGUMENTS" && nix develop --command echo "Shell works!"
```

## Important Notes

- Ask the user if they need any additional tools or packages
- If the project uses multiple languages, include all relevant packages
- Consider adding language servers (LSP) for better IDE integration
- For projects with native dependencies, include necessary libraries

Now analyze the project at "$ARGUMENTS" and create an appropriate flake.nix.
