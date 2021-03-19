#!/bin/bash

DEV_NAME=xvdb
PART_NAME="${DEV_NAME}1"
RESTART=n
MOUNT_NAME=/data
PV="${PART_NAME}"
VG=data
LV=datalv

# Display current block devices
function displayBlock() {
  sudo lsblk
}

# Parition device - don't change the carriage returns!!
# $1 device
# returns NA
function partitionDevice() {
  sudo -s /sbin/fdisk $1 <<< "n
p
1


t
83
w
"
}


# mount device
# $1 deviceName
# returns NA
function mountDevice() {
  sudo /bin/mount $1
}


## Main ##

sudo yum install -y lvm2

echo "PATH $PATH"

OUT=`ls /dev | grep -e "$DEV_NAME"`
if [[ $? -eq 1 ]]; then
  if [ "$RESTART" == "y" ]; then
    echo "SCSI Dev not found.  restarting host..."
    sudo reboot now
  else
    echo "Searching for device in /dev/$DEV_NAME found nothing.  Check param and path.  You may have to reboot."
    exit 1
  fi
fi

echo "out: $OUT"

echo "Device exists. Continuing.."

# partition the device
sudo /bin/lsblk | grep -e "$PART_NAME"
if [[ $? -ne 0 ]]; then
  echo "### Storage is not partitioned.  Partitioning $DEV_NAME"
  sudo fdisk -l
  displayBlock
  partitionDevice /dev/$DEV_NAME
fi

# create partition volume
echo "### Creating pv $PV"
sudo pvcreate -d /dev/$PV
sudo pvscan 
sudo pvdisplay

# create volume group
echo "### Create vg $VG"
sudo vgcreate $VG /dev/$PV
sudo vgdisplay

# assign lv to the vg
echo "### Create and assign lv $LV to vg $VG"
sudo lvcreate -l 100%VG $VG -n $LV
sudo lvscan
sudo lvdisplay -v $LV

# format
echo "### formatting"
sudo mkfs.ext4 /dev/mapper/$VG-$LV


#resizing VG
# add to lvm??
#pvcreate /dev/sda13
# pvdisplay
#vgextend VolGroup00 /dev/sda13
#pvdisplay
#pvscan
#lvextend -L +50G /dev/VolGroup00/homeVol
#lvextend -L +50G /dev/VolGroup00/rootVol
#resize



sudo /bin/mount | grep -e "$MOUNT_NAME"
if [[ $? -ne 0 ]]; then
  echo "### Storage is not mounted.  Mounting /dev/mapper/$VG-$LV $MOUNT_NAME"
  sudo mkdir -p $MOUNT_NAME
  sudo mount /dev/mapper/$VG-$LV $MOUNT_NAME
fi
