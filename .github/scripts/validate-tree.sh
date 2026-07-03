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

require_file "AndroidProducts.mk"
require_file "BoardConfig.mk"
require_file "device.mk"
require_file "twrp_lemonadep.mk"
require_file "recovery/root/system/etc/recovery.fstab"
require_file "recovery/root/system/etc/twrp.flags"

grep -R "twrp_lemonadep" "${root}/AndroidProducts.mk" "${root}/twrp_lemonadep.mk" >/dev/null
grep -R "twrp_lemonadep-ap2a-eng" "${root}/AndroidProducts.mk" >/dev/null
grep -R "TW_INCLUDE_FBE_METADATA_DECRYPT := true" "${root}/device.mk" >/dev/null
grep -R "vendor_dlkm.*erofs" "${root}/recovery/root/system/etc/recovery.fstab" >/dev/null

if command -v xmllint >/dev/null 2>&1; then
	find "${root}" -path "*/vintf/*.xml" -print0 | xargs -0 -r xmllint --noout
fi
