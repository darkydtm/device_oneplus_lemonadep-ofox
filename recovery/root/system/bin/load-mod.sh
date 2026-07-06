#!/system/bin/sh

load_module() {
	module="$1"
	shift
	name="${module%.ko}"

	if [ -d "/sys/module/${name}" ]; then
		return 0
	fi

	if [ ! -f "/lib/modules/${module}" ]; then
		return 1
	fi

	/system/bin/insmod "/lib/modules/${module}" "$@" 2>/dev/null
}

load_module q6_pdr_dlkm.ko
load_module q6_notifier_dlkm.ko
load_module snd_event_dlkm.ko
load_module apr_dlkm.ko
load_module adsp_loader_dlkm.ko
load_module aw8697.ko
load_module haptic.ko
load_module msm_drm.ko dsi_display0=qcom,mdss_dsi_samsung_amb670yf01_dsc_cmd:config0

/system/bin/setprop twrp.modules.loaded true
