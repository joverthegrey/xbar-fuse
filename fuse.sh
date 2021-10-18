#!/bin/zsh

# binaries
JQ_BIN=/usr/local/bin/jq
OSASCRIPT_BIN=/usr/bin/osascript

# global mountpoint path (all mountpoints will be under this path)
GLOBAL_MOUNTPOINT=$HOME

# keychain we use to retrieve passwords
KEYCHAIN="/Users/user/Library/Keychains/fuse.keychain-db" 

# filesystem configs
read -r -d '' FILESYSTEMS << JSON
[
    {"name": "sshfs", "fstype": "sshfs", "mountpoint": "fs1", "path": "user@remotehost.net", "passwordname": "remotehost"},
    {"name": "encfs", "fstype": "encfs", "mountpoint": "secure", "path": "/Users/user/mysupersecure/.secure", "passwordname": "encfs"}
]
JSON

# get a config option for the specified filesystem
function filesystem_config()
{
    echo $FILESYSTEMS | $JQ_BIN -c -r .'['$1']'.$2
}

# count the entries in the config
function filesystem_entries()
{
    echo $FILESYSTEMS | $JQ_BIN 'length'
}

# mount the specified filesystem
function filesystem_mount()
{
  # gather all the options 
  name=$(filesystem_config $1 name )
  type=$(filesystem_config $1 fstype )
  mountpoint=$(filesystem_config $1 mountpoint)
  path=$(filesystem_config $1 path)
  password=$(filesystem_config $1 passwordname)

  # mount the correct type
  ${type}_mount $name $path
    
}

# unmount the specified filesystem
function filesystem_unmount()
{
  # gather the information
  mountpoint=$(filesystem_config $1 mountpoint)

  umount $GLOBAL_MOUNTPOINT/$mountpoint
}


function filesystem_mounted()
{
    mountpoint=$(filesystem_config $1 mountpoint)
    mount | grep $mountpoint
    return $?
}

# mount sshfs filesystems
function sshfs_mount() {
    echo "sshfs: mounting '$1' on '$2'"
}

# mount encfs filesystems
function encfs_mount() {
    echo "encfs: mounting '$1' on '$2'"
}


# menu part
# set the text color based on the dark mode
color=black
if [ "$XBARDarkMode" = "true" ]; then
  color=white
fi

echo "Fuse :floppy_disk: | color='$color'"
echo "---"

for ((i = 0; i < $(filesystem_entries) ; i++));
do
  isMounted=$(filesystem_mounted $i)
  name=$(filesystem_config $i name)
  type=$(filesystem_config $i fstype)
  
  

  if [ $isMounted ];
  then
    echo "◆ $name | color='$color'"
  else
    echo "◇ $name | color='$color'"
  fi

done 
