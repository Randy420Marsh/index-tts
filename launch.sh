#!/bin/bash

# Determine max CPU threads
MAX_THREADS=$(nproc)

#export TORCH_CUDA_ARCH_LIST="7.5"

echo "Current User: $USER"
echo "Launching IndexTTS2 with low-VRAM fixes..."

# Activate virtual environment
source .venv/bin/activate

# === CRITICAL FIX for your 8 GB card (prevents fragmentation OOM) ===
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# Optional extra speed/VRAM tweaks (uncomment if you want)
# export CUDA_VISIBLE_DEVICES=0
# --gui_seg_tokens 80   (smaller segments = less peak VRAM + faster)

echo "Launching with --fp16 --deepspeed..."

#You need to install cuda, maybe...
export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
echo "Switched to CUDA 12.8"
nvcc --version | grep release

# Run with your existing flags + the fix
uv run webui.py --fp16 --cuda_kernel --gui_seg_tokens 120 --deepspeed
