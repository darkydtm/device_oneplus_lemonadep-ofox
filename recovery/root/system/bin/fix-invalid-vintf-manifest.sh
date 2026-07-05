#!/system/bin/sh

if /system/bin/grep -qe "androidboot.mode=recovery" -e "twrpfastboot" /proc/cmdline; then
	for f in /system/etc/vintf/manifest/* /vendor/etc/vintf/manifest/*; do
		if /system/bin/grep -qFvz "${f:1}" /ramdisk-files.txt; then
			rm $f
		fi
	done
fi
