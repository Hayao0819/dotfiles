# Nix Flakes as Task Runners - Complete Research Index

## Overview

This directory contains a complete research collection on using Nix Flakes as task runners for individual projects. The research covers patterns, best practices, real-world examples, and troubleshooting from 2023-2024 community knowledge.

**Total Research: 80 KB across 4 comprehensive documents**

---

## Documents at a Glance

| Document | Size | Purpose | Best For |
|----------|------|---------|----------|
| FLAKE_TASK_RUNNER_README.md | 11 KB | Navigation guide & summary | Overview, quick lookup |
| FLAKE_TASK_RUNNER_RESEARCH.md | 33 KB | Deep technical reference | Understanding concepts, design |
| FLAKE_TASK_RUNNER_QUICKREF.md | 8 KB | Quick lookup cheat sheet | Fast reference, decision-making |
| FLAKE_TASK_RUNNER_EXAMPLES.md | 23 KB | Production-ready code | Copy-paste implementation |

---

## How to Use This Collection

### First Time User Path
1. Start with **FLAKE_TASK_RUNNER_README.md** (overview)
2. Read **Five Core Patterns** section
3. Choose your pattern from the decision table
4. Copy example from **FLAKE_TASK_RUNNER_EXAMPLES.md**
5. Adapt to your project needs

**Estimated time: 30-60 minutes**

### Experienced Developer Path
1. Check **FLAKE_TASK_RUNNER_QUICKREF.md** for quick answers
2. Jump to specific example in **FLAKE_TASK_RUNNER_EXAMPLES.md**
3. Use copy-paste template
4. Reference **FLAKE_TASK_RUNNER_RESEARCH.md** for advanced topics

**Estimated time: 5-15 minutes**

### Research & Deep Dive Path
1. Read **FLAKE_TASK_RUNNER_RESEARCH.md** from start to finish
2. Study each design pattern thoroughly
3. Review all examples
4. Understand trade-offs and best practices
5. Consult referenced resources for additional learning

**Estimated time: 2-3 hours**

---

## Five Core Patterns Quick Reference

### Pattern 1: Simple Apps
**Use**: 1-3 simple, independent tasks
```bash
nix run .#taskname
```
**Example**: Single build script, deploy script

### Pattern 2: Multiplexed Runner
**Use**: 5-10 related tasks needing single entry point
```bash
nix run .# -- build
nix run .# -- test
nix run .# -- lint
```
**Example**: Full development workflow in one app

### Pattern 3: Dev Shells
**Use**: Local development, team convenience
```bash
nix develop
build    # custom alias
test     # custom function
```
**Example**: Development environment with tools and shortcuts

### Pattern 4: devenv Framework
**Use**: Complex workflows, multi-service management, process orchestration
```bash
nix develop --no-pure-eval
devenv up                    # Start services
devenv tasks run migrate
```
**Example**: Full-stack development with database, cache, app

### Pattern 5: Make/Just Wrapper
**Use**: Existing Makefile/justfile projects, gradual migration
```bash
nix run .#make -- build
nix run .#just -- build
```
**Example**: Retrofitting Nix onto existing build system

---

## Document Details

### FLAKE_TASK_RUNNER_README.md
Navigation guide that helps you find what you need.

**Contains:**
- Document descriptions
- Quick start by project type
- Five patterns with examples
- Key concepts
- Workflow guides
- Troubleshooting
- Integration examples
- When to use each pattern

**Start here if**: You're unsure where to begin

---

### FLAKE_TASK_RUNNER_RESEARCH.md
Comprehensive academic-style reference covering all aspects.

**Contains (9 parts):**
1. Core Concepts - Flakes fundamentals
2. Design Patterns - 5 patterns with detailed explanations
3. Advanced Patterns - Modular organization, monorepos, hooks
4. Best Practices - Documentation, error handling, reproducibility
5. Real-World Examples - Rust, Node.js, Docker implementations
6. Troubleshooting - Common issues and solutions
7. CI/CD Integration - GitHub Actions, GitLab CI
8. Comparison Matrix - Trade-offs table
9. Recommended Reading - Links to resources

**Read this if**: You want to understand everything thoroughly

---

### FLAKE_TASK_RUNNER_QUICKREF.md
Fast lookup reference for experienced developers.

**Contains:**
- Five patterns at a glance
- Essential Nix functions (writeShellApplication)
- Usage patterns table
- Best practices checklist
- Multi-task template (ready to adapt)
- Common issues & quick fixes
- Key commands reference
- Integration examples
- Decision matrix

**Use this if**: You need quick reminders while coding

---

### FLAKE_TASK_RUNNER_EXAMPLES.md
Production-ready code examples for common project types.

**Contains 5 complete examples:**
1. Node.js/TypeScript project
   - Tasks: dev, build, test, lint, format, type-check
   - Includes: dev shell with aliases
   
2. Python/Django project
   - Tasks: dev, test, lint, migrate, db operations
   - Includes: PostgreSQL setup, database management
   
3. Rust project
   - Tasks: build, test, bench, fmt, lint, doc
   - Includes: Rust overlay, cargo integration
   
4. Monorepo (frontend/backend)
   - Tasks: install, dev, build, test (all/specific)
   - Includes: Multi-package coordination
   
5. Docker/Services
   - Tasks: up, down, logs, shell, migrate, clean
   - Includes: docker-compose integration

**Use this if**: You need working code to copy and adapt

---

## Key Decision Matrix

```
Number of Tasks:
  1-3 tasks              -> Pattern 1: Simple Apps
  5-10 tasks             -> Pattern 2: Multiplexed Runner
  Many tasks             -> Pattern 4: devenv

Main Focus:
  CI/CD automation       -> Pattern 1 or 2
  Local development      -> Pattern 3 or 4
  Existing tools         -> Pattern 5

Complexity:
  Simple                 -> Pattern 1
  Medium                 -> Pattern 2 or 3
  Complex (services)     -> Pattern 4

Team Size:
  Solo                   -> Pattern 1 or 2
  Small team             -> Pattern 3 or 4
  Large monorepo         -> Pattern 4
```

---

## Essential Knowledge

### Key Nix Functions

**writeShellApplication** (preferred)
- Creates executable shell script
- Includes ShellCheck validation
- Automatically creates bin/<name>

**pkgs.mkShell**
- Creates development environment
- For use with `nix develop`
- Can include aliases, functions, variables

**flake.nix apps**
- Make tasks runnable with `nix run`
- Structure: `{ type = "app"; program = "..."; }`

### Required Patterns

All shell scripts must include:
```nix
text = ''
  set -euo pipefail
  # Your script
'';
```

All tasks must declare dependencies:
```nix
runtimeInputs = with pkgs; [ nodejs git ];
```

### Best Practices Checklist

- [ ] Use `writeShellApplication` (not writeShellScript)
- [ ] Add `set -euo pipefail` to all scripts
- [ ] Declare all `runtimeInputs` explicitly
- [ ] Provide help text (--help flag)
- [ ] Test with `nix run --pure` for isolated environment
- [ ] Run `git add` before testing (flakes need staged files)
- [ ] Commit `flake.lock` to version control
- [ ] Run `nix flake check` before committing
- [ ] Test in CI/CD environment

---

## Quick Start by Language/Framework

### Node.js / TypeScript / Next.js
See: **FLAKE_TASK_RUNNER_EXAMPLES.md - Example 1**
- 10 minute setup
- Build, test, lint, format tasks
- Development server ready

### Python / Django / FastAPI
See: **FLAKE_TASK_RUNNER_EXAMPLES.md - Example 2**
- 15 minute setup
- Database migrations built in
- PostgreSQL/Redis ready

### Rust / Cargo
See: **FLAKE_TASK_RUNNER_EXAMPLES.md - Example 3**
- 10 minute setup
- Full cargo workflow
- Benchmarking support

### Monorepo (Lerna, pnpm workspaces)
See: **FLAKE_TASK_RUNNER_EXAMPLES.md - Example 4**
- 20 minute setup
- Frontend/backend coordination
- Shared commands

### Docker / Services Stack
See: **FLAKE_TASK_RUNNER_EXAMPLES.md - Example 5**
- 15 minute setup
- Multi-container orchestration
- Database console access

---

## Common Workflow

### Initial Setup (5 minutes)
```bash
# Choose example from EXAMPLES document
# Copy flake.nix to your project root
git add flake.nix
nix flake check
```

### Testing (2 minutes)
```bash
nix flake show          # See available tasks
nix run .#task          # Run a task
nix develop            # Enter shell
```

### Daily Usage (ongoing)
```bash
nix run .#dev          # Start development
nix run .# -- test     # Run tests
nix run .# -- build    # Build
nix develop            # Dev shell
```

---

## Troubleshooting Quick Links

**Problem** -> **Solution**

| Problem | Section | Fix |
|---------|---------|-----|
| "Program not found" | QUICKREF | Git add files |
| Missing tool | QUICKREF | Add to runtimeInputs |
| Slow evaluation | README | Use --no-pure-eval |
| Script fails in nix run | QUICKREF | Test with --pure |
| Syntax errors | RESEARCH | nix flake check |
| Module not found | RESEARCH | Update imports |

---

## Community Resources

### Official Documentation
- Nix Flakes: https://nix.dev/concepts/flakes.html
- NixOS Wiki: https://nixos.wiki/wiki/Flakes

### Deep Technical Dives
- Tony Finn (9-part series): https://tonyfinn.com/blog/nix-from-first-principles-flake-edition/nix-9-runnable-flakes/
- Serokell Practical Guide: https://serokell.io/blog/practical-nix-flakes

### Frameworks & Tools
- devenv: https://devenv.sh/
- flake-parts: https://flake.parts/
- Nix-Tasks: https://github.com/clorl/Nix-Tasks
- nix-task: https://github.com/madjam002/nix-task

---

## Content Summary

### Concepts Covered
- Flake fundamentals and limitations
- Five design patterns with trade-offs
- Custom script creation with writeShellApplication
- Development environment setup
- Process management with devenv
- Multi-language project templates
- CI/CD integration
- Pre-commit hooks
- Monorepo strategies
- Performance optimization
- Troubleshooting guide

### Real-World Examples
- Node.js/TypeScript/Next.js projects
- Python/Django/FastAPI projects
- Rust projects with cargo
- Monorepos with multiple packages
- Docker/services stacks
- Database integration examples
- Service orchestration

### Best Practices
- Dependency declaration
- Error handling patterns
- Shell script validation
- Code organization
- Performance optimization
- Reproducibility checklist
- Git workflow integration
- CI/CD integration
- Team coordination

---

## Estimated Learning Time

| Level | Study Path | Time |
|-------|-----------|------|
| Beginner | README -> Quickref -> Examples | 1-2 hours |
| Intermediate | Examples -> Research as needed | 30-60 mins |
| Advanced | Research -> Deep dive resources | 2-3 hours |
| Expert | All documents + custom projects | 4+ hours |

---

## Next Steps

1. **Choose your pattern** - Use the decision matrix
2. **Find your example** - Look in FLAKE_TASK_RUNNER_EXAMPLES.md
3. **Copy template** - Adapt to your project
4. **Test** - Run `nix flake check` and `nix run .#task`
5. **Deploy** - Add to your project, commit flake.lock
6. **Iterate** - Refer to QUICKREF as needed

---

## Document Maintenance

These documents are comprehensive as of 2024. Community knowledge is evolving:

**Recommended for future updates:**
- Additional language examples (Go, Java, C++)
- Advanced monorepo patterns
- Integration with nix-direnv
- Cachix caching strategies
- Custom Nix modules
- Performance profiling guide

---

## Quick Index

**Need to...**
- Understand flakes? -> RESEARCH Part 1
- Choose a pattern? -> README Decision Section
- See examples? -> EXAMPLES
- Get quick answer? -> QUICKREF
- Troubleshoot? -> RESEARCH Part 6 or QUICKREF
- Set up new project? -> EXAMPLES (matching your tech)
- Integrate with CI/CD? -> RESEARCH Part 7 or README

---

## Final Notes

Nix Flakes provide a powerful, flexible approach to task running that integrates seamlessly with Nix's reproducibility guarantees. Whether you're starting a new project or refactoring an existing one, these documents provide everything needed to implement an effective task runner.

Key advantages:
- Zero setup for team members (with Nix installed)
- Exact reproducibility across machines
- Works with any programming language
- Composes with existing tools
- Integrates with git and CI/CD
- No Docker or system installation needed

Choose your pattern, copy your template, and start running tasks!

