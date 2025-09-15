#!/bin/bash
SIMSWAP_DIR="/cavnv"
SIMSWAP_FILE="simswap"
GPIO_PIN=35
LDO5="/sys/kernel/debug/regulator/soc:qcom,smd:rpm:rpmb@0:rpm-regulator-ldoa5:regulator-l5-mdm9607_l5"
LDO6="/sys/kernel/debug/regulator/soc:qcom,smd:rpm:rpmb@0:rpm-regulator-ldoa6:regulator-l6-mdm9607_l6"
PREFER_EXT_SIM="0000"
LDO5_VALUE=$(cat $LDO5/enable)
LDO6_VALUE=$(cat $LDO6/enable)
if [ -e $SIMSWAP_DIR/$SIMSWAP_FILE ]; then
    PREFER_EXT_SIM=$(hexdump /cavnv/simswap -v | awk 'NR==1{ print $2}')
fi

echo $GPIO_PIN > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$GPIO_PIN/direction
if [ $PREFER_EXT_SIM == "0000" ]; then
    echo 0 > /sys/class/gpio/gpio35/value
    if [ $LDO6_VALUE != 0 ]; then
        echo 0 > $LDO6/enable
    fi

    if [ $LDO5_VALUE != 1 ]; then
        echo 1 > $LDO5/enable
    fi
else
    echo 1 > /sys/class/gpio/gpio35/value
    if [ $LDO5_VALUE != 1 ]; then
        echo 1 > $LDO5/enable
    fi

    if [ $LDO6_VALUE != 1 ]; then
        echo 1 > $LDO6/enable
    fi
fi
sync