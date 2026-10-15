# Troubleshooting

## Common Issues

### Infinite Recursion
**Causes:**
- Circular module references
- Using package attrs in `nixpkgs.config`
- Missing `mkIf` for conditional config

**Fix:**
```nix
# Always use mkIf
config = mkIf cfg.enable { ... };
```

### Package Not Found
```bash
# Check if package exists
nix search nixpkgs packageName

# Check in specific channel
nix search github:NixOS/nixpkgs/nixos-24.11 packageName
```

### Attribute Not Found
- Verify imports in flake.nix
- Check module paths
- Use `nix repl` to explore

## LLM Configuration Writes Fail

Claude Code and Codex save some settings during normal use. A Home Manager
symlink into `/nix/store` cannot serve as their writable configuration file.
Keep authentication, conversations and runtime state outside the store.

As checked on 2026-10-14, this flake's pinned Home Manager `release-26.05`
revision does not provide `mutableSettings` for either module. Upstream master
has merged support for both:

- [Claude Code, PR #10031](https://github.com/nix-community/home-manager/pull/10031)
- [Codex, PR #10000](https://github.com/nix-community/home-manager/pull/10000)

On a Home Manager revision with that support, enable
`programs.claude-code.mutableSettings` and use `programs.codex` with
`mutableSettings = true`. Activation merges declared settings into writable
files: declared values win, while undeclared runtime settings survive. Lists
are replaced rather than appended. Removing a declaration does not remove the
previously merged value. These options do not make instructions or skills
writable.

The LLM module implements this merge on 26.05 with
`home.activation.llmSettings`, after `linkGeneration`. Claude's generated
settings remain in the store as the declared input, but `settings.json` itself
is a regular writable file. Codex settings are merged on every switch instead
of only being seeded on first use. Both files use mode 600. Existing hooks,
trusted projects and other undeclared settings are preserved; TOML comments
are preserved too. Lists are replaced, and removing a declaration does not
remove a value already merged into the runtime file.

The merger validates existing files before replacing them atomically. Invalid
files and dangling links cause activation to fail without overwriting them.
It checks for edits made during the merge and aborts if it detects one; a CLI
write in the brief interval between that check and replacement can still race.
Home Manager dry runs do not execute the merger. Its regression tests run
when the merger derivation is built:

```bash
nix build .#homeConfigurations.debian.activationPackage
home-manager switch --flake .#debian
```

The declared Codex configuration uses `workspace-write` with the home directory
as an additional writable root and network access enabled. This allows Go and
Rust tools to write their caches under the home directory. The approval policy
is `never`; these values are the module's existing declarations. They apply to
new sessions. Explicit CLI flags, project settings and managed policies can
change the effective permissions; check the running session when writes fail.
Nix store files remain read-only even when their directory is an allowed root.

For instructions and skills linked from the store, edit their source in
`modules/home-manager/llm/` and apply the configuration. `CLAUDE.md` and managed
skills remain immutable even with mutable settings enabled. A
`mkOutOfStoreSymlink` adds an intermediate link and is not a general remedy for
Claude's atomic-write bug; see
[Claude Code #78162](https://github.com/anthropics/claude-code/issues/78162).

A Codex `thread-store conflict` with an `active writer` is a separate session
ownership problem, not evidence of a read-only Nix configuration.

## Debug Commands

```bash
# Show traces
nix flake check --show-trace
nix build --show-trace .#config

# Find option declarations
nix repl
:l <nixpkgs>
:p options.networking.hostName.declarationPositions

# Force rebuild (bypass cache)
nixos-rebuild switch --flake . --option eval-cache false

# Clean old packages
nix-collect-garbage -d
```

## Error Assertions
```nix
assertions = [{
  assertion = config.option != null;
  message = "Option X requires Y";
}];
```