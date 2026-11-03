#!/usr/bin/env bash
set -euo pipefail

report_resources() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
  df -h / /nix
  if [[ "$OSTYPE" == linux* ]]; then
    df -i / /nix
    free -h
    ps -eo pid,ppid,comm,%cpu,%mem,rss --sort=-rss | sed -n '1,12p'
  else
    vm_stat
  fi
}

monitor_resources() {
  local sleep_pid=""
  trap 'if [[ -n "$sleep_pid" ]]; then kill "$sleep_pid" 2>/dev/null || true; fi; exit 0' TERM INT
  while true; do
    report_resources
    sleep 60 &
    sleep_pid=$!
    wait "$sleep_pid"
  done
}

monitor_resources &
monitor_pid=$!

cleanup() {
  local result=$?
  trap - EXIT
  kill "$monitor_pid" 2>/dev/null || true
  wait "$monitor_pid" 2>/dev/null || true
  report_resources || true
  exit "$result"
}
trap cleanup EXIT

nix build "$@" --show-trace --accept-flake-config --no-link --print-build-logs --no-fallback
