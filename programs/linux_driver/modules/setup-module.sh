#!/bin/bash
module_cpukh="cpukh_driver"
module_led="led_driver"
module_sw="sw_driver"

device_cpukh="cpukh"
device_led="led"
device_sw="sw"

if [ `id -u` -ne 0 ]; then
	echo "error: this script require root privilege"
	exit 1
fi

PWD=`dirname $0`

insmod ${PWD}/cpukh/$module_cpukh.ko 
insmod ${PWD}/led/$module_led.ko 
insmod ${PWD}/sw/$module_sw.ko 

major_cpukh=$(awk "\$2==\"$module_cpukh\" {print \$1}" /proc/devices)
major_led=$(awk "\$2==\"$module_led\" {print \$1}" /proc/devices)
major_sw=$(awk "\$2==\"$module_sw\" {print \$1}" /proc/devices)

 
mknod /dev/${device_cpukh} c $major_cpukh 0
mknod /dev/${device_led} c $major_led 0
mknod /dev/${device_sw} c $major_sw 0

