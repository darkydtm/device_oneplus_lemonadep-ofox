#!/usr/bin/env bash
set -euo pipefail

root="${1:?tree root is required}"

require_file() {
	local file="$1"

	if [[ ! -f "${root}/${file}" ]]; then
		echo "Missing ${file}" >&2
		exit 1
	fi
}

require_grep() {
	local pattern="$1"
	local file="$2"
	local message="$3"

	if ! grep -Eq "${pattern}" "${root}/${file}"; then
		echo "${message}" >&2
		exit 1
	fi
}

require_file "AndroidProducts.mk"
require_file "BoardConfig.mk"
require_file "device.mk"
require_file "twrp_lemonadep.mk"
require_file "recovery/root/system/etc/recovery.fstab"
require_file "recovery/root/system/etc/twrp.flags"
require_file "recovery/root/system/bin/fix-invalid-vintf-manifest.sh"
require_file ".github/workflows/build-orangefox.yml"

require_grep "twrp_lemonadep" "AndroidProducts.mk" "AndroidProducts.mk must reference twrp_lemonadep"
require_grep "twrp_lemonadep" "twrp_lemonadep.mk" "twrp_lemonadep.mk must define twrp_lemonadep"
require_grep "twrp_lemonadep-ap2a-eng" "AndroidProducts.mk" "AndroidProducts.mk must expose twrp_lemonadep-ap2a-eng"
require_grep "TARGET_OTA_ASSERT_DEVICE[[:space:]]*:=[[:space:]]*OnePlus9Pro,lemonadep" "BoardConfig.mk" "BoardConfig.mk must assert OnePlus9Pro and lemonadep"
require_grep "PRODUCT_DEVICE[[:space:]]*:=[[:space:]]*lemonadep" "twrp_lemonadep.mk" "twrp_lemonadep.mk must target lemonadep"
require_grep "PRODUCT_SYSTEM_DEVICE[[:space:]]*:=[[:space:]]*OnePlus9Pro" "twrp_lemonadep.mk" "twrp_lemonadep.mk must expose OnePlus9Pro system device"
require_grep "FOX_TARGET_DEVICES[[:space:]]*:=[[:space:]]*OnePlus9Pro,lemonadep" "twrp_lemonadep.mk" "twrp_lemonadep.mk must expose OnePlus9Pro and lemonadep to OrangeFox"
require_grep "TARGET_DEVICE_ALT[[:space:]]*:=[[:space:]]*OnePlus9Pro" "twrp_lemonadep.mk" "twrp_lemonadep.mk must expose OnePlus9Pro to the OrangeFox installer"
require_grep "TARGET_DEVICE_ALT=.*TARGET_DEVICE_ALT" ".github/scripts/patch-orangefox-tree.sh" "patch-orangefox-tree.sh must pass TARGET_DEVICE_ALT to OrangeFox"
require_grep "TARGET_DEVICE_ALT:[[:space:]]*OnePlus9Pro" ".github/workflows/build-orangefox.yml" "build workflow must export TARGET_DEVICE_ALT"
require_grep "env TARGET_DEVICE_ALT" ".github/scripts/run-orangefox-container.sh" "container wrapper must pass TARGET_DEVICE_ALT"
if grep -Eq "OF_TARGET_DEVICES[[:space:]]*:=" "${root}/twrp_lemonadep.mk"; then
	echo "twrp_lemonadep.mk must not use obsolete OF_TARGET_DEVICES" >&2
	exit 1
fi
require_grep "TW_INCLUDE_FBE_METADATA_DECRYPT[[:space:]]*:=[[:space:]]*true" "device.mk" "device.mk must enable FBE metadata decrypt"
require_grep "PRODUCT_ENABLE_UFFD_GC[[:space:]]*:=[[:space:]]*true" "twrp_lemonadep.mk" "twrp_lemonadep.mk must explicitly enable UFFD GC"
require_grep "vendor_dlkm.*erofs" "recovery/root/system/etc/recovery.fstab" "recovery.fstab must mount vendor_dlkm as erofs"
require_grep "fix-invalid-vintf-manifest\\.sh" "recovery/root/init.recovery.qcom.rc" "init.recovery.qcom.rc must run the VINTF manifest fix"
require_grep "default:[[:space:]]*bootimage" ".github/workflows/build-orangefox.yml" "build workflow must default to bootimage"
require_grep "DEFAULT_TARGET:[[:space:]]*bootimage" ".github/workflows/build-orangefox.yml" "build workflow DEFAULT_TARGET must be bootimage"

if [[ ! -x "${root}/recovery/root/system/bin/fix-invalid-vintf-manifest.sh" ]]; then
	echo "fix-invalid-vintf-manifest.sh must be executable" >&2
	exit 1
fi

if grep -Eq "^[[:space:]]*(mkdir /mnt/firmware|mount vfat .*modem|exec .*adsp|umount /mnt/firmware)" "${root}/recovery/root/init.recovery.qcom.rc"; then
	echo "init.recovery.qcom.rc must not copy modem firmware during recovery boot" >&2
	exit 1
fi

find "${root}/.github/scripts" -name "*.sh" -print0 | xargs -0 -r bash -n

if command -v xmllint >/dev/null 2>&1; then
	find "${root}" -path "*/vintf/*.xml" -print0 | xargs -0 -r xmllint --noout
fi
