#!/bin/sh

test -f /usr/share/acpi-support/key-constants || exit 0
echo "key constants" >> /tmp/power.log

. /usr/share/acpi-support/policy-funcs

# I think this fails to pass if gnome power manager is fucking with my shit
#if [ -z "$*" ] && ( [ `CheckPolicy` = 0 ] || CheckUPowerPolicy ); then
#    echo "policy" >> /tmp/power.log
#    exit;
#fi

grep -q closed /proc/acpi/button/lid/*/state
if [ $? = 0 ]
then
    echo "closed" >> /tmp/power.log
    echo -n mem > /sys/power/state
else
    echo "open" >> /tmp/power.log
    pm-powersave $*
fi

