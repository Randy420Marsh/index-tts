#!/usr/bin/env bash
python -c "
import gc
import torch

# Force garbage collection first
gc.collect()

if torch.cuda.is_available():
    try:
        torch.cuda.empty_cache()
        torch.cuda.synchronize()  # This can still fail if critically low
        print('✅ VRAM cache cleared!')
    except RuntimeError as e:
        print('⚠️ empty_cache failed (likely due to fragmentation):', e)
        print('Try killing processes first or rebooting the GPU driver.')
else:
    print('No CUDA available.')
"
