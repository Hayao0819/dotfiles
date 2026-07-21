# Opus is unreachable through the proxy; use plain `claude` for it.

port="${CCP_PORT:-18765}"
model="${CLAUDE_SOL_MODEL:-gpt-5.6-sol[1m]}"
fast_model="${CLAUDE_SOL_FAST_MODEL:-gpt-5.6-luna[1m]}"

# The proxy keeps its own credential store, so gate on its auth status and run
# the browser login on first use rather than failing later with a 401.
if ! claude-code-proxy codex auth status >/dev/null 2>&1; then
  echo "claude-sol: not signed in to claude-code-proxy; opening browser login..." >&2
  claude-code-proxy codex auth login
fi

port_open() {
  (exec 3<>"/dev/tcp/127.0.0.1/${port}") 2>/dev/null
}

if ! port_open; then
  nohup claude-code-proxy serve >/dev/null 2>&1 &
  disown
  for ((i = 0; i < 40; i++)); do
    if port_open; then break; fi
    sleep 0.1
  done
  if ! port_open; then
    echo "claude-sol: claude-code-proxy did not come up on port ${port}" >&2
    exit 1
  fi
fi

export ANTHROPIC_BASE_URL="http://127.0.0.1:${port}"
export ANTHROPIC_AUTH_TOKEN="unused"
export ANTHROPIC_MODEL="${model}"
export ANTHROPIC_SMALL_FAST_MODEL="${fast_model}"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW="272000"
export CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK="1"

exec claude "$@"
