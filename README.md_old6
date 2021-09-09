Homework 3.5

#2
Жесткие ссылки - имеют ту же информацию inode и набор разрешений что и у исходного файла.

#4

{
Command (m for help): n \
Partition type \
   p   primary (0 primary, 0 extended, 4 free) \
   e   extended (container for logical partitions) \
Select (default p): p \
Partition number (1-4, default 1): 1 \
First sector (2048-5242879, default 2048): \
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2048M \

Created a new partition 1 of type 'Linux' and of size 2 GiB. \

Command (m for help): n \
Partition type \
   p   primary (1 primary, 0 extended, 3 free) \
   e   extended (container for logical partitions) \
Select (default p): p \
Partition number (2-4, default 2): 2 \
First sector (4196352-5242879, default 4196352): \
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): +512m \
Value out of range. \
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): +512M \
Value out of range. \
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): \

Created a new partition 2 of type 'Linux' and of size 511 MiB. \

Command (m for help): w \
The partition table has been altered. \
Calling ioctl() to re-read partition table. \
Syncing disks.
}

#5

{
vagrant@vagrant:~$ sfdisk -d /dev/sdb > part_table \
sfdisk: cannot open /dev/sdb: Permission denied \
vagrant@vagrant:~$ sudo sfdisk -d /dev/sdb > part_table \
vagrant@vagrant:~$ sudo sfdisk /dev/sdc < part_table \
Checking that no-one is using this disk right now ... OK \

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors \
Disk model: VBOX HARDDISK \
Units: sectors of 1 * 512 = 512 bytes \
Sector size (logical/physical): 512 bytes / 512 bytes \
I/O size (minimum/optimal): 512 bytes / 512 bytes \

>>> Script header accepted. \
>>> Script header accepted. \
>>> Script header accepted. \
>>> Script header accepted. \
>>> Created a new DOS disklabel with disk identifier 0x5cc6f568. \
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB. \
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB. \
/dev/sdc3: Done. \

New situation: \
Disklabel type: dos \
Disk identifier: 0x5cc6f568 \

Device     Boot   Start     End Sectors  Size Id Type \
/dev/sdc1          2048 4196351 4194304    2G 83 Linux \
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux \

The partition table has been altered. \
Calling ioctl() to re-read partition table. \
Syncing disks.
}

#6
{
vagrant@vagrant:~$ sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sdb1 /dev/sdc1 \
mdadm: Note: this array has metadata at the start and \
    may not be suitable as a boot device.  If you plan to \
    store '/boot' on this device please ensure that \
    your boot-loader understands md/v1.x metadata, or use \
    --metadata=0.90 \
mdadm: size set to 2094080K \
Continue creating array? y \
mdadm: Defaulting to version 1.2 metadata \
mdadm: array /dev/md0 started.
}

#7

{
vagrant@vagrant:~$ sudo mdadm --create --verbose /dev/md1 -l 0 -n 2 /dev/sdb2 /dev/sdc2 \
mdadm: chunk size defaults to 512K \
mdadm: Defaulting to version 1.2 metadata \
mdadm: array /dev/md1 started.
}

#8

{
vagrant@vagrant:~$ sudo pvcreate /dev/md0 \
  Physical volume "/dev/md0" successfully created. \
vagrant@vagrant:~$ sudo pvcreate /dev/md1 \
  Physical volume "/dev/md1" successfully created. \

vagrant@vagrant:~$ sudo pvs \
  PV         VG        Fmt  Attr PSize    PFree \
  /dev/md0             lvm2 ---    <2.00g   <2.00g \
  /dev/md1             lvm2 ---  1018.00m 1018.00m \
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0
}

#9

{
vagrant@vagrant:~$ sudo vgcreate vg01 /dev/md0 /dev/md1 \
  Volume group "vg01" successfully created \

vvagrant@vagrant:~$ sudo vgs \
  VG        #PV #LV #SN Attr   VSize   VFree \
  vg01        2   0   0 wz--n-  <2.99g <2.99g \
  vgvagrant   1   2   0 wz--n- <63.50g     0
}

#10

{
vagrant@vagrant:~$ sudo lvcreate -L 100 -n lv01 /dev/vg01 /dev/md1 \
  Logical volume "lv01" created. \
vagrant@vagrant:~$ sudo lvs -a -o +devices \
  LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices \
  lv01   vg01      -wi-a----- 100.00m                                                     /dev/md1(0) \
  root   vgvagrant -wi-ao---- <62.54g                                                     /dev/sda5(0) \
  swap_1 vgvagrant -wi-ao---- 980.00m                                                     /dev/sda5(16010)
}

#11

{
vagrant@vagrant:~$ sudo mkfs.ext4 /dev/vg01/lv01 \
mke2fs 1.45.5 (07-Jan-2020) \
Creating filesystem with 25600 4k blocks and 25600 inodes \

Allocating group tables: done \
Writing inode tables: done \
Creating journal (1024 blocks): done \
Writing superblocks and filesystem accounting information: done
}

#12

{
vagrant@vagrant:~$ mkdir /tmp/new \
vagrant@vagrant:~$ sudo mount /dev/vg01/lv01 /tmp/new
}

#14

{
vagrant@vagrant:~$ lsblk \
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT \
sda                    8:0    0   64G  0 disk \
├─sda1                 8:1    0  512M  0 part  /boot/efi \
├─sda2                 8:2    0    1K  0 part \
└─sda5                 8:5    0 63.5G  0 part \
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   / \
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP] \
sdb                    8:16   0  2.5G  0 disk \
├─sdb1                 8:17   0    2G  0 part \
│ └─md0                9:0    0    2G  0 raid1 \
└─sdb2                 8:18   0  511M  0 part \
  └─md1                9:1    0 1018M  0 raid0 \
    └─vg01-lv01      253:2    0  100M  0 lvm   /tmp/new \
sdc                    8:32   0  2.5G  0 disk \
├─sdc1                 8:33   0    2G  0 part \
│ └─md0                9:0    0    2G  0 raid1 \
└─sdc2                 8:34   0  511M  0 part \
  └─md1                9:1    0 1018M  0 raid0 \
    └─vg01-lv01      253:2    0  100M  0 lvm   /tmp/new
}

#15

{
vagrant@vagrant:~$ gzip -t /tmp/new/test.gz \
vagrant@vagrant:~$ echo $?
0
}

#16

{
vagrant@vagrant:~$ sudo pvmove /dev/md1 /dev/md0 \
  /dev/md1: Moved: 100.00%
}

#17

{
vagrant@vagrant:~$ sudo mdadm /dev/md0 --fail /dev/sdb1 \
mdadm: set /dev/sdb1 faulty in /dev/md0
}

#18

{
[ 4411.516555] md/raid1:md0: Disk failure on sdb1, disabling device. \
               md/raid1:md0: Operation continuing on 1 devices.
}

#19

{
vagrant@vagrant:~$ gzip -t /tmp/new/test.gz \
vagrant@vagrant:~$ echo $? \
0
}


