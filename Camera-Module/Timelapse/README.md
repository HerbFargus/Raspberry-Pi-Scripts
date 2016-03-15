# Raspberry-Pi-Time-Lapse

Just a simple how to on getting a timelapse working with a raspberry pi.

`sudo raspi-config`

Enable camera and reboot

`mkdir camera`

### Create Camera Script

`sudo nano /home/pi/camera.sh`

```
#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H%M%S")

raspistill -o /home/pi/camera/$DATE.jpg
```

`sudo chmod +x ./camera.sh`

## Set up Timelapse with crontab

crontab -e

`* * * * * /home/pi/camera.sh 2>&1`
```
# +---------------- minute (0 - 59)
# |  +------------- hour (0 - 23)
# |  |  +---------- day of month (1 - 31)
# |  |  |  +------- month (1 - 12)
# |  |  |  |  +---- day of week (0 - 6) (Sunday=0 or 7)
# |  |  |  |  |
  *  *  *  *  *  command to be executed
```
so for example if you wanted it every 10 minutes:

`*/10 * * * * /home/pi/camera.sh 2>&1`

navigate to camera folder:

`ls *.jpg > stills.txt`

`sudo apt-get install mencoder`

```
mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:aspect=16/9:vbitrate=8000000 -vf scale=1920:1080 -o timelapse.avi -mf type=jpeg:fps=24 mf://@stills.txt
```