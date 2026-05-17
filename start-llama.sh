#!/bin/bash
# llama-server multi-model launcher
# Usage: ./start-llama.sh [30b|7b|32b|9b]

export PATH=/usr/local/cuda-12.6/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.6/targets/x86_64-linux/lib:/usr/lib/wsl/lib

LM="/mnt/c/LM Studio/models"
PORT=8081
CTX=65536

case "${1:-30b}" in
  30b)
    MODEL="$LM/lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-GGUF/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf"
    echo "[llama] Qwen3-Coder-30B-A3B (MoE) - 65k ctx"
    ;;
  32b)
    MODEL="$LM/lmstudio-community/Qwen2.5-Coder-32B-GGUF/Qwen2.5-Coder-32B-Q4_K_M.gguf"
    CTX=32768
    echo "[llama] Qwen2.5-Coder-32B - 32k ctx"
    ;;
  7b)
    MODEL="$LM/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF/Qwen2.5-Coder-7B-Instruct-Q4_K_S.gguf"
    echo "[llama] Qwen2.5-Coder-7B - 65k ctx (fast)"
    ;;
  9b)
    MODEL="$LM/Jackrong/Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF/Qwen3.5-9B.Q4_K_M.gguf"
    echo "[llama] Qwen3.5-9B Reasoning - 65k ctx"
    ;;
  *)
    echo "Usage: $0 [30b|7b|32b|9b]"
    exit 1
    ;;
esac

echo "[llama] Port: $PORT | CTX: $CTX"
exec ~/llama.cpp/build/bin/llama-server \
  --model "$MODEL" \
  --host 127.0.0.1 \
  --port $PORT \
  --ctx-size $CTX \
  --n-gpu-layers 99