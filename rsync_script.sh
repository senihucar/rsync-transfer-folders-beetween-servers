#!/bin/bash
#Date
TODAY=`date +%Y%m%d`

#Time
TS=`date +%H%M%S`

MAIL=senihucar@yahoo.com

# directory to backup 1st
BDIR1=/home/folder1
# directory to backup 2st
BDIR2=/home/folder2

# directory to destionation
DDIR="/backup"

# the name of the destionation machine
BSERVER=linux2

# your password on the destionation server use SHA crypted
#export RSYNC_PASSWORD=XXXXXX

#HOSTNAME (Script run on this host)
hs=`hostname`

#rsync SETTINGS

BCKP_OPTS="--archive --verbose --info=COPY2,DEL2,NAME2,BACKUP2,REMOVE2,SKIP2"

#LOG file Email Settings

mkdir $DDIR/log
LOGFILE=$DDIR/log/$TODAY-$TS-sync.log
echo $LOGFILE

echo -e "Transfer Date: `date` - $hs>$BSERVER " >> $LOGFILE

###########################################################################################
#Level 1 if begin
if [[ -e $BDIR1 && -e $BDIR2 ]]
then
  echo -e "The Backup folders is ready for transfer. && (Return code: $BDIR1) && (Return code: $BDIR2)" >> $LOGFILE
 #LS DIRECTORY 1
  echo -e "Directory $BDIR1 exists." >> $LOGFILE
  echo -e "The files on first directory to be transferred are listed below:"
  ls -al $BDIR1 >> $LOGFILE
 #LS DIRECTORY 2
  echo "Directory $BDIR2 exists." >> $LOGFILE
  echo -e "The files on second directory to be transferred are listed below:"
  ls -al $BDIR2 >> $LOGFILE



############################################################################
  bdir1log=$DDIR/log/$TODAY-$TS-rsynctransferbackup1log.txt
  bdir2log=$DDIR/log/$TODAY-$TS-rsyncTransferbackup2log.txt

  #### rsync ! Doing transfer and archive the file
  rsync $BCKP_OPTS $BDIR1 $DDIR > $bdir1log
  rsync_status1=$?

  rsync $BCKP_OPTS $BDIR2 $DDIR > $bdir2log
  rsync_status2=$?
############################################################################

  #Level 2 if begin
  if [[ $rsync_status1 = 0 && $rsync_status2 = 0 ]]; then

    echo "The file transfer completed successfully. (Return code:$rsync_status1) (Return code:$rsync_status2)" >> $LOGFILE
    echo `date` >> $LOGFILE
    echo "The file transfer completed successfully. Please, check the attached log or $LOGFILE" |mailx -s "THE FILE TRANSFER SUCCESS! - $hs>$BSERVER" -a $LOGFILE -a $bdir1log -a $bdir2log $MAIL
  else
    echo "The file transfer failed. (Error code:$rsync_status1) (Error code:$rsync_status2)" >> $LOGFILE
    echo "Notify the user to verify the the log" >> $LOGFILE \
    echo "The file transfer failed. Please, check the attached log or  $LOGFILE" |mailx -s "THE FILE TRANSFER FAILED - $hs>$BSERVER" -a $LOGFILE -a $bdir1log -a $bdir2log $MAIL
  fi
  #Level 2 if end

else
  echo "The file transfer failed. The backup transfer file is not ready. && (Return code: $BDIR1) && (Return code: $BDIR2)" >> $LOGFILE
  echo "Waiting the system to create the backup transfer file" >> $LOGFILE
  echo `date`  >> $LOGFILE
  echo "The file transfer failed. The backup file is not ready. Unsuccesfull " | mailx -s "THE FILE TRANSFER FAILED - $hs>$BSERVER" -a $LOGFILE $MAIL
fi
#Level 1 if end
