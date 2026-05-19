#!/bin/bash
# llama-server multi-model launcher
# Usage: ./start-llama.sh [30b|35b|32b|vision]

export PATH=/usr/local/cuda-12.6/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.6/targets/x86_64-linux/lib:/usr/lib/wsl/lib

M="$HOME/models"
PORT=8081
CTX=98304
MMPROJ=""

case "${1:-30b}" in
  30b)
    MODEL="$M/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf"
    echo "[llama] Qwen3-Coder-30B-A3B Q4_K_M — 98k ctx"
    ;;
  35b)
    MODEL="$M/Qwen3.6-35B-A3B-UD-Q3_K_S.gguf"
    MMPROJ="$M/mmproj-F32.gguf"
    CTX=65536
    echo "[llama] Qwen3.6-35B-A3B UD-Q3_K_S + vision — 65k ctx"
    ;;
  32b)
    MODEL="$M/Qwen2.5-Coder-32B-Q4_K_M.gguf"
    CTX=32768
    echo "[llama] Qwen2.5-Coder-32B Q4_K_M — 32k ctx"
    ;;
  vision)
    MODEL="$M/Qwen_Qwen2.5-VL-7B-Instruct-Q4_K_M.gguf"
    MMPROJ="$M/mmproj-Qwen_Qwen2.5-VL-7B-Instruct-f16.gguf"
    CTX=32768
    echo "[llama] Qwen2.5-VL-7B Q4_K_M + vision — 32k ctx"
    ;;
  *)
    echo "Usage: $0 [30b|35b|32b|vision]"
    exit 1
    ;;
esac

echo "[llama] Port: $PORT | CTX: $CTX"

EXTRA_ARGS=()
[ -n "$MMPROJ" ] && EXTRA_ARGS+=(--mmproj "$MMPROJ")

exec ~/llama.cpp/build/bin/llama-server \
  --model "$MODEL" \
  "${EXTRA_ARGS[@]}" \
  --host 127.0.0.1 \
  --port $PORT \
  --ctx-size $CTX \
  --n-gpu-layers 99 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0
