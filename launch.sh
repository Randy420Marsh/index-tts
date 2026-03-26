#!/bin/bash

# Determine max CPU threads
MAX_THREADS=$(nproc)
export TORCH_CUDA_ARCH_LIST="7.5"
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

###############################
# ffmpeg and CUDA paths
###############################
# Force TorchAudio to look for your specific FFmpeg version
export TORCHAUDIO_USE_FFMPEG_VERSION=8 

# Ensure the linker finds your custom build libs and CUDA 12.8 first
export LD_LIBRARY_PATH=/home/john/build_temp/lib:/usr/local/cuda-12.8/lib64:/usr/local/lib:$LD_LIBRARY_PATH
export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}

echo "--- System Check ---"
echo "Current User: $USER"
nvcc --version | grep release
###############################

# --- VENV CHECK ---
if [ ! -d ".venv" ]; then
    echo "Creating new virtual environment..."
    uv venv .venv --python 3.11
    source .venv/bin/activate
    echo "Installing core stack (Torch 2.8.0 + CU128)..."
    uv pip install "torch==2.8.0+cu128" "torchaudio==2.8.0+cu128" "torchvision==0.23.0+cu128" --extra-index-url https://download.pytorch.org/whl/cu128
    uv pip install -r pyproject.toml
else
    echo "Virtual environment found."
    source .venv/bin/activate
fi

# --- PRE-FLIGHT DIAGNOSTIC ---
echo "Verifying environment stability..."
python3 << END
import torch
import torchaudio
import sys

print(f"Python: {sys.version.split()[0]}")
print(f"PyTorch: {torch.__version__} (CUDA: {torch.version.cuda})")
print(f"CUDA Available: {torch.cuda.is_available()}")

if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)} (Arch: {torch.cuda.get_device_capability(0)})")

# Check FFmpeg linkage
try:
    backends = torchaudio.list_audio_backends()
    print(f"Audio Backends: {backends}")
    # Verify we aren't hitting the OSError from missing .so files
    from torch.utils.cpp_extension import CUDA_HOME
    print(f"Compiler Path: {CUDA_HOME}")
except Exception as e:
    print(f"ENVIRONMENT ERROR: {e}")
    sys.exit(1)
END

if [ $? -ne 0 ]; then
    echo "Diagnostic failed. Environment is still missing binary dependencies."
    exit 1
fi

echo "Launching IndexTTS with --fp16 --cuda_kernel..."
# Run with your existing flags
uv run webui.py --fp16 --cuda_kernel --gui_seg_tokens 100
