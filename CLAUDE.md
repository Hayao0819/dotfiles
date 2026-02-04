# CLAUDE.md

AI assistant guidance for Nix dotfiles repository.

## Quick Links

### Setup & Validation

- [Validation Guide](docs/setup/validation.md) - **ALWAYS validate after .nix changes**

### Reference

- [Commands](docs/reference/commands.md) - All deployment commands
- [Architecture](docs/reference/architecture.md) - Repository structure

### Guides

- [Nix Language](docs/guides/nix-language.md) - Language quick reference
- [File System Mounts](docs/guides/filesystem-mounts.md) - Mount configuration
- [Task Runner](docs/guides/task-runner.md) - Built-in automation
- [Task Runner Details](docs/guides/task-runner/) - Advanced patterns & examples

### Troubleshooting

- [Common Issues](docs/troubleshooting/common-issues.md) - Debug commands & fixes

## Essential Rules

1. **ALWAYS validate** after any `.nix` file change:

   ```bash
   nix flake check --extra-experimental-features 'nix-command flakes'
   ```

2. **Repository**: Nix Flakes for NixOS, Home Manager, Darwin
3. **Platforms**: NixOS (full OS), Linux (Home Manager), macOS (nix-darwin)
4. **Main configs**: `XPS9350` (NixOS), `archlinux` (Home Manager)

## Auto-Update Policy

When discovering new Nix information through web searches or problem-solving, automatically update relevant documentation
files without being asked.
