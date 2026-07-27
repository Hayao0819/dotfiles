---
name: cleanup
description: Performs comprehensive cleanup of the Nix codebase. Detects anti-patterns, removes dead code, fixes inconsistencies, and validates.
when_to_use: When the user asks to clean up, lint, or improve the quality of their Nix configuration files.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(nix flake check:*), Bash(nix eval:*)
---

# Nix Codebase Cleanup

## Phase 1: Anti-Pattern Detection

Scan for and fix:

- **`rec { }`** → Use `let ... in` instead (infinite recursion risk)
- **Top-level `with`** → Use `inherit` or qualified names
- **Lookup paths `<...>`** → Use flake inputs
- **Bare URLs** → Always quote (RFC 45)

## Phase 2: Dead Code & Redundancy

- Unused `let` bindings and function arguments
- Commented-out code blocks
- Duplicate package declarations across files
- `if x == true` → `if x`, `if x then true else false` → `x`

## Phase 3: Consistency

- camelCase for variables, kebab-case for derivations
- Consistent `lib` usage
- Consistent module structure

## Phase 4: Module Structure

- Large files that should be split
- No circular imports
- Clear dependency direction

## Phase 5: Validate

```bash
nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'
nix eval .#nixosConfigurations.XPS9350.config.system.build.toplevel --extra-experimental-features 'nix-command flakes pipe-operators'
```

Report: files modified, issues found/fixed, validation results.
