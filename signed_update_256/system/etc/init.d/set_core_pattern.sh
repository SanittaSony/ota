#!/bin/sh

#start:CAVLI_EDIT
echo "set_core_pattern.sh has been disabled, to disable core_dump" > /dev/kmsg
#sysctl -w kernel.core_pattern=/var/tmp/core.%e.%p.%s.%t
#end: CAVLI_EDIT
