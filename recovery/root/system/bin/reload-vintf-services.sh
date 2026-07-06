#!/system/bin/sh

/system/bin/setprop ctl.restart hwservicemanager
/system/bin/sleep 1
/system/bin/setprop ctl.restart keymaster-4-1-qti
/system/bin/setprop ctl.restart gatekeeper-1-0-qti
/system/bin/setprop ctl.restart keystore2
/system/bin/setprop ctl.restart health-hal-2-0
/system/bin/setprop ctl.restart health-hal-2-1
