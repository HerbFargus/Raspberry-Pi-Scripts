Thanks to https://github.com/jacksonliam/mjpg-streamer and https://miguelmota.com/blog/raspberry-pi-camera-board-video-streaming/

# Raspberry-Pi-Live-Video-Stream
A collection of scripts/ how tos to make mjpg streaming work

# Install dev version of libjpeg
```sudo apt-get install libjpeg62-dev```

# Install cmake
```sudo apt-get install cmake```

# Download mjpg-streamer with raspicam plugin
```git clone https://github.com/jacksonliam/mjpg-streamer.git ~/mjpg-streamer```

# Change directory
```cd ~/mjpg-streamer/mjpg-streamer-experimental```

# Compile
```make clean all``

# Replace old mjpg-streamer
```sudo rm -rf /opt/mjpg-streamer```
```sudo mv ~/mjpg-streamer/mjpg-streamer-experimental /opt/mjpg-streamer```
```sudo rm -rf ~/mjpg-streamer```

# Begin streaming
```LD_LIBRARY_PATH=/opt/mjpg-streamer/ /opt/mjpg-streamer/mjpg_streamer -i "input_raspicam.so -fps 15 -q 50 -x 640 -y 480" -o "output_http.so -p 9000 -w /opt/mjpg-streamer/www" &```
