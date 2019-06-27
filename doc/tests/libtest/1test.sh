#! /usr/bin/env bash

#TODO Cannibalized from ghidra launcher
SCRIPT_FILE="$(readlink -f "$0" 2>/dev/null || readlink "$0" 2>/dev/null || echo "$0")"
SCRIPT_DIR="${SCRIPT_FILE%/*}"

nix eval -f "$SCRIPT_DIR/run_tests.nix" result --show-trace
