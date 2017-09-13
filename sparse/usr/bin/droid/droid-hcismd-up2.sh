#!/bin/sh

RFKILL=/usr/sbin/rfkill
BT_SLEEP=/proc/bluetooth/sleep/proto
FIRMWARE=/persist
HCI_DEVICE=/dev/ttyHSL0
HCI_INIT=/system/bin/hci_qcomm_init
HCI_ATTACH=/usr/sbin/hciattach
HCI_TRANSPORT=smd
BT_POWER_CLASS=2
BT_LE_POWER_CLASS=2
VENDOR=qualcomm
bt_mac=
lastres=

##################################################

setprop ro.qualcomm.bt.hci_transport $HCI_TRANSPORT
setprop qcom.bt.dev_power_class $BT_POWER_CLASS
setprop qcom.bt.le_dev_pwr_class $BT_LE_POWER_CLASS

echo 0 > /sys/module/hci_smd/parameters/hcismd_set

MAXTRIES=15
for i in $MAXTRIES; do
  echo "i: $i"
  if [ -e /dev/socket/qmux_radio/qmux_connect_socket ] ; then
    echo "QMUX socket was found after `expr $MAXTRIES - $i` tries"
    echo "Retrieving MAC-address for Bluetooth device"
    echo "$HCI_INIT -e -p $BT_POWER_CLASS -P $BT_LE_POWER_CLASS -d $HCI_DEVICE 2>1 | grep -oP '([0-9a-f]{2}:){5}([0-9a-f]{2})'"
    bt_mac=$($HCI_INIT -e -p $BT_POWER_CLASS -P $BT_LE_POWER_CLASS -d $HCI_DEVICE 2>1 | grep -oP '([0-9a-f]{2}:){5}([0-9a-f]{2})')
    if [ ! -z "$bt_mac" ] ; then
      echo $bt_mac > /var/lib/bluetooth/board-address
      echo "BT MAC: $bt_mac"
      break
    fi
  fi
  sleep 1
done

echo "QMUX LOOP is OVER and bt_mac is $bt_mac"
if [ ! -z "$bt_mac" ] ; then
  echo "Bluetooth QSoC firmware download succeeded"

  # Maximum number of attempts to enable hcismd to try to get
  # hci0 to come online.  Writing to sysfs too early seems to
  # not work, so we loop.
  MAXTRIES=15

  seq 1 $MAXTRIES | while read i ; do
      echo 1 > /sys/module/hci_smd/parameters/hcismd_set
      if [ -e /sys/class/bluetooth/hci0 ] ; then
          # found hci0, exit successfully
	  echo "Found hci0 after $i tries"
          exit 0
      fi
      sleep 1
      if [ $i == $MAXTRIES ] ; then
          # must have gotten through all our retries, fail
          exit 1
      fi
  done
else
  echo "Bluetooth QSoC firmware download failed"
  exit 1
fi
