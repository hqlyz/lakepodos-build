FROM ubuntu:jammy

RUN apt-get update && apt install -y \
      xorriso \
      squashfuse \
	squashfs-tools \
      vim \
      rsync \
      fdisk \
      wget \
      isolinux \
      syslinux-common \
      iproute2 \
      iputils-ping
      
ENV LANG en_US.utf8
