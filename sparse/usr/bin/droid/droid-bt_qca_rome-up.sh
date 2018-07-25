#!/bin/sh

REVERSED_BDADDR=$(/system/bin/btnvtool -p 2>&1 | grep address | cut -s -d: -f2)
BDADDR=$(for i in `seq 6 -1 1`; do printf "%02x:" "0x`echo $REVERSED_BDADDR | cut -d . -f $i`"; done)
BDADDR="${BDADDR%:*}"

if [ ! -e /var/lib/bluetooth/board-address ]; then
  echo "Store bt mac $BDADDR"
  echo "$BDADDR" > /var/lib/bluetooth/board-address
fi

/usr/sbin/rfkill block bluetooth
/usr/sbin/rfkill unblock bluetooth

#/usr/bin/hciattach  /dev/ttyHS0 qca /var/lib/bluetooth/board-address
/usr/bin/hciattach -b -d -m -t120 /dev/ttyHS0 qca 115200 flow sleep
#/use/bin/hciattach /dev/ttyHS0 -t120 flow -f1

/usr/sbin/rfkill block bluetooth
/usr/sbin/rfkill unblock bluetooth

sleep 2
/usr/bin/hciconfig hci0 up

/usr/bin/hcitool lescan &

pid=$!
sleep 5
kill -INT $pid

exit 0


