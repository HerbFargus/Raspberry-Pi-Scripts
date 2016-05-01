
#!/bin/bash

# This will go into each subdirectory and run a command

for f in ~/Desktop/BOMBERMAN_SPRITES/ANI_BACKUP/*;
  do
     [ -d $f ] && cd "$f" && file=$(find . -name '*.ANI') && ./ab_aniex $file
  done;
