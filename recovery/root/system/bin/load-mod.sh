#!/system/bin/sh

LOG_FILE=/tmp/recovery.log
failed=0

log_module() {
	echo "load-mod: $*" >> "${LOG_FILE}"
}

log_vermagic() {
	module="$1"
	vermagic="$(/system/bin/modinfo -F vermagic "/lib/modules/${module}" 2>/dev/null)"

	if [ -n "${vermagic}" ]; then
		log_module "${module}: vermagic ${vermagic}"
	fi
}

load_module() {
	module="$1"
	shift
	name="${module%.ko}"

	if [ -d "/sys/module/${name}" ]; then
		log_module "${module}: already loaded"
		return 0
	fi

	if [ ! -f "/lib/modules/${module}" ]; then
		log_module "${module}: missing"
		failed=1
		return 1
	fi

	log_vermagic "${module}"
	log_module "${module}: insmod $*"

	/system/bin/insmod "/lib/modules/${module}" "$@" >> "${LOG_FILE}" 2>&1
	rc="$?"

	if [ "${rc}" = "0" ]; then
		log_module "${module}: loaded"
		return 0
	fi

	log_module "${module}: failed ${rc}"
	failed=1
	return "${rc}"
}

log_module "start"
load_module q6_pdr_dlkm.ko
load_module q6_notifier_dlkm.ko
load_module snd_event_dlkm.ko
load_module apr_dlkm.ko
load_module adsp_loader_dlkm.ko
load_module aw8697.ko
load_module haptic.ko
load_module msm_drm.ko dsi_display0=qcom,mdss_dsi_samsung_amb670yf01_dsc_cmd:config0

if [ "${failed}" != "0" ]; then
	/system/bin/setprop twrp.modules.failed true
	log_module "finished with failures"
else
	log_module "finished"
fi

/system/bin/setprop twrp.modules.loaded true
