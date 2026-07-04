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

require_grep "twrp_lemonadep" "AndroidProducts.mk" "AndroidProducts.mk must reference twrp_lemonadep"
require_grep "twrp_lemonadep" "twrp_lemonadep.mk" "twrp_lemonadep.mk must define twrp_lemonadep"
require_grep "twrp_lemonadep-ap2a-eng" "AndroidProducts.mk" "AndroidProducts.mk must expose twrp_lemonadep-ap2a-eng"
require_grep "TW_INCLUDE_FBE_METADATA_DECRYPT[[:space:]]*:=[[:space:]]*true" "device.mk" "device.mk must enable FBE metadata decrypt"
require_grep "PRODUCT_ENABLE_UFFD_GC[[:space:]]*:=[[:space:]]*true" "device.mk" "device.mk must explicitly enable UFFD GC"
require_grep "vendor_dlkm.*erofs" "recovery/root/system/etc/recovery.fstab" "recovery.fstab must mount vendor_dlkm as erofs"
find "${root}/.github/scripts" -name "*.sh" -print0 | xargs -0 -r bash -n

if command -v xmllint >/dev/null 2>&1; then
	find "${root}" -path "*/vintf/*.xml" -print0 | xargs -0 -r xmllint --noout
fi
