#!/bin/sh
module_cpukh="cpukh_driver"
module_led="led_driver"
module_sw="sw_driver"

device_cpukh="cpukh"
device_led="led"
device_sw="sw"

if [ `id -u` -ne 0 ]; then
	echo "error: this script requires root privilege"
	exit 1
fi

rmmod ./cpukh/$module_cpukh.ko 
rmmod ./led/$module_led.ko 
rmmod ./sw/$module_sw.ko 

rm -f /dev/${device_cpukh}
rm -f /dev/${device_led}
rm -f /dev/${device_sw}


