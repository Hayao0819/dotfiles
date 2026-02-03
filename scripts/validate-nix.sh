#!/usr/bin/env bash

# Comprehensive Nix Flake Validation Script
# This script performs both syntax and runtime validation of Nix configurations

set -eEuo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common.sh"

# Exit codes are exported from common.sh (uppercase for constants)
# EXIT_SUCCESS, EXIT_SYNTAX_ERROR, EXIT_RUNTIME_ERROR, EXIT_PACKAGE_ERROR

# Initialize error counters (uppercase for script-wide state variables)
TOTAL_ERRORS=0
SYNTAX_ERRORS=0
RUNTIME_ERRORS=0
PACKAGE_ERRORS=0

# Override log_error to track errors
log_error() {
    print_error "$1"
    track_error "TOTAL"
}

# 1. Basic syntax validation
validate_syntax() {
    print_separator
    log_info "Phase 1: Syntax Validation"
    print_separator

    log_info "Running basic flake check..."
    if nix_cmd flake check 2>&1 | tee /tmp/nix-check.log; then
        log_success "Basic syntax check passed"
    else
        log_error "Basic syntax check failed"
        track_error "SYNTAX"
        return 1
    fi

    # Check for ignored errors
    if grep -q "error (ignored)" /tmp/nix-check.log; then
        log_warning "Found ignored errors in flake check:"
        grep "error (ignored)" /tmp/nix-check.log | head -10
    fi
}

# 2. Validate all configurations can be evaluated
validate_configurations() {
    print_separator
    log_info "Phase 2: Configuration Evaluation"
    print_separator

    # Get all configuration types
    local config_types=("nixosConfigurations" "homeConfigurations" "darwinConfigurations")

    for config_type in "${config_types[@]}"; do
        log_info "Checking ${config_type}..."

        # Check if configuration type exists
        if ! nix_cmd eval --quiet ".#${config_type}" 2> /dev/null; then
            log_info "No ${config_type} defined, skipping"
            continue
        fi

        # Get list of configurations
        local configs
        # Try different methods to get configuration names
        configs=$(nix_cmd flake show . --json 2> /dev/null | jq -r ".${config_type} | keys[]?" 2> /dev/null || echo "")

        # Fallback to parsing text output if JSON doesn't work
        if [[ -z "${configs}" ]]; then
            configs=$(nix_cmd flake show . 2>&1 | grep -A20 "${config_type}" | grep "│.*├\|│.*└" | sed 's/.*─//g' | sed 's/:.*//' | tr -d ' ' || echo "")
        fi

        if [[ -z "${configs}" ]]; then
            log_warning "Could not enumerate ${config_type}"
            continue
        fi

        # Validate each configuration
        while IFS= read -r config; do
            log_info "  Validating ${config_type}.${config}..."

            case "${config_type}" in
                nixosConfigurations)
                    if nix_cmd eval --quiet ".#${config_type}.${config}.config.system.build.toplevel" --apply 'x: null' 2> /tmp/nix-eval-error.log; then
                        log_success "  ✓ ${config}"
                    else
                        log_error "  ✗ ${config} - Failed to evaluate"
                        cat /tmp/nix-eval-error.log
                        track_error "RUNTIME"
                    fi
                    ;;
                homeConfigurations)
                    if nix_cmd eval --quiet ".#${config_type}.${config}.activationPackage" --apply 'x: null' 2> /tmp/nix-eval-error.log; then
                        log_success "  ✓ ${config}"
                    else
                        log_error "  ✗ ${config} - Failed to evaluate"
                        cat /tmp/nix-eval-error.log
                        track_error "RUNTIME"
                    fi
                    ;;
                darwinConfigurations)
                    if nix_cmd eval --quiet ".#${config_type}.${config}.system" --apply 'x: null' 2> /tmp/nix-eval-error.log; then
                        log_success "  ✓ ${config}"
                    else
                        log_error "  ✗ ${config} - Failed to evaluate"
                        cat /tmp/nix-eval-error.log
                        track_error "RUNTIME"
                    fi
                    ;;
                *)
                    log_warning "Unknown configuration type: ${config_type}"
                    ;;
            esac
        done <<< "${configs}"
    done
}

# 3. Validate package references and derivations
validate_packages() {
    print_separator
    log_info "Phase 3: Package & Derivation Validation"
    print_separator

    local config_types=("nixosConfigurations" "homeConfigurations")

    for config_type in "${config_types[@]}"; do
        # Check if configuration type exists
        if ! nix_cmd eval --quiet ".#${config_type}" 2> /dev/null; then
            continue
        fi

        local configs
        # Try different methods to get configuration names
        configs=$(nix_cmd flake show . --json 2> /dev/null | jq -r ".${config_type} | keys[]?" 2> /dev/null || echo "")

        # Fallback to parsing text output if JSON doesn't work
        if [[ -z "${configs}" ]]; then
            configs=$(nix_cmd flake show . 2>&1 | grep -A20 "${config_type}" | grep "│.*├\|│.*└" | sed 's/.*─//g' | sed 's/:.*//' | tr -d ' ' || echo "")
        fi

        while IFS= read -r config; do
            if [[ -z "${config}" ]]; then
                continue
            fi

            log_info "Dry-run build for ${config_type}.${config}..."

            case "${config_type}" in
                nixosConfigurations)
                    if nix_cmd build --dry-run \
                        ".#${config_type}.${config}.config.system.build.toplevel" 2>&1 | tee /tmp/nix-dry-run.log | grep -q "will be built"; then
                        log_success "  ✓ All packages resolvable for ${config}"
                    else
                        if grep -q "error:" /tmp/nix-dry-run.log; then
                            log_error "  ✗ Package resolution failed for ${config}"
                            grep "error:" /tmp/nix-dry-run.log | head -5
                            track_error "PACKAGE"
                        else
                            log_success "  ✓ All packages cached for ${config}"
                        fi
                    fi
                    ;;
                homeConfigurations)
                    if nix_cmd build --dry-run \
                        ".#${config_type}.${config}.activationPackage" 2>&1 | tee /tmp/nix-dry-run.log | grep -q "will be built"; then
                        log_success "  ✓ All packages resolvable for ${config}"
                    else
                        if grep -q "error:" /tmp/nix-dry-run.log; then
                            log_error "  ✗ Package resolution failed for ${config}"
                            grep "error:" /tmp/nix-dry-run.log | head -5
                            track_error "PACKAGE"
                        else
                            log_success "  ✓ All packages cached for ${config}"
                        fi
                    fi
                    ;;
            esac
        done <<< "${configs}"
    done
}

# 4. Check for common issues
check_common_issues() {
    print_separator
    log_info "Phase 4: Common Issues Check"
    print_separator

    # Check for infinite recursion patterns
    log_info "Checking for potential infinite recursion..."
    if grep -r "config\." --include="*.nix" . 2> /dev/null | grep -v "mkIf" | grep -v "^#" | head -5 > /tmp/recursion-check.txt; then
        if [[ -s /tmp/recursion-check.txt ]]; then
            log_warning "Found config references without mkIf (potential infinite recursion):"
            cat /tmp/recursion-check.txt
        fi
    fi

    # Check for unknown package references
    log_info "Scanning for suspicious package references..."
    if grep -r "pkgs\.\w\+" --include="*.nix" . 2> /dev/null | grep -E "pkgs\.[a-z0-9_-]{20,}" | head -5 > /tmp/suspicious-pkgs.txt; then
        if [[ -s /tmp/suspicious-pkgs.txt ]]; then
            log_warning "Found unusually long package names (might be typos):"
            cat /tmp/suspicious-pkgs.txt
        fi
    fi
}

# 5. Validate specific problematic packages
validate_specific_packages() {
    print_separator
    log_info "Phase 5: Specific Package Validation"
    print_separator

    # Test evaluation of commonly problematic packages
    local test_packages=(
        "pkgs.hello"
        "pkgs.git"
        "pkgs.vim"
    )

    for pkg in "${test_packages[@]}"; do
        log_info "Testing ${pkg}..."
        if nix_cmd eval --quiet \
            --impure --expr "with import <nixpkgs> {}; ${pkg}" 2> /dev/null; then
            log_success "  ✓ ${pkg} is available"
        else
            log_warning "  ⚠ ${pkg} might not be available in current nixpkgs"
        fi
    done
}

# Main execution
main() {
    print_box_header "Comprehensive Nix Flake Validation Tool"
    echo

    check_flake_exists

    # Run all validation phases
    validate_syntax || true
    validate_configurations || true
    validate_packages || true
    check_common_issues || true

    # Final report
    print_separator
    echo
    print_box_header "VALIDATION SUMMARY"
    echo
    print_error_summary
    echo

    if [[ ${TOTAL_ERRORS} -eq 0 ]]; then
        log_success "✨ All validation checks passed!"
        exit ${EXIT_SUCCESS}
    else
        log_error "❌ Validation failed with ${TOTAL_ERRORS} error(s)"
        if [[ ${SYNTAX_ERRORS} -gt 0 ]]; then
            exit ${EXIT_SYNTAX_ERROR}
        elif [[ ${PACKAGE_ERRORS} -gt 0 ]]; then
            exit ${EXIT_PACKAGE_ERROR}
        else
            exit ${EXIT_RUNTIME_ERROR}
        fi
    fi
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
