#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H%M%S")

raspistill -o /home/pi/camera/$DATE.jpg