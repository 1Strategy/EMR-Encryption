#!/bin/bash
set -euo pipefail
set -x
IFS=$'\n\t'
RUN_ONCE_FILE="/.encrypt"

if [ -f "${RUN_ONCE_FILE}" ]; then
  echo "encrypt.sh bootstrap already ran!"
  exit 0
fi

size="`stat -f -c '%f' /mnt`"
size="`expr ${size} \* 4096`"
size5="`expr ${size} / 5`"
CRYPT_SIZE="`expr ${size} - ${size5}`"
PWD_FILE="/dev/shm/.disk-key"
CIPHER="AES_256"
AWS_KMS_KEY_ID=""

while getopts ":k:c:" opt; do
  case $opt in
    k)
      AWS_KMS_KEY_ID=$OPTARG
      ;;
    c)
      CIPHER=$OPTARG
      ;;
  esac
done



if [ -z "${CRYPT_SIZE}" ]; then
  echo "Invalid CRYPT_SIZE: ${CRYPT_SIZE}"
  exit 1
fi

function encrypt_disk() {
  local dev=$1
  local dir=$2

  local cryptname="crypt_${dir:1}"

  # Unmount the drive
  sudo umount "$dev"

  # Encrypt the drive
  sudo cryptsetup luksFormat -q --key-file "$PWD_FILE" "$dev"
  sudo cryptsetup luksOpen -q --key-file "$PWD_FILE" "$dev" "$cryptname"

  # Format the drive
  sudo mkfs -t xfs "/dev/mapper/$cryptname"

  sudo mount -o defaults,noatime,inode64 "/dev/mapper/$cryptname" "$dir"
  sudo rm -rf "$dir/lost+found"
  sudo mkdir -p "$dir/encrypted"
  sudo chown -R hadoop:hadoop "$dir"

  echo "/dev/mapper/$cryptname $dir xfs defaults,noatime,inode64 0 0" | \
    sudo tee -a /etc/fstab

  echo "$cryptname $dev $PWD_FILE" | sudo tee -a /etc/crypttab
}

function encrypt_loop() {

  #Encrypt /mnt point
  DIR=$1
  i=$2

  ENCRYPTED_LOOPBACK_DIR=$DIR/encrypted_loopbacks
  ENCRYPTED_MOUNT_POINT=$DIR/encrypted
  ENCRYPTED_LOOPBACK_DEVICE=/dev/loop0
  ENCRYPTED_NAME=crypt_mnt

  #Giving extra space for Log files to grow
  LOG_GROWTH=5

  nblocks=`stat -f -c '%a' $DIR`
  bsize=`stat -f -c '%s' $DIR`
  mntsize=`expr $nblocks \* $bsize \/ 1000 \/ 1000 \/ 1000`
  TMPSIZE=`expr $mntsize \/ 10`

  ENCRYPTED_SIZE=`expr $mntsize - $TMPSIZE - $LOG_GROWTH`g

  mkdir -p $ENCRYPTED_LOOPBACK_DIR
  mkdir -p $ENCRYPTED_MOUNT_POINT


  sudo fallocate -l $ENCRYPTED_SIZE $ENCRYPTED_LOOPBACK_DIR/encrypted_loopback.img
  sudo chown hadoop:hadoop $ENCRYPTED_LOOPBACK_DIR/encrypted_loopback.img
  sudo losetup /dev/loop0 $ENCRYPTED_LOOPBACK_DIR/encrypted_loopback.img

  sudo cryptsetup luksFormat -q --key-file $PWD_FILE $ENCRYPTED_LOOPBACK_DEVICE
  sudo cryptsetup luksOpen -q --key-file $PWD_FILE $ENCRYPTED_LOOPBACK_DEVICE $ENCRYPTED_NAME

  mycmd="sudo mkfs -t xfs /dev/mapper/$ENCRYPTED_NAME && sudo mount /dev/mapper/$ENCRYPTED_NAME $ENCRYPTED_MOUNT_POINT && sudo chown hadoop:hadoop $ENCRYPTED_MOUNT_POINT && sudo rm -rf $ENCRYPTED_MOUNT_POINT/lost\+found"
  echo $mycmd
  eval $mycmd &

}

function encrypt() {
  local i=0
  # Remove xvd entries
  sudo sed -i 's/\(^.*xvd.*$\)/#\1/g' /etc/fstab
  awk '/mnt/{print $1 " " $2}' < /proc/mounts | while read line; do
    local dev="`echo $line | cut -d' ' -f1`"
    local dir="`echo $line | cut -d' ' -f2`"
    if [ -z "$dev" ] || [ -z "$dir" ]; then
      continue
    fi
    if [ "$dir" = "/mnt" ]; then
      encrypt_loop "$dir" "$i"
    else
      encrypt_disk "$dev" "$dir"
    fi
    let i=i+1
  done
}


#Creating encryption key - Use random key if KMS is not provided
if [ "$AWS_KMS_KEY_ID" = "" ]; then
      sudo dd if=/dev/urandom of="$PWD_FILE" bs=2k count=1

    else
      aws kms generate-data-key --key-id $AWS_KMS_KEY_ID --key-spec $CIPHER --encryption-context KeyName1=emr-encryption-key --query Plaintext --region us-east-1 |  tr -d '"' > "$PWD_FILE"
fi


sudo chmod 400 "$PWD_FILE"

sudo modprobe loop
sudo yum install -y cryptsetup
# Encrypt the mountpoints
echo "Script start `date`"
encrypt
sudo touch "${RUN_ONCE_FILE}"
sudo chown hadoop:hadoop "${RUN_ONCE_FILE}"
sleep 1

#Remove Disk Key
sudo rm "$PWD_FILE"
exit 0
