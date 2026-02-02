# Nix Flakes as Task Runners: Comprehensive Research Guide

## Executive Summary

Nix Flakes provide multiple patterns for task running and project automation, from simple executable apps to complex process orchestration. The primary mechanisms are:

1. **Flake Apps Output** - Direct execution via `nix run`
2. **Development Shells (devShell)** - Reproducible development environments with custom commands
3. **devenv Framework** - Higher-level task orchestration and process management
4. **Custom Scripts** - Shell scripts with Nix-managed dependencies
5. **Integration with Make/Just** - Combining traditional tools with Nix reproducibility

---

## Part 1: Core Concepts

### What Are Flakes?

Flakes are a standardized Nix extension providing:
- **Entry Point**: Single `flake.nix` file defining all project outputs
- **Dependency Management**: `flake.lock` for reproducible pinning
- **Structured Outputs**: packages, apps, devShells, checks, etc.
- **Pure Evaluation**: No external environment variables, ensuring reproducibility

Key limitations:
- No runtime parameters (must be defined ahead of time)
- Files must be staged in Git to be visible to flakes
- Still marked as experimental (though widely used)

### Why Use Flakes for Task Running?

1. **Zero Setup**: `nix run .#task` works immediately without installation
2. **Reproducibility**: Same environment across machines and CI/CD
3. **Dependency Management**: Nix ensures exact tool versions
4. **Composition**: Can combine multiple tools seamlessly
5. **No Docker Needed**: Lighter weight than containerization
6. **Cached Evaluation**: Fast after first run due to Nix caching

---

## Part 2: Design Patterns

### Pattern 1: Simple Flake Apps with writeShellApplication

**Best for**: Single-purpose scripts, build steps, deployment tasks

A flake app is the most basic task runner pattern. It defines an executable to run with `nix run`.

```nix
{
  description = "Project task runner";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Define a custom script with dependencies
        buildScript = pkgs.writeShellApplication {
          name = "build";
          runtimeInputs = with pkgs; [ git gnumake gcc nodejs ];
          text = ''
            echo "Building project..."
            make clean
            make build
            echo "Build complete!"
          '';
        };

        # Web server for development
        serveScript = pkgs.writeShellApplication {
          name = "serve";
          runtimeInputs = with pkgs; [ caddy ];
          text = ''
            echo "Serving on http://localhost:8090"
            caddy file-server --listen :8090 --root .
          '';
        };

        # Test runner
        testScript = pkgs.writeShellApplication {
          name = "test";
          runtimeInputs = with pkgs; [ nodejs ];
          text = ''
            echo "Running tests..."
            npm test
            echo "Tests completed!"
          '';
        };

      in
      {
        # Define as packages (optional - makes them reusable)
        packages = {
          build = buildScript;
          serve = serveScript;
          test = testScript;
        };

        # Define as apps (enables 'nix run' execution)
        apps = {
          build = {
            type = "app";
            program = "${buildScript}/bin/build";
          };
          serve = {
            type = "app";
            program = "${serveScript}/bin/serve";
          };
          test = {
            type = "app";
            program = "${testScript}/bin/test";
          };
          default = {
            type = "app";
            program = "${buildScript}/bin/build";
          };
        };

        # Make scripts available in dev shell
        devShells.default = pkgs.mkShell {
          buildInputs = [ buildScript serveScript testScript ];
        };
      }
    );
}
```

**Usage**:
```bash
nix run .#build
nix run .#test
nix run .#serve
nix develop  # Enter shell with all scripts available
```

**Key Features**:
- `writeShellApplication` validates scripts with ShellCheck
- `runtimeInputs` specifies required tools
- `text` contains the script body
- Scripts are reproducible across machines
- No installation step needed

---

### Pattern 2: Multiplexed Task Runner (Single App, Multiple Commands)

**Best for**: Projects with many related tasks (test, lint, format, deploy)

Instead of separate apps for each task, use a single app that dispatches to different commands:

```nix
{
  description = "Multi-task runner";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        taskRunner = pkgs.writeShellApplication {
          name = "task";
          runtimeInputs = with pkgs; [
            nodejs
            python3
            shellcheck
            nixpkgs-fmt
            git
          ];
          text = ''
            set -euo pipefail

            usage() {
              cat << 'USAGE'
            Usage: task [COMMAND]

            Available commands:
              build       Build the project
              test        Run tests
              lint        Run linters (shellcheck, nixpkgs-fmt)
              format      Auto-format code
              clean       Clean build artifacts
              deploy      Deploy the project
              help        Show this help message

            Examples:
              task build
              task test
              task lint
            USAGE
            }

            main() {
              local cmd="''${1:-help}"

              case "$cmd" in
                build)
                  echo "Building project..."
                  npm run build
                  ;;
                test)
                  echo "Running tests..."
                  npm test
                  ;;
                lint)
                  echo "Running linters..."
                  shellcheck scripts/*.sh || true
                  nixpkgs-fmt --check . || true
                  ;;
                format)
                  echo "Formatting code..."
                  nixpkgs-fmt .
                  prettier --write "src/**/*.{js,ts,jsx,tsx}"
                  ;;
                clean)
                  echo "Cleaning build artifacts..."
                  rm -rf node_modules dist build
                  ;;
                deploy)
                  echo "Deploying..."
                  npm run build
                  # deployment commands here
                  ;;
                help|--help|-h)
                  usage
                  ;;
                *)
                  echo "Unknown command: $cmd" >&2
                  usage
                  exit 1
                  ;;
              esac
            }

            main "$@"
          '';
        };
      in
      {
        apps.default = {
          type = "app";
          program = "${taskRunner}/bin/task";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ taskRunner ];
        };
      }
    );
}
```

**Usage**:
```bash
nix run .#  # Show help
nix run .# -- build
nix run .# -- test
nix run .# -- lint
nix run .# -- format
```

**Benefits**:
- Single entry point for all tasks
- Consistent error handling
- Easy discovery with help command
- Can share setup/teardown logic

---

### Pattern 3: Development Shells with Custom Commands

**Best for**: Development-time convenience, integrating with direnv

Development shells let developers enter a Nix environment with tools pre-configured.

```nix
{
  description = "Development environment with custom commands";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
            nodejs
            python3
            postgresql
            redis
            git
            jq
            curl
          ];

          shellHook = ''
            # Set up environment variables
            export PROJECT_NAME="my-project"
            export PYTHONPATH="$PWD/lib:$PYTHONPATH"

            # Display info on shell entry
            echo "Welcome to $PROJECT_NAME development environment"
            echo "Node: $(node --version)"
            echo "Python: $(python3 --version)"

            # Create aliases for common commands
            alias build="npm run build"
            alias test="npm test"
            alias dev="npm run dev"
            alias lint="npm run lint"

            # Helper function to start services
            start-services() {
              echo "Starting PostgreSQL..."
              postgres -D /tmp/postgres-data &
              sleep 2
              
              echo "Starting Redis..."
              redis-server --daemonize yes
              
              echo "Services started!"
            }

            stop-services() {
              echo "Stopping services..."
              pkill postgres || true
              redis-cli shutdown || true
            }
          '';
        };
      }
    );
}
```

**Usage**:
```bash
nix develop
# Inside shell:
build
test
dev
lint
start-services
stop-services
```

**Features**:
- Tools available in PATH without global installation
- Custom functions and aliases
- Environment variable setup
- Service startup/shutdown helpers
- Works with direnv for automatic activation

---

### Pattern 4: Using devenv for Advanced Task Management

**Best for**: Complex workflows, process orchestration, service dependencies

The `devenv` framework provides a higher-level abstraction with built-in process management and task orchestration.

```nix
{
  description = "Advanced development environment with devenv";

  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, devenv, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              # Languages and packages
              packages = with pkgs; [
                nodejs_20
                python3
                postgresql
                redis
              ];

              # Environment variables
              env.PROJECT_NAME = "my-project";
              env.LOG_LEVEL = "debug";

              # Processes that can be started with 'devenv up'
              processes = {
                # PostgreSQL database
                postgres.exec = ''
                  postgres -D "$DEVENV_STATE/postgres" \
                    -k "$DEVENV_STATE" \
                    -p 5432
                '';

                # Redis cache
                redis.exec = "redis-server --port 6379";

                # Application development server
                app.exec = "npm run dev";
              };

              # Tasks - more flexible than processes
              tasks = {
                # Database migrations before starting app
                "db:migrate" = {
                  exec = "npm run migrate";
                  before = [ "devenv:processes:app" ];
                };

                # Linting task
                "lint" = {
                  exec = "npm run lint";
                };

                # Testing task
                "test" = {
                  exec = "npm test";
                  # Can depend on other tasks
                  after = [ "lint" ];
                };

                # Formatting task
                "format" = {
                  exec = "prettier --write .";
                };

                # Build task
                "build" = {
                  exec = "npm run build";
                  after = [ "lint" ];
                };

                # CI pipeline simulation
                "ci" = {
                  exec = "npm ci && npm run lint && npm test && npm run build";
                };
              };

              # Services (higher level than processes)
              services.postgres.enable = true;
              services.redis.enable = true;

              # Startup hook
              enterShell = ''
                echo "Welcome to $PROJECT_NAME development environment"
                echo ""
                echo "Available tasks:"
                devenv tasks list
              '';
            }
          ];
        };
      }
    );
}
```

**Usage**:
```bash
nix develop --no-pure-eval
# Inside shell:
devenv up                    # Start all processes
devenv tasks run db:migrate  # Run specific task
devenv tasks run test        # Run tests
devenv tasks run ci          # Run full CI pipeline
```

**Key Features**:
- Task dependencies (before/after)
- Process management with status checks
- Built-in services (PostgreSQL, Redis, etc.)
- Task input/output with JSON support
- Process health monitoring
- Parallel task execution where possible

---

### Pattern 5: Wrapping Makefile with Nix Apps

**Best for**: Migrating existing projects, keeping familiar workflows

Some projects use Make or Just for task running. Nix flakes can wrap these:

```nix
{
  description = "Project with Makefile wrapped in Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Wrapper around make with all required tools
        makeWrapper = pkgs.writeShellApplication {
          name = "make-project";
          runtimeInputs = with pkgs; [
            gnumake
            gcc
            nodejs
            git
          ];
          text = ''
            cd "''${1:-.}"
            make "''${@:2}"
          '';
        };

        # Just wrapper (if using justfile)
        justWrapper = pkgs.writeShellApplication {
          name = "just-project";
          runtimeInputs = with pkgs; [
            just
            nodejs
            git
          ];
          text = ''
            cd "''${1:-.}"
            just "''${@:2}"
          '';
        };
      in
      {
        apps = {
          # Run make targets
          make = {
            type = "app";
            program = "${makeWrapper}/bin/make-project";
          };

          # Run just recipes
          just = {
            type = "app";
            program = "${justWrapper}/bin/just-project";
          };

          # Convenience targets
          build = {
            type = "app";
            program = "${makeWrapper}/bin/make-project . build";
          };
          test = {
            type = "app";
            program = "${makeWrapper}/bin/make-project . test";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gnumake
            just
            nodejs
            git
          ];
        };
      }
    );
}
```

**Usage**:
```bash
nix run .#make -- build      # Equivalent to: make build
nix run .#just -- build      # Equivalent to: just build
nix develop
make build                    # Inside dev shell
just build
```

**Advantages**:
- Keep existing Makefile/justfile
- Add Nix dependency management
- Enable `nix run` for CI/CD
- Team members don't need make/just installed globally

---

## Part 3: Advanced Patterns

### Modular Flake Organization

For large projects, organize flake.nix into multiple files:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages = import ./nix/packages.nix { inherit pkgs; };
        apps = import ./nix/apps.nix { inherit pkgs packages; };
        devShells = import ./nix/devshells.nix { inherit pkgs; };
        checks = import ./nix/checks.nix { inherit pkgs; };
      }
    );
}
```

```nix
# nix/apps.nix
{ pkgs, packages }:
{
  build = {
    type = "app";
    program = "${packages.buildScript}/bin/build";
  };
  test = {
    type = "app";
    program = "${packages.testScript}/bin/test";
  };
  default = {
    type = "app";
    program = "${packages.buildScript}/bin/build";
  };
}
```

```nix
# nix/devshells.nix
{ pkgs }:
{
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      nodejs
      python3
      git
    ];
  };

  python = pkgs.mkShell {
    buildInputs = with pkgs; [
      python3
      python311Packages.pip
      python311Packages.virtualenv
    ];
  };

  rust = pkgs.mkShell {
    buildInputs = with pkgs; [
      rustup
      cargo
      rustc
    ];
  };
}
```

### Monorepo Task Running

For monorepos with multiple projects:

```nix
{
  description = "Monorepo task runner";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Generic task builder
        mkTask = { name, description, dir, command, runtimeInputs }:
          pkgs.writeShellApplication {
            inherit name runtimeInputs;
            text = ''
              cd "${dir}" || exit 1
              echo "${description}..."
              ${command}
            '';
          };

        # Define tasks for each project
        apiTask = mkTask {
          name = "api-build";
          description = "Building API";
          dir = "packages/api";
          command = "npm run build";
          runtimeInputs = with pkgs; [ nodejs ];
        };

        webTask = mkTask {
          name = "web-build";
          description = "Building Web";
          dir = "packages/web";
          command = "npm run build";
          runtimeInputs = with pkgs; [ nodejs ];
        };
      in
      {
        packages = {
          inherit apiTask webTask;
        };

        apps = {
          api-build = {
            type = "app";
            program = "${apiTask}/bin/api-build";
          };
          web-build = {
            type = "app";
            program = "${webTask}/bin/web-build";
          };
        };
      }
    );
}
```

### Pre-commit Hooks Integration

Run tasks as git pre-commit hooks:

```nix
{
  description = "Development environment with pre-commit hooks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              shellcheck.enable = true;
              prettier.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = with pkgs; [
            nodejs
            shellcheck
            nixpkgs-fmt
          ];
        };
      }
    );
}
```

---

## Part 4: Best Practices

### 1. Clear Command Documentation

Always provide help text and usage examples:

```bash
nix run .# -- --help
nix run .# -- -h
```

### 2. Use writeShellApplication Over writeShellScript

- `writeShellApplication`: Preferred, includes ShellCheck validation
- `writeShellScript`: Older pattern, no validation
- `writeTextFile`: For non-shell scripts

### 3. Dependency Declaration

Be explicit about runtime dependencies:

```nix
runtimeInputs = with pkgs; [
  nodejs          # JavaScript runtime
  git             # Version control
  gnumake         # Build system
  postgresql      # Database
];
```

### 4. Error Handling

Use `set -euo pipefail` in scripts:
- `-e`: Exit on error
- `-u`: Exit on undefined variable
- `-o pipefail`: Fail if any pipe stage fails

```nix
text = ''
  set -euo pipefail
  # Script content
'';
```

### 5. Environment Variable Management

Keep configuration clear and documented:

```nix
env = {
  # Build settings
  NODE_ENV = "production";
  RUST_BACKTRACE = "1";
  
  # Database
  DATABASE_URL = "postgresql://localhost/mydb";
  REDIS_URL = "redis://localhost:6379";
};

# Or for sensitive values, use .env files or runtime configuration
```

### 6. Testing and CI Integration

Always include checks:

```nix
checks = {
  syntax = # Nix syntax validation
  formatting = # Code style checks
  tests = # Unit/integration tests
  types = # Type checking if applicable
};
```

### 7. Reproducibility Checklist

- All dependencies declared in flake.nix
- No reliance on system PATH beyond Nix
- No environment variable dependencies
- flake.lock committed to version control
- Tested in clean environments (CI/CD)

### 8. Performance Optimization

- Use `--no-pure-eval` with devenv (faster evaluation)
- Cache build outputs with `nix.cachix.org`
- Use `nix develop` instead of `nix shell` (faster subsequent runs)
- Profile with `nix eval --json --allow-import-from-derivation`

---

## Part 5: Real-World Examples

### Example 1: Rust Project

```nix
{
  description = "Rust project with task runner";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.stable.latest.default;

        taskRunner = pkgs.writeShellApplication {
          name = "task";
          runtimeInputs = with pkgs; [ rustToolchain cargo ];
          text = ''
            set -euo pipefail

            case "''${1:-help}" in
              build)
                cargo build --release
                ;;
              test)
                cargo test
                ;;
              bench)
                cargo bench
                ;;
              fmt)
                cargo fmt
                ;;
              lint)
                cargo clippy -- -D warnings
                ;;
              doc)
                cargo doc --no-deps --open
                ;;
              *)
                echo "Usage: task {build|test|bench|fmt|lint|doc}"
                ;;
            esac
          '';
        };
      in
      {
        packages.default = taskRunner;

        apps.default = {
          type = "app";
          program = "${taskRunner}/bin/task";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            cargo
            rustfmt
            clippy
            pkg-config
            openssl
          ];

          shellHook = ''
            echo "Rust development environment loaded"
            echo "Run 'nix run .' to see available tasks"
          '';
        };
      }
    );
}
```

### Example 2: Node.js + Python Project

```nix
{
  description = "Node.js and Python monorepo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        runner = pkgs.writeShellApplication {
          name = "task";
          runtimeInputs = with pkgs; [
            nodejs
            python3
            git
            gnumake
          ];
          text = ''
            set -euo pipefail

            BACKEND_DIR="packages/backend"
            FRONTEND_DIR="packages/frontend"

            help() {
              cat << 'EOF'
            Available tasks:
              install       Install all dependencies
              dev           Start development servers
              build         Build for production
              test          Run all tests
              lint          Lint all code
              backend-*     Run backend tasks
              frontend-*    Run frontend tasks
            EOF
            }

            install() {
              (cd "$FRONTEND_DIR" && npm ci)
              (cd "$BACKEND_DIR" && pip install -r requirements.txt)
            }

            dev() {
              # Start both dev servers
              (cd "$FRONTEND_DIR" && npm run dev) &
              (cd "$BACKEND_DIR" && python manage.py runserver) &
              wait
            }

            build() {
              (cd "$FRONTEND_DIR" && npm run build)
              (cd "$BACKEND_DIR" && python manage.py collectstatic)
            }

            test() {
              (cd "$FRONTEND_DIR" && npm test) &&
              (cd "$BACKEND_DIR" && python -m pytest)
            }

            lint() {
              (cd "$FRONTEND_DIR" && npm run lint) || true
              (cd "$BACKEND_DIR" && python -m flake8) || true
            }

            main() {
              case "''${1:-help}" in
                install)
                  install
                  ;;
                dev)
                  dev
                  ;;
                build)
                  build
                  ;;
                test)
                  test
                  ;;
                lint)
                  lint
                  ;;
                help|--help|-h)
                  help
                  ;;
                *)
                  echo "Unknown task: $1" >&2
                  help
                  exit 1
                  ;;
              esac
            }

            main "$@"
          '';
        };
      in
      {
        apps.default = {
          type = "app";
          program = "${runner}/bin/task";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            python3
            git
            gnumake
          ];

          env.PYTHONPATH = "${pkgs.python3}/lib/python3.11/site-packages";
        };
      }
    );
}
```

### Example 3: Docker/Container Project

```nix
{
  description = "Docker multi-service project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        runner = pkgs.writeShellApplication {
          name = "dev";
          runtimeInputs = with pkgs; [
            docker
            docker-compose
            postgresql
            redis
          ];
          text = ''
            set -euo pipefail

            usage() {
              cat << 'EOF'
            Development commands:
              up              Start all services
              down            Stop all services
              logs [service]  View service logs
              shell [service] Access service shell
              migrate         Run database migrations
              seed            Seed database
              reset           Reset everything
            EOF
            }

            main() {
              case "''${1:-help}" in
                up)
                  docker-compose up -d
                  echo "Services started. View logs with: dev logs"
                  ;;
                down)
                  docker-compose down
                  ;;
                logs)
                  docker-compose logs -f "''${2:-}"
                  ;;
                shell)
                  docker-compose exec "''${2:-app}" /bin/bash
                  ;;
                migrate)
                  docker-compose exec app python manage.py migrate
                  ;;
                seed)
                  docker-compose exec app python manage.py seed
                  ;;
                reset)
                  docker-compose down -v
                  docker-compose up -d
                  docker-compose exec app python manage.py migrate
                  echo "Reset complete"
                  ;;
                *)
                  usage
                  ;;
              esac
            }

            main "$@"
          '';
        };
      in
      {
        apps.default = {
          type = "app";
          program = "${runner}/bin/dev";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            docker
            docker-compose
          ];
        };
      }
    );
}
```

---

## Part 6: Troubleshooting

### Issue: "Program not found"

**Cause**: Binary name doesn't match expected output

**Solution**: 
- Use `writeShellApplication` which automatically creates bin/<name>
- Check derivation output with: `nix build .#app --no-link && find result/bin`

### Issue: Missing runtime dependencies

**Cause**: Forgot to add tool to `runtimeInputs`

**Solution**: 
```nix
runtimeInputs = with pkgs; [
  myTool  # Add here!
];
```

### Issue: Scripts fail in nix run but work locally

**Cause**: Local PATH has tools flakes don't

**Solution**: 
- Add all dependencies to `runtimeInputs`
- Test with `--pure` flag: `nix develop --pure`
- Check PATH in script: `echo $PATH`

### Issue: Changes not visible when running

**Cause**: Flakes only see git-tracked files

**Solution**: 
```bash
git add flake.nix
git add nix/apps.nix
nix run .#app
```

### Issue: Very slow evaluation

**Cause**: Pure evaluation mode with devenv

**Solution**: 
```bash
nix develop --no-pure-eval  # Faster
```

---

## Part 7: Integration with CI/CD

### GitHub Actions Example

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: cachix/install-nix-action@v20
        with:
          nix_path: nixpkgs=channel:nixpkgs-unstable
      
      - name: Run tests
        run: nix run .#test
      
      - name: Run linters
        run: nix run .#lint
      
      - name: Build
        run: nix run .#build
```

### GitLab CI Example

```yaml
test:
  image: nixos/nix:latest
  script:
    - nix run .#test
    - nix run .#lint
    - nix run .#build
```

---

## Part 8: Comparison Matrix

| Pattern | Complexity | Best For | Overhead |
|---------|-----------|----------|----------|
| Simple Apps | Low | Single scripts | None |
| Multiplexed Runner | Medium | Multiple related tasks | Bash dispatch |
| Dev Shell | Low | Development only | Small |
| devenv | High | Complex workflows | Framework overhead |
| Make/Just Wrapper | Low | Existing projects | Thin wrapper |

---

## Part 9: Recommended Reading

1. **Official Documentation**
   - https://nix.dev/concepts/flakes.html
   - https://nixos.wiki/wiki/Flakes

2. **Deep Dives**
   - https://tonyfinn.com/blog/nix-from-first-principles-flake-edition/nix-9-runnable-flakes/
   - https://serokell.io/blog/practical-nix-flakes

3. **devenv Documentation**
   - https://devenv.sh/
   - https://devenv.sh/tasks/
   - https://devenv.sh/guides/using-with-flakes/

4. **Tool Integration**
   - Nix-Tasks: https://github.com/clorl/Nix-Tasks
   - nix-task: https://github.com/madjam002/nix-task

---

## Conclusion

Nix Flakes provide multiple, complementary patterns for task running:

1. **Start Simple**: Use `writeShellApplication` for basic tasks
2. **Scale Up**: Use multiplexed runners for many related tasks
3. **Add Complexity**: Use devenv when you need process management
4. **Integrate**: Wrap existing Make/Just files with Nix

The key advantage: **Zero setup for team members**. With Nix installed, anyone can run your project's tasks immediately without installing dependencies.

All patterns share these benefits:
- Reproducible across machines
- Exact version pinning
- No system pollution
- Easy CI/CD integration
- Composition and reusability

Choose the pattern that best fits your project's complexity and team's familiarity with Nix.

