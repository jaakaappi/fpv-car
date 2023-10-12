# fpv-car

- Install Raspbian **32bit** Lite on your raspi. uv4l does not support 64bit!
- Install `uv4l` from https://www.linux-projects.org/2022/04/25/installation-instructions-of-uv4l-for-bullseye-raspberry-pi-os/
- Install `tmux` or `screen` to have a split terminal
- Start stream in foreground with `uv4l --auto-video_nr --driver raspicam --encoding h264 --width 1280 --height 720 --framerate 20 --server-option '--port=9000' --server-option '–webrtc-hw-vcodec-maxbitrate 1000' -f --output-buffers 1 --hflip --vflip`. Stream is accessible in http://<raspi-ip>:9000/stream

`sudo service uv4l_raspicam stop` to kill background process if not running with `-f`

`wpa_cli -i wlan0 disconnect`

`tmux`
`ctrl b %`
`ctrl b <- ->`
