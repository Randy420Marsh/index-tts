#Quick setup readme...

#Might need these:

#sudo apt install -y libpython3.11 libpython3.11-dev ffmpeg libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev

uv python pin 3.11

uv venv .venv --python 3.11

source ./.venv/bin/activate

uv pip install -r requirements-py311-ubuntu2204.txt

#rtx_tuner.py
#is a gpu overclock and monitor, needs root 
#run in separate terminal

#source ./.venv/bin/activate && \
#sudo -v && \
#python rtx_tuner.py

#or by 
#bash gpu-monitor.sh

#uv run webui.py
#or check

./launch.sh
