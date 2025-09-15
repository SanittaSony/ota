#!/bin/sh

 for uevent in /sys/bus/iio/devices/iio:device?*/uevent; do
      . $uevent
      if [ -e $uevent ]; then
        if [ ! -e /dev/iio:device$MINOR ]; then
            mknod /dev/iio:device$MINOR c $MAJOR $MINOR
        fi
      fi
 done
