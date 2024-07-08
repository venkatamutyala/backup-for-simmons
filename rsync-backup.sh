#!/bin/bash

set -e

# Define the mount points and network shares
MOUNT1="/mnt/qnap/tvshows"
SHARE1="//plexd.randrservices.com/PlexData/TV Shows"
MOUNT2="/mnt/plexserver2/"
SHARE2="//plexs.randrservices.com/PlexData2"
MOUNT3="/mnt/plexserver/"
SHARE3="//plexs.randrservices.com/PlexData"
MOUNT4="/mnt/itunes/"
SHARE4="//plexs.randrservices.com/iTunes"


# Function to check and mount if not already mounted using findmnt
mount_if_needed() {
    local share=$1
    local mountpoint=$2

    # Ensure the mount point directory exists
    if [ ! -d "$mountpoint" ]; then
        echo "Creating mount point $mountpoint"
        mkdir -p "$mountpoint"
    fi

    # Use findmnt to check if the mount point is already used
    if findmnt -rno TARGET "$mountpoint" > /dev/null; then
        echo "$mountpoint is already mounted."
    else
        echo "Attempting to mount $share to $mountpoint"
        mount.cifs "$share" "$mountpoint" -o user=$SYNC_USERNAME,password=$SYNC_PASSWORD,vers=2.1
        if [ $? -ne 0 ]; then
            echo "Failed to mount $share on $mountpoint"
            dmesg | tail -10  # Display the last 10 kernel log messages to help diagnose the issue
        fi
    fi
}

# Mount the shares to the specified mount points
mount_if_needed "$SHARE1" "$MOUNT1"
# mount_if_needed "$SHARE2" "$MOUNT2"
# mount_if_needed "$SHARE3" "$MOUNT3"
# mount_if_needed "$SHARE4" "$MOUNT4"

# Path to store the last run timestamp
LOG_FILE="log_run.txt"

while true; do
    # Current time in seconds since the epoch
    START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

    # Record the current time as the last run time
    echo "START TIME: ${START_TIME}" >> "$LOG_FILE"
    echo "START TIME: ${START_TIME}"
    
    # the folders stored on PlexData2 Share
    rsync -avvh --delete "/mnt/qnap/Exercise/" "/mnt/plexserver2/Exercise/"
    rsync -avvh --delete "/mnt/qnap/Greg Towes Healing with Oils/" "/mnt/plexserver2/Greg Towes Healing with Oils/"
    rsync -avvh --delete "/mnt/qnap/Miscellaneous/" "/mnt/plexserver2/Miscellaneous/"
    rsync -avvh --delete "/mnt/qnap/Photos/" "/mnt/plexserver2/Photos/"
    rsync -avvh --delete "/mnt/qnap/Robert's Edits/" "/mnt/plexserver2/Robert's Edits/"

    # # folder stored on PlexData Share
    rsync -avvh --delete "/mnt/qnap/backup/" "/mnt/plexserver/backup/"
    rsync -avvh --delete "/mnt/qnap/Movies/" "/mnt/plexserver/Movies/"
    rsync -avvh --delete "/mnt/qnap/TV Shows/" "/mnt/plexserver/TV Shows/"
    rsync -avvh --delete "/mnt/qnap/Vision Boards/" "/mnt/plexserver/Vision Boards/"
    rsync -avvh --delete "/mnt/qnap/Books/" "/mnt/plexserver/Books/"

    # # folder stored on iTunes Share
    rsync -avvh --delete "/mnt/qnap/iTunes/iTunes Media/" "/mnt/itunes/iTunes Media/"
    
    FINISH_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    # Sleep for ten minutes to avoid excessive CPU usage, then check again
    echo "FINISH TIME: ${FINISH_TIME}" >> "$LOG_FILE"
    echo "FINISH TIME: ${FINISH_TIME}"
    
    sleep 14400
done
