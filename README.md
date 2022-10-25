# Disk expansion base on LVM
**The operation of disk in linux is based on lvm, This is a set of tools related to disk expansion.**

  ##### 1. Create a virtual block device from the current filesystem space
  -----
  ```
  Code: CreateLvm.sh
    (1). dd if=/dev/zero of=${LOOP_PATH} bs=${LOOP_UNIT} count=${LOOP_SIZE}  // generate memory file
    (2). losetup  // Virtualize a file into a block device
    (3). vgcreate --> lvcreate --> mkfs.xfs --> mount -a
    (4). CreateService(code func)  // system service
  ```

  ##### 1. added disk is expanded based on an existing logical volume
  -----
  ```
  Code: DiskExp.py
      Script command set:
        parted (>2GB) or fdisk --> Create disk partition
        mkfs.xfs -f partition --> format new partition
        pvcreate --> Create a physical volume group
        vgextend --> Add physical volume space to volume group
        lvextend --> Add idle PEFREE to the logical volume through lvextend
        
        resize2fs (ext)/xfs_growfs (xfs) --> Sync file system
  ```
  
  ##### 2. Create a logical volume based on a new single disk, and create a raid1 volume with dual disks
  -----
  ```
   Code: initraid1
      Through code or view code comments
  ```
  
  
  ##### 3. expect script to create partitions interactively
  -----
  ```
  Code: DiskPartedTool
    nothing to say
  ```
  init
