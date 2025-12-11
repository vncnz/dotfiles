#!/usr/bin/env bash
set -e

DEST_DIR="$HOME/.local/bin"

# Se viene passato un argomento, è il nome del binario
if [[ -n "$1" ]]; then
    BIN_NAME="$1"
else
    # Prova a rilevare automaticamente il binario dal manifest
    BIN_COUNT=$(cargo metadata --no-deps --format-version 1 | jq '.packages[0].targets | map(select(.kind[] == "bin")) | length')
    if [[ "$BIN_COUNT" -eq 1 ]]; then
        BIN_NAME=$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[0].targets | map(select(.kind[] == "bin"))[0].name')
        echo -e "\033[0;36mDetected single binary:\033[0m $BIN_NAME"
    else
        echo -e "\033[0;31mMultiple binaries detected.\033[0m"
        echo -e "Usage: $0 <binary_name>"
        exit 1
    fi
fi

SRC_PATH="$(pwd)/target/release/$BIN_NAME"
DEST_PATH="$DEST_DIR/$BIN_NAME"

echo -e "\033[0;34mBuilding $BIN_NAME in $(pwd)...\033[0m"
cargo build --release --bin "$BIN_NAME"

PID=$(pgrep -x "$BIN_NAME" || true)
WAS_RUNNING=false

if [[ -n "$PID" ]]; then
    echo -e "\033[0;33m$BIN_NAME is running (pid: $PID), stopping it...\033[0m"
    kill "$PID"
    WAS_RUNNING=true
    sleep 0.5
fi

echo -e "\033[0;34mCopying binary to $DEST_PATH...\033[0m"
cp "$SRC_PATH" "$DEST_PATH"

echo -e "\033[0;32m$BIN_NAME built and copied successfully.\033[0m"

if [[ "$WAS_RUNNING" = true ]]; then
    echo -e "\033[0;34mRestarting $BIN_NAME with nohup...\033[0m"
    nohup "$DEST_PATH" >/dev/null 2>&1 &
    echo -e "\033[0;32m$BIN_NAME restarted.\033[0m"
fi
