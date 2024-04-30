#!/bin/bash

set -e

# Define the mount points and network shares
MOUNT1="/mnt/qnap/"
SHARE1="//192.168.6.161/PlexData"
MOUNT2="/mnt/plexserver2/"
SHARE2="//192.168.4.38/PlexData2"
MOUNT3="/mnt/plexserver/"
SHARE3="//192.168.4.38/PlexData"
MOUNT4="/mnt/itunes/"
SHARE4="//192.168.4.38/iTunes"


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
mount_if_needed "$SHARE2" "$MOUNT2"
mount_if_needed "$SHARE3" "$MOUNT3"
mount_if_needed "$SHARE4" "$MOUNT4"


# Path to the rsync log file
LOG_FILE="rsync.log"
# Path to store the last run timestamp
LAST_RUN_FILE="last_run.txt"

# Initialize the last run time
if [ ! -f "$LAST_RUN_FILE" ]; then
    echo "0" > "$LAST_RUN_FILE"
fi

while true; do
    # Current time in seconds since the epoch
    CURRENT_TIME=$(date +%s)
    # Last run time from file
    LAST_RUN_TIME=$(cat "$LAST_RUN_FILE")

    # Calculate time since last run
    TIME_SINCE_LAST_RUN=$(( CURRENT_TIME - LAST_RUN_TIME ))

    # Check if an 4 hours has passed since the last run
    if [ "$TIME_SINCE_LAST_RUN" -ge (60*60*4) ]; then
        # Record the current time as the last run time
        echo "$CURRENT_TIME" > "$LAST_RUN_FILE"

        # Log and run the rsync command
        echo "Running rsync: $(date)"

        # the folders stored on PlexData2 Share
        rsync -avh /mnt/qnap/Exercise/ /mnt/plexserver2/Exercise/ --dry-run
        rsync -avh /mnt/qnap/Greg Towes Healing with Oils/ /mnt/plexserver2/Greg Towes Healing with Oils/
        rsync -avh /mnt/qnap/Miscellaneous/ /mnt/plexserver2/Miscellaneous/
        rsync -avh /mnt/qnap/Photos/ /mnt/plexserver2/Photos/
        rsync -avh /mnt/qnap/Robert's Edits/ /mnt/plexserver2/Robert's Edits/

        # folder stored on PlexData Share
        rsync -avh /mnt/qnap/backup/ /mnt/plexserver/backup/
        rsync -avh /mnt/qnap/Movies/ /mnt/plexserver/Movies/
        rsync -avh /mnt/qnap/TV Shows/ /mnt/plexserver/TV Shows/
        rsync -avh /mnt/qnap/Vision Boards/ /mnt/plexserver/Vision Boards/

        # folder stored on iTunes Share
        rsync -avh /mnt/qnap/iTunes/ /mnt/iTunes/iTunes/
    fi

    # Sleep for ten minutes to avoid excessive CPU usage, then check again
    sleep 60*10
done
