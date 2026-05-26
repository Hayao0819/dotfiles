# Intel SGX SDK for Linux.
#
# Resurrected from nixpkgs prior to commit c7beca362b ("sgx-sdk: drop",
# 2026-02-11). Layout preserves the upstream `sdk` / `samples` split so the
# relative `callPackage ../samples` inside `sdk/default.nix` keeps working and
# the eventual upstream PR can move these directories back under
# `pkgs/os-specific/linux/sgx/` unchanged.
{ callPackage }: callPackage ./sdk { }
