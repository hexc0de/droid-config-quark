#!/usr/bin/env bash

MNT=$(grep "Where=" /lib/systemd/system/android.mount | cut -d'=' -f 2)/media/0

if [ ! -d "/home/nemo/AndroidData" ]; then
  mkdir /home/nemo/AndroidData
  ln -s $MNT /home/nemo/AndroidData/0
fi
