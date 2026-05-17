#!/bin/bash
# Script de lancement llama.cpp (Ubuntu 25.04 / WSL2)
# Prerequisite : sudo apt install libcublas-dev-12-6

set -e
cd /home/neowh/llama.cpp/build

# Chemins CUDA critiques (WSL2)
export PATH=/usr/local/cuda-12.6/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.6/targets/x86_64-linux/lib:/usr/lib/wsl/lib

MODE="${1:-server}"
GGUF="/tmp/Qwen2.5-7B-Q4_K_S.gguf"

case "$MODE" in
  server)
    echo "[GPU] Start llama-server on :8081"
    bin/llama-server \
      --model "$GGUF" \
      --host 127.0.0.1 \
      --port 8081 \
      --n-gpu-layers 99 \
      --n-threads 4 \
      --log-disable
    ;;
  cli)
    echo "[GPU] Start llama-cli (chat)"
    bin/llama-cli \
      --model "$GGUF" \
      --n-gpu-layers 99 \
      --n-threads 4
    ;;
  *)
    echo "Usage: $0 [server|cli]"
    exit 1
    ;;
esac
