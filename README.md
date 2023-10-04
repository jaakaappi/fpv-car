# fpv-car

* Install Raspbian **32bit** Lite on your raspi. uv4l does not support 64bit!
* Install `uv4l` from https://www.linux-projects.org/2022/04/25/installation-instructions-of-uv4l-for-bullseye-raspberry-pi-os/
* Start stream in foreground with `uv4l --auto-video_nr --driver raspicam --quality 10 --encoding h264 --width 1280 --height 720 --framerate 60 --server-option '--port=9000' -f`. Stream is accessible in http://<raspi-ip>:9000/stream

`sudo service uv4l_raspicam stop` to kill background process if not running with `-f`
