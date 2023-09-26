#!/bin/bash

#MAIL LIST
MAIL="senih.ucar@yahoo.com"

# Rsync SETTINGS
BCKP_OPTS="-avzipogt"

# Directories to backup (add more directories as needed)
BACKUP_DIRS=(
  "/home/sucar2/test5.dat"
  "/home/sucar2/test10.dat"
  "/home/sucar2/test24.dat"
)

#  destination directory on target machine
DDIR="/home/sucar2"

# The name of the destination machine
BSERVER="destination@host"




### ***PLEASE DO NOT CHANGE BELOW*** ###
# Date
TODAY=$(date +%Y%m%d)

# Time
TS=$(date +%H%M%S)


# HOSTNAME (Script run on this host)
hs=$(hostname)

# LOG file Email Settings
mkdir -p "$PWD/log"
LOGFILE="$PWD/log/$TODAY-$TS-sync.log"
echo "$LOGFILE"

echo -e "Transfer Date: $(date) - $hs > $BSERVER" >> "$LOGFILE"

# Iterate over backup directories
for BDIR in "${BACKUP_DIRS[@]}"; do
  if [ -e "$BDIR" ]; then
    echo "Directory $BDIR exists." >> "$LOGFILE"
    echo "The files in the directory to be transferred are listed below:" >> "$LOGFILE"
    ls -al "$BDIR" >> "$LOGFILE"

    bdirlog="$PWD/log/$TODAY-$TS-$(basename "$BDIR")-rsync-transfer-log.txt"

    # rsync! Doing transfer and archive the file
    rsync "$BCKP_OPTS" "$BDIR" "$BSERVER:$DDIR" > "$bdirlog"
    rsync_status=$?

    if [ $rsync_status -eq 0 ]; then
      echo "The file transfer for $BDIR completed successfully. (Return code: $rsync_status)" >> "$LOGFILE"
      echo "$(date)" >> "$LOGFILE"
      echo "The file transfer completed successfully. Please check the attached log: $bdirlog" | mail -s "FILE TRANSFER SUCCESS - $hs > $BSERVER" $MAIL < "$bdirlog"
    else
      echo "The file transfer for $BDIR failed. (Error code: $rsync_status)" >> "$LOGFILE"
      echo "Notify the user to verify the log" >> "$LOGFILE"
      echo "The file transfer for $BDIR failed. Please check the attached log: $bdirlog" | mail -s "FILE TRANSFER FAILED - $hs > $BSERVER" $MAIL < "$bdirlog"
    fi
  else
    echo "The file transfer for $BDIR failed. The backup transfer file is not ready. (Return code: $BDIR)" >> "$LOGFILE"
    echo "Waiting for the system to create the backup transfer file" >> "$LOGFILE"
    echo "$(date)" >> "$LOGFILE"
    echo "The file transfer for $BDIR failed. The backup file is not ready. Unsuccessful." | mail -s "FILE TRANSFER FAILED - $hs > $BSERVER" $MAIL < "$LOGFILE"
  fi
done
