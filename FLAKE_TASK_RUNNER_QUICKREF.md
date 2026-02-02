# Nix Flakes Task Runner: Quick Reference

## Five Core Patterns

### 1. Simple Apps - Use writeShellApplication + apps output
```bash
nix run .#taskname
```
**Best for:** Simple scripts, CI/CD tasks, quick automation

### 2. Multiplexed Runner - Single app with command dispatch
```bash
nix run .# -- build
nix run .# -- test
nix run .# -- lint
```
**Best for:** Projects with 5-10 related tasks

### 3. Dev Shells - Environment with custom aliases/functions
```bash
nix develop
build    # Inside shell
test     # Custom alias
```
**Best for:** Local development, team environments

### 4. devenv - Process management + task orchestration
```bash
nix develop --no-pure-eval
devenv up                    # Start all services
devenv tasks run mydb:seed
```
**Best for:** Complex workflows, multi-service dev

### 5. Make/Just Wrapper - Keep existing tools, add Nix
```bash
nix run .#make -- build
nix develop
make test                    # Inside shell
```
**Best for:** Migrating existing projects

---

## Essential Functions

```nix
# Create executable script with dependencies
pkgs.writeShellApplication {
  name = "mytask";
  runtimeInputs = with pkgs; [ nodejs git ];
  text = ''
    set -euo pipefail
    npm build
  '';
}

# Make it runnable via 'nix run'
apps.${system}.mytask = {
  type = "app";
  program = "${scriptDeriv}/bin/mytask";
};
```

---

## Usage Patterns

| Task | Command | Pattern |
|------|---------|---------|
| Build | `nix run .#build` | Flake app |
| Develop | `nix develop` | devShell |
| Test CI | `nix flake check` | checks output |
| Run server | `nix run .#serve` | Flake app |
| Start services | `devenv up` | devenv processes |

---

## Best Practices Checklist

- [ ] Use `writeShellApplication` (not writeShellScript)
- [ ] Add `set -euo pipefail` to all scripts
- [ ] Declare all `runtimeInputs` explicitly
- [ ] Add help text/--help flag
- [ ] Test with `nix run --pure` to catch missing deps
- [ ] Git add all files before testing flakes
- [ ] Commit flake.lock to version control
- [ ] Test in clean environment (CI/CD)

---

## Template: Multi-Task Project

```nix
{
  description = "Project tasks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      task = name: runtimeInputs: text: pkgs.writeShellApplication {
        inherit name runtimeInputs text;
      };

      runner = task "task" (with pkgs; [ nodejs git ]) ''
        set -euo pipefail
        case "''${1:-help}" in
          build) npm run build ;;
          test) npm test ;;
          lint) npm run lint ;;
          *) echo "Tasks: build, test, lint" ;;
        esac
      '';
    in {
      apps.default = {
        type = "app";
        program = "${runner}/bin/task";
      };

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [ nodejs git ];
      };
    });
}
```

---

## Common Issues & Fixes

**Problem:** `Program not found`
**Fix:** Files not staged in git
```bash
git add flake.nix
nix run .#task
```

**Problem:** Missing runtime dependency  
**Fix:** Add to runtimeInputs
```nix
runtimeInputs = with pkgs; [ myTool ];  # Add this
```

**Problem:** Slow evaluation in devenv
**Fix:** Use --no-pure-eval
```bash
nix develop --no-pure-eval
```

**Problem:** Script works locally, fails in nix run
**Fix:** Local PATH has tools flakes don't - verify runtimeInputs
```bash
nix run --pure  # Test in isolated environment
```

---

## Key Commands

```bash
# Show all available apps
nix flake show

# Enter development shell
nix develop

# Run a task
nix run .#taskname

# Run with arguments
nix run .#task -- arg1 arg2

# Check syntax/validity
nix flake check

# Update dependencies
nix flake update

# Rebuild and enter shell
nix flake update && nix develop
```

---

## Integration Examples

**GitHub Actions:**
```yaml
- uses: cachix/install-nix-action@v20
- run: nix run .#test
- run: nix run .#build
```

**CI Makefile:**
```bash
.PHONY: test build
test:
	nix run .#test

build:
	nix run .#build
```

**Direnv Integration:**
```bash
# .envrc file
use flake
```

---

## Advanced Topics

### Monorepo with Multiple Tasks
- Define `mkTask` helper function
- Create task per subproject
- Reference with `nix run .#api-build`

### Process Management
- Use `devenv` for multi-service setup
- Define processes with dependencies
- Use `devenv up` to start all

### Task Dependencies
- devenv supports before/after
- Can depend on processes
- Parallel execution optimized

### Pre-commit Hooks
- Use pre-commit-hooks.nix flake input
- Define hooks in checks output
- Auto-run on git commit

---

## Learning Resources

1. **Official Docs**
   - https://nix.dev/concepts/flakes.html
   - https://nixos.wiki/wiki/Flakes

2. **Deep Dives**
   - https://tonyfinn.com/blog/nix-from-first-principles-flake-edition/nix-9-runnable-flakes/
   - https://serokell.io/blog/practical-nix-flakes

3. **Framework Docs**
   - devenv: https://devenv.sh/
   - flake-parts: https://flake.parts/

4. **Real Examples**
   - Nix-Tasks: https://github.com/clorl/Nix-Tasks
   - nix-task: https://github.com/madjam002/nix-task

---

## When to Use Each Pattern

**Use Simple Apps when:**
- You have 1-3 simple tasks
- Tasks are independent
- No service management needed

**Use Multiplexed Runner when:**
- You have 5-10 related tasks
- Want single entry point
- Share setup/teardown logic

**Use Dev Shells when:**
- Focus on local development
- Want convenient aliases/functions
- Integrating with direnv

**Use devenv when:**
- Multiple services needed
- Task dependencies matter
- Team needs structured workflow

**Use Make/Just Wrapper when:**
- Migrating existing project
- Team familiar with Make
- Want Nix + traditional tools

