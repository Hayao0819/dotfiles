# Flake Task Runner: Practical Implementation Examples

This document contains copy-paste ready examples for common project types.

---

## Example 1: Node.js/TypeScript Project

### Use Case
- Build, test, lint, format tasks
- Development server
- Production deployment

### Implementation

```nix
# flake.nix
{
  description = "Node.js TypeScript project with task runner";

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
          runtimeInputs = with pkgs; [ nodejs npm ];
          text = ''
            set -euo pipefail

            usage() {
              cat <<'EOF'
            Nextjs Project Tasks

            Commands:
              dev       Start development server on http://localhost:3000
              build     Build for production
              start     Start production server
              test      Run tests (Jest)
              test:watch Run tests in watch mode
              lint      Run ESLint
              format    Format code with Prettier
              type      Check TypeScript types
              clean     Clean node_modules and build artifacts

            Examples:
              task dev
              task test
              task lint
            EOF
            }

            case "''${1:-help}" in
              dev)
                echo "Starting development server..."
                npm run dev
                ;;
              build)
                echo "Building for production..."
                npm run build
                ;;
              start)
                echo "Starting production server..."
                npm start
                ;;
              test)
                echo "Running tests..."
                npm test -- --coverage
                ;;
              test:watch)
                echo "Running tests in watch mode..."
                npm test -- --watch
                ;;
              lint)
                echo "Running linter..."
                npm run lint
                ;;
              format)
                echo "Formatting code..."
                npm run format
                ;;
              type)
                echo "Checking TypeScript types..."
                npm run type-check
                ;;
              clean)
                echo "Cleaning artifacts..."
                rm -rf node_modules .next dist coverage
                ;;
              help|--help|-h)
                usage
                ;;
              *)
                echo "Unknown command: $1"
                usage
                exit 1
                ;;
            esac
          '';
        };
      in
      {
        packages.default = runner;

        apps = {
          default = {
            type = "app";
            program = "${runner}/bin/task";
          };
          dev = {
            type = "app";
            program = "${runner}/bin/task -- dev";
          };
          test = {
            type = "app";
            program = "${runner}/bin/task -- test";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ nodejs npm git ];

          shellHook = ''
            echo "Node.js development environment"
            echo "Node: $(node --version)"
            echo "NPM: $(npm --version)"
            echo ""
            echo "Run 'nix run .' for available tasks"
            
            # Useful aliases
            alias dev="npm run dev"
            alias test="npm test"
            alias lint="npm run lint"
          '';
        };
      }
    );
}
```

### Usage
```bash
nix run .#              # Show help
nix run .#dev          # Start dev server
nix run .# -- build    # Build
nix develop
dev                    # Inside shell - start dev server
test                   # Run tests
```

---

## Example 2: Python/Django Project

### Use Case
- Development with local database
- Testing
- Database migrations
- Code quality tools

### Implementation

```nix
# flake.nix
{
  description = "Django project with PostgreSQL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        python = pkgs.python311;
        pythonPackages = python.pkgs;

        pythonDeps = with pythonPackages; [
          django
          psycopg2
          djangorestframework
          python-dotenv
          black
          flake8
          pytest
          pytest-django
        ];

        runner = pkgs.writeShellApplication {
          name = "task";
          runtimeInputs = with pkgs; [
            python
            postgresql
            redis
          ] ++ pythonDeps;
          text = ''
            set -euo pipefail

            export PYTHONPATH="''${PWD}:$PYTHONPATH"
            export DATABASE_URL="postgresql://localhost/mydb"
            export REDIS_URL="redis://localhost:6379"

            usage() {
              cat <<'EOF'
            Django Project Tasks

            Development:
              dev           Start development server
              shell         Django shell
              migrate       Run database migrations
              makemigrations Create new migrations
              createsuperuser Create admin user

            Testing:
              test          Run tests
              test:fast     Run tests without migrations

            Code Quality:
              lint          Run flake8
              format        Auto-format with black
              check         Check code style

            Database:
              db:reset      Reset database (WARNING: deletes data)
              db:seed       Seed with test data

            Examples:
              task dev
              task test
              task migrate
            EOF
            }

            db:setup() {
              mkdir -p ./data
              initdb -D ./data/postgres 2>/dev/null || true
              postgres -D ./data/postgres -p 5432 &
              sleep 2
              createdb mydb 2>/dev/null || true
            }

            db:cleanup() {
              pkill postgres || true
            }

            main() {
              case "''${1:-help}" in
                dev)
                  db:setup
                  trap db:cleanup EXIT
                  python manage.py migrate
                  python manage.py runserver 0.0.0.0:8000
                  ;;
                shell)
                  db:setup
                  trap db:cleanup EXIT
                  python manage.py shell
                  ;;
                migrate)
                  python manage.py migrate
                  ;;
                makemigrations)
                  python manage.py makemigrations
                  ;;
                createsuperuser)
                  python manage.py createsuperuser
                  ;;
                test)
                  pytest --cov=.
                  ;;
                test:fast)
                  pytest --nomigrations
                  ;;
                lint)
                  flake8 .
                  ;;
                format)
                  black .
                  ;;
                check)
                  black --check .
                  flake8 .
                  python manage.py check
                  ;;
                db:reset)
                  echo "Resetting database..."
                  rm -rf ./data/postgres
                  db:setup
                  python manage.py migrate
                  echo "Database reset complete"
                  db:cleanup
                  ;;
                db:seed)
                  python manage.py seed_data
                  ;;
                help|--help|-h)
                  usage
                  ;;
                *)
                  echo "Unknown command: $1"
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
        packages.default = runner;

        apps.default = {
          type = "app";
          program = "${runner}/bin/task";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python
            postgresql
            redis
            git
          ] ++ pythonDeps;

          shellHook = ''
            export PYTHONPATH="''${PWD}:$PYTHONPATH"
            export DATABASE_URL="postgresql://localhost/mydb"
            
            echo "Django development environment"
            echo "Python: $(python --version)"
            
            alias dev="python manage.py runserver"
            alias test="pytest"
            alias migrate="python manage.py migrate"
          '';
        };
      }
    );
}
```

### Usage
```bash
nix run .# -- dev      # Start dev server with auto-reset DB
nix run .# -- test     # Run tests
nix develop
dev                    # Start dev server (inside shell)
migrate                # Run migrations
```

---

## Example 3: Rust Project

### Use Case
- Compilation and testing
- Benchmarking
- Documentation generation
- Release builds

### Implementation

```nix
# flake.nix
{
  description = "Rust project with comprehensive task runner";

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

        runner = pkgs.writeShellApplication {
          name = "task";
          runtimeInputs = with pkgs; [ rustToolchain cargo ];
          text = ''
            set -euo pipefail

            usage() {
              cat <<'EOF'
            Rust Project Tasks

            Building:
              build         Build in debug mode
              build:release Build optimized release
              check         Check compilation (faster)

            Testing:
              test          Run all tests
              test:lib      Run library tests only
              test:doc      Run documentation tests
              test:bench    Run benchmarks

            Code Quality:
              fmt           Format code
              fmt:check     Check formatting
              lint          Run clippy linter
              doc           Generate documentation

            Development:
              run           Run the binary
              watch         Watch and rebuild on changes

            Examples:
              task build
              task test
              task lint
            EOF
            }

            case "''${1:-help}" in
              build)
                cargo build
                ;;
              build:release)
                cargo build --release
                ;;
              check)
                cargo check
                ;;
              test)
                cargo test --all
                ;;
              test:lib)
                cargo test --lib
                ;;
              test:doc)
                cargo test --doc
                ;;
              test:bench)
                cargo bench
                ;;
              fmt)
                cargo fmt
                ;;
              fmt:check)
                cargo fmt -- --check
                ;;
              lint)
                cargo clippy --all-targets -- -D warnings
                ;;
              doc)
                cargo doc --no-deps --open
                ;;
              run)
                cargo run
                ;;
              watch)
                cargo watch -x build
                ;;
              help|--help|-h)
                usage
                ;;
              *)
                echo "Unknown command: $1"
                usage
                exit 1
                ;;
            esac
          '';
        };
      in
      {
        packages.default = runner;

        apps.default = {
          type = "app";
          program = "${runner}/bin/task";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            cargo
            rustfmt
            clippy
            cargo-watch
            pkg-config
            openssl
          ];

          shellHook = ''
            echo "Rust development environment"
            echo "Rustc: $(rustc --version)"
            echo "Cargo: $(cargo --version)"
          '';
        };
      }
    );
}
```

### Usage
```bash
nix run .# -- build:release   # Optimized build
nix run .# -- test            # Run tests
nix develop
cargo run                      # Inside shell
cargo test
```

---

## Example 4: Monorepo (Multiple Packages)

### Use Case
- Frontend (React)
- Backend (Node.js)
- Shared utilities
- Coordinated tasks

### Implementation

```nix
# flake.nix
{
  description = "Monorepo with frontend and backend";

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
          runtimeInputs = with pkgs; [ nodejs npm git ];
          text = ''
            set -euo pipefail

            FRONTEND_DIR="packages/frontend"
            BACKEND_DIR="packages/backend"

            usage() {
              cat <<'EOF'
            Monorepo Tasks

            Installation:
              install       Install all dependencies

            Development:
              dev           Start both dev servers
              dev:frontend  Start frontend only
              dev:backend   Start backend only

            Building:
              build         Build all packages
              build:frontend Build frontend
              build:backend  Build backend

            Testing:
              test          Test all packages
              test:frontend Test frontend
              test:backend  Test backend

            Linting:
              lint          Lint all packages
              lint:fix      Fix linting issues

            Examples:
              task install
              task dev
              task test
            EOF
            }

            install() {
              echo "Installing dependencies..."
              npm ci --workspace packages/frontend
              npm ci --workspace packages/backend
            }

            dev() {
              echo "Starting development servers..."
              (cd "$FRONTEND_DIR" && npm run dev) &
              (cd "$BACKEND_DIR" && npm run dev) &
              wait
            }

            build() {
              echo "Building all packages..."
              npm run build --workspace packages/frontend
              npm run build --workspace packages/backend
            }

            test() {
              echo "Running tests..."
              npm test --workspace packages/frontend &&
              npm test --workspace packages/backend
            }

            lint() {
              echo "Linting..."
              npm run lint --workspace packages/frontend || true
              npm run lint --workspace packages/backend || true
            }

            main() {
              case "''${1:-help}" in
                install)
                  install
                  ;;
                dev)
                  dev
                  ;;
                dev:frontend)
                  (cd "$FRONTEND_DIR" && npm run dev)
                  ;;
                dev:backend)
                  (cd "$BACKEND_DIR" && npm run dev)
                  ;;
                build)
                  build
                  ;;
                build:frontend)
                  (cd "$FRONTEND_DIR" && npm run build)
                  ;;
                build:backend)
                  (cd "$BACKEND_DIR" && npm run build)
                  ;;
                test)
                  test
                  ;;
                test:frontend)
                  (cd "$FRONTEND_DIR" && npm test)
                  ;;
                test:backend)
                  (cd "$BACKEND_DIR" && npm test)
                  ;;
                lint)
                  lint
                  ;;
                lint:fix)
                  npm run lint:fix --workspace packages/frontend || true
                  npm run lint:fix --workspace packages/backend || true
                  ;;
                help|--help|-h)
                  usage
                  ;;
                *)
                  echo "Unknown command: $1"
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
        packages.default = runner;

        apps.default = {
          type = "app";
          program = "${runner}/bin/task";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ nodejs npm git ];

          shellHook = ''
            echo "Monorepo development environment"
            alias install="npm ci --workspace packages/frontend && npm ci --workspace packages/backend"
            alias dev="nix run ."
          '';
        };
      }
    );
}
```

### Usage
```bash
nix run .# -- install       # Install all deps
nix run .# -- dev          # Start both servers
nix run .# -- test         # Test all
nix run .# -- test:backend # Test backend only
```

---

## Example 5: Docker/Services Stack

### Use Case
- Docker Compose services
- Database setup
- Service orchestration

### Implementation

```nix
# flake.nix
{
  description = "Docker-based development environment";

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
          runtimeInputs = with pkgs; [ docker docker-compose ];
          text = ''
            set -euo pipefail

            COMPOSE_FILE="docker-compose.yml"

            usage() {
              cat <<'EOF'
            Docker Development Environment

            Services:
              up              Start all services
              down            Stop all services
              restart         Restart all services
              logs [service]  View service logs
              ps              Show running services

            Database:
              db:migrate      Run database migrations
              db:seed         Seed database
              db:console      Connect to database

            Debugging:
              shell [service] Open service shell
              inspect [srv]   Inspect container details

            Cleaning:
              clean           Remove containers (keep volumes)
              clean:all       Remove everything (WARNING!)

            Examples:
              dev up
              dev logs api
              dev shell db
            EOF
            }

            up() {
              echo "Starting services..."
              docker-compose -f "$COMPOSE_FILE" up -d
              sleep 2
              docker-compose -f "$COMPOSE_FILE" ps
            }

            down() {
              echo "Stopping services..."
              docker-compose -f "$COMPOSE_FILE" down
            }

            main() {
              case "''${1:-help}" in
                up)
                  up
                  ;;
                down)
                  down
                  ;;
                restart)
                  down
                  up
                  ;;
                logs)
                  docker-compose -f "$COMPOSE_FILE" logs -f "''${2:-}"
                  ;;
                ps)
                  docker-compose -f "$COMPOSE_FILE" ps
                  ;;
                db:migrate)
                  docker-compose -f "$COMPOSE_FILE" exec api npm run migrate
                  ;;
                db:seed)
                  docker-compose -f "$COMPOSE_FILE" exec api npm run seed
                  ;;
                db:console)
                  docker-compose -f "$COMPOSE_FILE" exec db psql -U postgres mydb
                  ;;
                shell)
                  docker-compose -f "$COMPOSE_FILE" exec "''${2:-api}" /bin/bash
                  ;;
                inspect)
                  docker inspect "''${2:-myproject-api-1}"
                  ;;
                clean)
                  docker-compose -f "$COMPOSE_FILE" down
                  ;;
                clean:all)
                  echo "WARNING: Removing all containers and volumes..."
                  docker-compose -f "$COMPOSE_FILE" down -v
                  ;;
                help|--help|-h)
                  usage
                  ;;
                *)
                  echo "Unknown command: $1"
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
        packages.default = runner;

        apps.default = {
          type = "app";
          program = "${runner}/bin/dev";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ docker docker-compose git ];
        };
      }
    );
}
```

### Usage
```bash
nix run .# -- up            # Start services
nix run .# -- logs api      # View logs
nix run .# -- shell db      # Access database
```

---

## Tips for Adaptation

1. **Customize commands**: Modify case statements for your project's tasks
2. **Add environments**: Define different shells for different purposes
3. **Environment variables**: Use `export VARNAME="value"` in scripts
4. **Error handling**: Add `|| true` to optional commands
5. **Documentation**: Update usage() with your actual tasks
6. **Dependencies**: Add packages to `runtimeInputs` for tools you need

---

## Testing Your Flake

```bash
# Validate syntax
nix flake check

# Show available apps
nix flake show

# Test in pure environment
nix run --pure .#

# Enter dev shell
nix develop

# Run specific task
nix run .#taskname
```

