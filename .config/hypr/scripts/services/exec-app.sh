#!/usr/bin/env bash

is_installed() {
  command -v "$1" >/dev/null 2>&1
}

if is_installed "$1"; then
  exec "$@"
fi
