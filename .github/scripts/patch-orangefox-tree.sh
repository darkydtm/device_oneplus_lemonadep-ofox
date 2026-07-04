#!/usr/bin/env bash
set -euo pipefail

tree_root="${1:?tree root is required}"
missing_lib="androidx.camera.extensions.impl"
config_file=""

for candidate in "${tree_root}/build/make/core/config.mk" "${tree_root}/build/core/config.mk"; do
	if [[ -f "${candidate}" ]]; then
		config_file="${candidate}"
		break
	fi
done

if [[ -z "${config_file}" ]]; then
	config_file="$(find "${tree_root}" -path "*/core/config.mk" -type f -print -quit)"
fi

if [[ -z "${config_file}" ]]; then
	echo "Unable to find Android core config.mk in ${tree_root}" >&2
	exit 1
fi

echo "Patching ${config_file}"

if ! grep -Fq "${missing_lib}" "${config_file}"; then
	printf '\nINTERNAL_PLATFORM_MISSING_USES_LIBRARIES += %s\n' "${missing_lib}" >> "${config_file}"
fi

grep -n "INTERNAL_PLATFORM_MISSING_USES_LIBRARIES\\|${missing_lib}" "${config_file}"
