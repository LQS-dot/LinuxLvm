#!/bin/sh
LVM_GRP=klas
LVM_VOL=lv_opt
LOOP_PATH=/home/lvm_loop
LOOP_SIZE=2000
LOOP_UNIT=1M

CreateLoop () {
    dd if=/dev/zero of=${LOOP_PATH} bs=${LOOP_UNIT} count=${LOOP_SIZE}
    losetup -f ${LOOP_PATH}
    LOOPDEVICE=${LOOP_PATH} python <<EOF
import subprocess
import json
import os

proc = subprocess.Popen(["losetup", "--json"], stdout=subprocess.PIPE)
data = json.loads(proc.stdout.read().decode())["loopdevices"]
for item in data:
    if item["back-file"] == os.getenv("LOOPDEVICE"):
        print(item["name"])
EOF
}

CreateService () {
    cat > /etc/systemd/system/setup-klas-loop.service <<EOF
[Unit]
Description=Setup loop devices for klas
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target
After=systemd-udevd.service home.mount
Required=systemd-udevd.serpvice

[Service]
Type=oneshot
ExecStart=/usr/sbin/kpartx -v -a /home/lvm_loop
ExecStop=/usr/sbin/kpartx -d /home/lvm_loop
TimeoutSec=60
RemainAfterExit=yes

[Install]
WantedBy=local-fs.target
Also=systemd-udevd.service
EOF
    systemctl daemon-reload
    systemctl enable setup-klas-loop
}

InitlizeLvm () {
    vgcreate ${LVM_GRP} ${1}
    lvcreate -l +100%FREE ${LVM_GRP} -n ${LVM_VOL}
}

InitlizeXfs () {
    mkfs.xfs /dev/mapper/${LVM_GRP}-${LVM_VOL}
    grep -q "${LVM_GRP}-${LVM_VOL}" /etc/fstab || echo "/dev/mapper/${LVM_GRP}-${LVM_VOL} /opt                   xfs     defaults        0 0" >> /etc/fstab
    mount -a
}

Main () {
    loop_name=$(CreateLoop)
    CreateService
    InitlizeLvm ${loop_name}
    InitlizeXfs
}

Main
