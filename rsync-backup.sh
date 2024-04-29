#!/bin/bash

set -e

# Define the mount points and network shares
MOUNT1="/mnt/qnap/"
SHARE1="//192.168.6.161/PlexData"
MOUNT2="/mnt/plexserver/"
SHARE2="//192.168.4.38/PlexData2"

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

    # Check if an hour has passed since the last run (3600 seconds)
    if [ "$TIME_SINCE_LAST_RUN" -ge 120 ]; then
        # Record the current time as the last run time
        echo "$CURRENT_TIME" > "$LAST_RUN_FILE"

        # Log and run the rsync command
        echo "Running rsync: $(date)" >> "$LOG_FILE"
        rsync -avh /mnt/qnap/Exercise/ /mnt/plexserver/Exercise/ --dry-run >> "$LOG_FILE"
    fi

    # Sleep for a short period to avoid excessive CPU usage, then check again
    sleep 60
done
