#!/bin/bash

set -e

ROOT_DIR=/lakepod-os
ISO_URLBASE=https://releases.ubuntu.com/22.04
ISO_FILENAME=ubuntu-22.04.2-live-server-amd64.iso
ISO_MOUNTPOINT=/mnt/iso
ISO_ROOT=iso_root

## copy files
GRUBCFG_SRC=config/boot/grub/grub.cfg
GRUBCFG_DEST=$ISO_ROOT/boot/grub/grub.cfg
USERDATA_SRC=config/user-data
USERDATA_DEST=$ISO_ROOT/user-data
METADATA_SRC=config/meta-data
METADATA_DEST=$ISO_ROOT/meta-data
EXTRAS_SRCDIR=$ROOT_DIR/config/extras
EXTRAS_DESTDIR=$ISO_ROOT/
DOWNLOADED_PKG_SRCDIR=$ROOT_DIR/packages
DOWNLOADED_PKG_DESTDIR=$ISO_ROOT/install/
ORIGIN_SQUASH_FS=$ROOT_DIR/$ISO_ROOT/casper

GENISO_LABEL=LAKEPODOS
GENISO_FILENAME=ubuntu-custom-autoinstaller.$(date +%Y%m%d.%H%M%S).iso
GENISO_BOOTIMG=boot/grub/i386-pc/eltorito.img
GENISO_BOOTCATALOG=/boot.catalog
GENISO_START_SECTOR=$(fdisk -l $ISO_FILENAME |grep iso2 | cut -d' ' -f2)
GENISO_END_SECTOR=$(fdisk -l $ISO_FILENAME |grep iso2 | cut -d' ' -f3)


download_iso() {
    if [ ! -f $ISO_FILENAME ];then
    log "iso文件不存在"
    wget -N $ISO_URLBASE/$ISO_FILENAME
    else
    log "iso文件已存在"
    fi
}

init_iso() {
    if [ -d $ISO_ROOT ]; then
    log "iso_root已存在"
    else
    log "iso_root不存在，需要初始化"
    ( test -d $ISO_ROOT && mv -f $ISO_ROOT $ISO_ROOT.$(date +%Y%m%d.%H%M%S) ) || true
	mkdir -p $ISO_ROOT
	mkdir -p $ISO_MOUNTPOINT
	(mountpoint $ISO_MOUNTPOINT && umount -q $ISO_MOUNTPOINT) || true
	mount -o ro,loop $ISO_FILENAME $ISO_MOUNTPOINT
	rsync -av $ISO_MOUNTPOINT/. $ISO_ROOT/.
	umount $ISO_MOUNTPOINT
    fi
}

setup() {
    chmod 755 $ISO_ROOT
	chmod 644 $GRUBCFG_DEST
	cp -f $GRUBCFG_SRC $GRUBCFG_DEST
	chmod 755 $ISO_ROOT
	cp -f $USERDATA_SRC $USERDATA_DEST
	cp -f $METADATA_SRC $METADATA_DEST
	rsync -av $EXTRAS_SRCDIR/. $EXTRAS_DESTDIR/.

	SQUASH_DIR=$(mktemp -d)
	log $SQUASH_DIR
	SQUASH_FS="ubuntu-server-minimal.squashfs"
	cp $ORIGIN_SQUASH_FS/$SQUASH_FS $SQUASH_DIR
	cd $SQUASH_DIR
	unsquashfs $SQUASH_FS

	cp -f $DOWNLOADED_PKG_SRCDIR/* squashfs-root/media/
	cp -f $EXTRAS_SRCDIR/installer.sh squashfs-root/media/
	chroot squashfs-root/ /bin/bash /media/installer.sh
	mksquashfs squashfs-root/ "${SQUASH_FS}" -comp xz -b 1M -noappend
	log "copy back ${SQUASH_FS} ==> $ORIGIN_SQUASH_FS"
	cp -f $SQUASH_FS $ORIGIN_SQUASH_FS
	rm -rf $SQUASH_FS
	rm -rf squashfs-root

	cd -
}

gen_iso() {
    xorriso -as mkisofs -volid $GENISO_LABEL \
	-output $GENISO_FILENAME \
	-eltorito-boot $GENISO_BOOTIMG \
	-eltorito-catalog $GENISO_BOOTCATALOG -no-emul-boot \
	-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
	-no-emul-boot -isohybrid-gpt-basdat \
	-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:$GENISO_START_SECTOR'd'-$GENISO_END_SECTOR'd'::$ISO_FILENAME \
	-e '--interval:appended_partition_2_start_1782357s_size_8496d:all::' \
	--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:$ISO_FILENAME \
	"$ISO_ROOT"
}

download_packages() {
	# 下载 lakepod-os 必须的组件对应的特定版本的安装包
	mkdir -p $DOWNLOADED_PKG_SRCDIR

}

clean() {
	rm -rf iso_root
}

log() {
    echo >&2 -e "[$(date +"%Y-%m-%d %H:%M:%S")] ${1-}"
}

build() {
    download_iso
    init_iso
	download_packages
    setup
    gen_iso
	clean
}

build