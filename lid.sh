#!/bin/bash
logger "ACPI [lid]: START"

test -f /usr/share/acpi-support/state-funcs || exit 0

logger "ACPI [lid] state-func passed"

. /usr/share/acpi-support/power-funcs
. /usr/share/acpi-support/policy-funcs
. /etc/default/acpi-support

logger "ACPI [lid] support funcs loaded"

if [ `CheckPolicy` = 0 ]
then
  logger "ACPI [lid] CheckPolicy failed"
  exit
fi

# get the user running xscreensaver
xs=$(ps up $(pidof xscreensaver) | awk '/xscreensaver/ {print $1}')
logger "ACPI [lid] xscreensaver user $xs"
# If $? = 0 then the lid is closing otherwise it's being opened
grep -q closed /proc/acpi/button/lid/*/state
if [ $? = 0 ]
then
  logger "ACPI [lid]: Lid closed"
	Dis=`acpi | cut -f3 -d " "`

	# If we are discharging then sleep otherwise blank the screen
  if [ "$Dis" = "Discharging," ]
  then
    logger "ACPI [lid]: Discharging... Entering sleep"
    su $xs -c "xscreensaver-command -lock"
    sleep 2
    echo -n mem > /sys/power/state
  else
    logger "ACPI user: $user"
    logger "ACPI [lid]: Power connected blanking screen"
    su $xs -c "xscreensaver-command -lock"
  fi
else
  logger "ACPI [lid]: Lid opened"
  su $xs -c "xset dpms force on"
  su $xs -c "xscreensaver-command -deactivate"
fi
