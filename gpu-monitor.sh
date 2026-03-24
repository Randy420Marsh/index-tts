#!/usr/bin/sh

source ./.venv/bin/activate && \
sudo -v && \
python rtx_tuner.py
