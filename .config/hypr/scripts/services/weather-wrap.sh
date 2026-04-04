#!/usr/bin/env bash
# Wrapper script for weather integration

SCRIPT_DIR="$(dirname "$0")"
PY_SCRIPT="$SCRIPT_DIR/Weather.py"
BASH_FALLBACK="$SCRIPT_DIR/weather.sh"

# Check network connectivity
check_network() {
  curl --silent --max-time 3 -o /dev/null https://1.1.1.1
}

# If no network, return offline status immediately
if ! check_network; then
  echo '{"text":"󰖪", "alt":"Offline", "tooltip":"No network connection"}'
  exit 0
fi

run_fallback() {
  if [[ -f "$BASH_FALLBACK" ]]; then
    bash "$BASH_FALLBACK" "$@"
    return $?
  else
    echo "Weather fallback not found: $BASH_FALLBACK" >&2
    return 127
  fi
}

if command -v python3 >/dev/null 2>&1; then
  if [[ -f "$PY_SCRIPT" ]]; then
    python3 "$PY_SCRIPT" "$@"
    exit_code=$?
    if [[ "$exit_code" -eq 0 ]]; then
      exit 0
    fi
    echo "Weather.py failed with code $exit_code — falling back to weather.sh" >&2
  else
    echo "Weather.py not found: $PY_SCRIPT — falling back to weather.sh" >&2
  fi
  run_fallback "$@"
  exit $?
else
  echo "python3 not found in PATH — falling back to weather.sh" >&2
  run_fallback "$@"
  exit $?
fi
