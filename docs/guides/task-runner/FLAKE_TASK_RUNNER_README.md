# Nix Flakes as Task Runners: Complete Research Collection

This research collection provides comprehensive guidance on using Nix Flakes as task runners for individual projects, covering everything from basic concepts to advanced patterns with real-world examples.

## Research Documents

### 1. FLAKE_TASK_RUNNER_RESEARCH.md (1336 lines)
**Comprehensive Academic Deep Dive**

The primary research document covering all aspects of using Nix Flakes for task running. Includes:

- **Part 1: Core Concepts** - What are flakes, why use them, key limitations
- **Part 2: Design Patterns** (5 major patterns)
  - Pattern 1: Simple Apps with writeShellApplication
  - Pattern 2: Multiplexed Task Runner
  - Pattern 3: Development Shells with Custom Commands
  - Pattern 4: devenv Framework for Advanced Task Management
  - Pattern 5: Wrapping Makefile/Just with Nix
- **Part 3: Advanced Patterns** - Modular organization, monorepos, pre-commit hooks
- **Part 4: Best Practices** - Documentation, error handling, reproducibility, performance
- **Part 5: Real-World Examples** - Rust, Node.js+Python, Docker
- **Part 6: Troubleshooting** - Common issues and solutions
- **Part 7: CI/CD Integration** - GitHub Actions, GitLab CI examples
- **Part 8: Comparison Matrix** - When to use each pattern
- **Part 9: Recommended Reading** - Links to official docs and deep dives

**Use this for:**
- Understanding all aspects of flake-based task runners
- Learning design patterns and trade-offs
- Troubleshooting complex setups
- Understanding the "why" behind recommendations

### 2. FLAKE_TASK_RUNNER_QUICKREF.md (288 lines)
**Fast Lookup Reference Guide**

Quick reference for experienced developers. Includes:

- Five core patterns at a glance
- Essential Nix functions
- Usage patterns table
- Best practices checklist
- Multi-task template
- Common issues & fixes
- Key commands
- Integration examples
- When to use each pattern

**Use this for:**
- Quick reminders while coding
- Decision-making on pattern selection
- Common command syntax
- Troubleshooting checklist

### 3. FLAKE_TASK_RUNNER_EXAMPLES.md (892 lines)
**Copy-Paste Ready Implementation Examples**

Production-ready examples for common project types:

1. **Node.js/TypeScript Project** - Development, building, testing
2. **Python/Django Project** - Database setup, migrations, testing
3. **Rust Project** - Building, testing, benchmarking, documentation
4. **Monorepo** - Multi-package coordination, frontend/backend tasks
5. **Docker/Services Stack** - Container orchestration, database management

Each example includes:
- Full flake.nix implementation
- Usage examples
- Customization tips

**Use this for:**
- Quick project setup
- Copy and adapt for your needs
- Understanding real-world patterns

---

## Quick Start by Project Type

### Node.js Project
1. Copy Example 1 from FLAKE_TASK_RUNNER_EXAMPLES.md
2. Adapt task names in the runner script
3. Run: `nix run .# -- dev`

### Python Project
1. Copy Example 2 from FLAKE_TASK_RUNNER_EXAMPLES.md
2. Update dependencies in pythonDeps
3. Run: `nix run .# -- dev`

### Rust Project
1. Copy Example 3 from FLAKE_TASK_RUNNER_EXAMPLES.md
2. Customize toolchain if needed
3. Run: `nix run .# -- build`

### Monorepo
1. Copy Example 4 from FLAKE_TASK_RUNNER_EXAMPLES.md
2. Update directory paths
3. Run: `nix run .# -- install`

### Docker Setup
1. Copy Example 5 from FLAKE_TASK_RUNNER_EXAMPLES.md
2. Update compose file reference
3. Run: `nix run .# -- up`

---

## Five Core Patterns Explained

### Pattern 1: Simple Apps
Use `writeShellApplication` + `apps` output
```bash
nix run .#taskname
```
Best for: Simple scripts, 1-3 tasks, CI/CD

### Pattern 2: Multiplexed Runner
Single app with command dispatch
```bash
nix run .# -- build
nix run .# -- test
```
Best for: 5-10 related tasks, shared setup

### Pattern 3: Dev Shells
Environment with aliases and functions
```bash
nix develop
build    # Inside shell
```
Best for: Local development, team convenience

### Pattern 4: devenv Framework
Process management + task orchestration
```bash
nix develop --no-pure-eval
devenv up
devenv tasks run mytask
```
Best for: Complex workflows, multi-service setup

### Pattern 5: Make/Just Wrapper
Wrap existing tools with Nix
```bash
nix run .#make -- build
```
Best for: Migrating projects, familiar workflows

---

## Key Concepts

### writeShellApplication vs Alternatives
- **writeShellApplication** (preferred) - Includes ShellCheck validation
- **writeShellScript** (older) - No validation
- **writeTextFile** (for non-shell) - Generic option

### Required Patterns
All scripts should include:
```nix
text = ''
  set -euo pipefail
  # Your script here
'';
```

### Dependency Declaration
Always explicit about runtime inputs:
```nix
runtimeInputs = with pkgs; [ 
  nodejs      # JavaScript runtime
  git         # Version control
  gnumake     # Build system
];
```

### Best Practices
1. Use `writeShellApplication` (not writeShellScript)
2. Add `set -euo pipefail` for error handling
3. Declare all `runtimeInputs` explicitly
4. Add help text with --help flag
5. Test with `nix run --pure` to catch missing deps
6. Git add files before testing (flakes need staged files)
7. Commit flake.lock to version control
8. Test in clean CI/CD environments

---

## Common Workflow

### Setting Up a New Project

1. **Create flake.nix** from examples or template
2. **Stage files**: `git add flake.nix`
3. **Validate**: `nix flake check`
4. **Test**: `nix run .#taskname`
5. **Enter shell**: `nix develop`
6. **Commit**: Include flake.lock

### Daily Usage

```bash
# View available tasks
nix flake show

# Enter development environment
nix develop

# Run a specific task
nix run .#taskname

# Run with arguments
nix run .#task -- arg1 arg2

# Format code (if configured)
nix fmt

# Validate flakes (MUST DO before commit)
nix flake check
```

---

## Troubleshooting

### "Program not found"
**Cause**: Files not staged in git

**Fix**:
```bash
git add flake.nix
nix run .#task
```

### Missing runtime dependency
**Cause**: Forgot to add tool to `runtimeInputs`

**Fix**:
```nix
runtimeInputs = with pkgs; [ myTool ];
```

### Script works locally, fails in nix run
**Cause**: Local PATH has tools flakes don't

**Fix**: Verify runtimeInputs, test with `nix run --pure`

### Slow evaluation in devenv
**Cause**: Pure evaluation mode

**Fix**:
```bash
nix develop --no-pure-eval
```

---

## Integration with Other Tools

### GitHub Actions
```yaml
- uses: cachix/install-nix-action@v20
- run: nix run .#test
- run: nix run .#build
```

### GitLab CI
```yaml
test:
  image: nixos/nix:latest
  script:
    - nix run .#test
    - nix run .#build
```

### Pre-commit Hooks
```bash
# .envrc
use flake
```

### direnv Integration
```bash
# .envrc
use flake
```

Automatic shell activation when entering directory.

---

## When to Use Each Pattern

| Pattern | Complexity | Use When | Overhead |
|---------|-----------|----------|----------|
| Simple Apps | Low | 1-3 simple tasks | None |
| Multiplexed Runner | Medium | 5-10 related tasks | Bash dispatch |
| Dev Shells | Low | Local development focus | Small |
| devenv | High | Complex multi-service | Framework |
| Make/Just Wrapper | Low | Migrating existing project | Thin |

---

## Advanced Topics Covered

### In FLAKE_TASK_RUNNER_RESEARCH.md:
- Modular flake organization (split into multiple files)
- Monorepo task management
- Pre-commit hooks integration
- Performance optimization techniques
- Language-specific patterns

### In FLAKE_TASK_RUNNER_EXAMPLES.md:
- Production-ready configurations
- Multi-language setups
- Database management
- Docker integration
- Service orchestration

---

## Performance Tips

1. **Use `--no-pure-eval` with devenv** for faster evaluation
2. **Use `nix develop` instead of `nix shell`** for faster subsequent runs
3. **Cache evaluation results** - Nix does this automatically after first run
4. **Use flake-utils** for multi-platform support
5. **Profile with `nix eval --json`** if evaluation is slow

---

## Real-World Usage Stats

Based on 2023-2024 community practices:

- **Simple Apps**: Simplest, no configuration needed, works immediately
- **Multiplexed Runner**: Most balanced, good for most projects
- **Dev Shells**: Popular for team environments with direnv
- **devenv**: Growing adoption for complex projects
- **Make/Just Wrapper**: Common migration path from existing tools

---

## Key Files to Reference

1. **Official Documentation**
   - https://nix.dev/concepts/flakes.html
   - https://nixos.wiki/wiki/Flakes

2. **Deep Dives**
   - Tony Finn's Nix From First Principles
   - Serokell's Practical Nix Flakes

3. **Frameworks**
   - devenv (https://devenv.sh/)
   - flake-parts (https://flake.parts/)
   - pre-commit-hooks.nix (https://github.com/cachix/pre-commit-hooks.nix)

4. **Community Projects**
   - Nix-Tasks (https://github.com/clorl/Nix-Tasks)
   - nix-task (https://github.com/madjam002/nix-task)

---

## Document Navigation

**Start Here:**
- First time user? Start with FLAKE_TASK_RUNNER_QUICKREF.md

**Need Examples?**
- Looking for copy-paste ready code? See FLAKE_TASK_RUNNER_EXAMPLES.md

**Need Deep Understanding?**
- Want to understand everything? Read FLAKE_TASK_RUNNER_RESEARCH.md

**Have Specific Problem?**
- Check Troubleshooting section in RESEARCH or QUICKREF

**Need Specific Pattern?**
- Find your use case in EXAMPLES with full implementations

---

## Contribution Notes

These documents are comprehensive but not exhaustive. Recommended additions in future:

- More language examples (Go, C++, Java, etc.)
- Advanced monorepo patterns
- Integration with nix-direnv
- Cachix caching strategies
- Performance profiling techniques
- Custom Nix modules for tasks

---

## Summary

Nix Flakes provide powerful, reproducible task running capabilities suitable for any project type:

- **Zero installation** - Anyone with Nix can run tasks immediately
- **Reproducible** - Same environment across all machines
- **Flexible** - Five different patterns for different needs
- **Composable** - Can wrap existing tools
- **Well-integrated** - Works with git, CI/CD, and direnv

Whether you're building a simple Node.js app or managing a complex monorepo, there's a flake pattern that fits your needs.

