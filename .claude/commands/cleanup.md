---
description: Cleanup Nix codebase - fix redundancies, inconsistencies, and improve readability
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(nix flake check:*), Bash(nix eval:*), Bash(nix-instantiate:*)
---

# Nix Codebase Cleanup

Perform a comprehensive cleanup of the Nix codebase to improve code quality, readability, and maintainability.

## Cleanup Checklist

### Phase 1: Static Analysis

Run these checks to identify issues:

```bash
# Check for syntax errors
nix flake check --extra-experimental-features 'nix-command flakes'
```

### Phase 2: Anti-Pattern Detection

Search for and fix these common Nix anti-patterns:

#### 2.1 Avoid `rec` (Infinite Recursion Risk)
**Problem**: `rec { }` can cause hard-to-debug infinite recursion when names are shadowed.
**Solution**: Use `let ... in` instead.

```nix
# Bad
rec {
  a = 1;
  b = a + 2;
}

# Good
let
  a = 1;
in {
  inherit a;
  b = a + 2;
}
```

#### 2.2 Avoid Top-Level `with`
**Problem**: `with` makes code harder to analyze and scoping unclear.
**Solution**: Use explicit `inherit` or qualified names.

```nix
# Bad
with pkgs; [ git vim nodejs ]

# Good
with pkgs; [ git vim nodejs ]  # OK in limited scope like lists
inherit (pkgs) git vim nodejs;  # Better for bindings

# Best (explicit)
[ pkgs.git pkgs.vim pkgs.nodejs ]
```

#### 2.3 Avoid Lookup Paths `<...>`
**Problem**: `<nixpkgs>` depends on `$NIX_PATH`, breaking reproducibility.
**Solution**: Use flake inputs or explicit pinning.

```nix
# Bad
import <nixpkgs> {}

# Good (in flakes)
inputs.nixpkgs.legacyPackages.${system}
```

#### 2.4 Always Quote URLs
**Problem**: Bare URLs are deprecated (RFC 45).
**Solution**: Always use quoted strings.

```nix
# Bad
url = https://example.com;

# Good
url = "https://example.com";
```

### Phase 3: Code Quality Improvements

#### 3.1 Dead Code Detection
Look for:
- Unused `let` bindings
- Unused function arguments
- Commented-out code blocks
- Unreachable code paths

#### 3.2 Redundancy Removal
Look for:
- Duplicate package declarations across files
- Repeated configuration blocks that could be abstracted
- Identical imports in multiple files
- Redundant conditionals (e.g., `if true then x else y`)

#### 3.3 Consistency Checks
Ensure:
- Consistent naming conventions (camelCase for variables, kebab-case for derivations)
- Consistent formatting and indentation (2 spaces standard)
- Consistent use of `lib` vs inline functions
- Consistent module structure across similar files

#### 3.4 Simplification Opportunities
Look for:
- `if x == true` → `if x`
- `if x == false` → `if !x`
- `if x then true else false` → `x`
- Nested `let` that can be flattened
- `with pkgs; with lib;` → single `with`
- Empty `let in` blocks
- Useless parentheses

### Phase 4: Module Structure Review

#### 4.1 File Organization
Check for:
- Large files that should be split
- Related options scattered across files
- Missing `default.nix` in directories

#### 4.2 Import Hygiene
Verify:
- No circular imports
- Minimal import depth
- Clear dependency direction (modules → lib, not lib → modules)

#### 4.3 Option Definitions
Ensure:
- Proper option types (`lib.types.*`)
- Meaningful default values
- Documentation strings for public options

### Phase 5: Attribute Set Best Practices

#### 5.1 Proper Merging
```nix
# Bad (shallow merge loses nested attrs)
a // b

# Good (for nested structures)
lib.recursiveUpdate a b

# Or use mkMerge for module options
lib.mkMerge [ config1 config2 ]
```

#### 5.2 Explicit Config/Overlays
```nix
# Bad (inherits global config)
import nixpkgs {}

# Good (explicit and reproducible)
import nixpkgs {
  config = {};
  overlays = [];
}
```

### Phase 6: Specific Files to Check

1. **flake.nix** - Entry point, inputs/outputs structure
2. **modules/nixos/default.nix** - Module index
3. **modules/home-manager/default.nix** - Home Manager module index
4. **Configuration files** - `nixos/*/configuration.nix`

### Phase 7: Validation

After all changes:

```bash
# Syntax and type check
nix flake check --extra-experimental-features 'nix-command flakes'

# Evaluate to catch runtime errors
nix eval .#nixosConfigurations.xps9350.config.system.build.toplevel --extra-experimental-features 'nix-command flakes'
```

## Execution Steps

1. **Scan**: Use Grep to find anti-patterns (`rec {`, `with pkgs;`, `<nixpkgs>`, unquoted URLs)
2. **Read**: Examine each file with issues
3. **Fix**: Apply corrections following the patterns above
4. **Validate**: Run `nix flake check` after each significant change
5. **Report**: Summarize changes made

## Output Format

Provide a summary of:
- Files modified
- Issues found and fixed (categorized)
- Remaining warnings or suggestions
- Validation results

Now begin the cleanup process by scanning for anti-patterns.
