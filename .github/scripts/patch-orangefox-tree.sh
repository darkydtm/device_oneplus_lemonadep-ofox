#!/usr/bin/env bash
set -euo pipefail

tree_root="${1:?tree root is required}"
bad_optional_uses_lib_module="CameraExtensionsProxy"
config_file=""
make_file=""

for candidate in "${tree_root}/build/make/core/config.mk" "${tree_root}/build/core/config.mk"; do
	if [[ -f "${candidate}" ]]; then
		config_file="${candidate}"
		break
	fi
done

if [[ -z "${config_file}" ]]; then
	config_file="$(find "${tree_root}" -path "*/core/config.mk" -type f -print -quit)"
fi

for candidate in "${tree_root}/build/make/core/Makefile" "${tree_root}/build/core/Makefile"; do
	if [[ -f "${candidate}" ]]; then
		make_file="${candidate}"
		break
	fi
done

if [[ -z "${make_file}" ]]; then
	make_file="$(find "${tree_root}" -path "*/core/Makefile" -type f -print -quit)"
fi

if [[ -z "${config_file}" ]]; then
	echo "Unable to find Android core config.mk in ${tree_root}" >&2
	exit 1
fi

if [[ -z "${make_file}" ]]; then
	echo "Unable to find Android core Makefile in ${tree_root}" >&2
	exit 1
fi

echo "Patching ${config_file}"

if ! grep -Eq "^BUILD_WARNING_BAD_OPTIONAL_USES_LIBS_ALLOWLIST[[:space:]]*[:+]?=.*(^|[[:space:]])${bad_optional_uses_lib_module}($|[[:space:]])" "${config_file}"; then
	if grep -Eq "^BUILD_WARNING_BAD_OPTIONAL_USES_LIBS_ALLOWLIST[[:space:]]*[:+]?=" "${config_file}"; then
		sed -i -E "0,/^(BUILD_WARNING_BAD_OPTIONAL_USES_LIBS_ALLOWLIST[[:space:]]*[:+]?=.*)$/s//\\1 ${bad_optional_uses_lib_module}/" "${config_file}"
	else
		tmp_file="$(mktemp)"
		awk -v module="${bad_optional_uses_lib_module}" '
			$0 == "include $(BUILD_SYSTEM)/soong_config.mk" && !inserted {
				print "BUILD_WARNING_BAD_OPTIONAL_USES_LIBS_ALLOWLIST += " module
				inserted = 1
			}
			{ print }
			END { exit inserted ? 0 : 1 }
		' "${config_file}" > "${tmp_file}"
		mv "${tmp_file}" "${config_file}"
	fi
fi

grep -n "BUILD_WARNING_BAD_OPTIONAL_USES_LIBS_ALLOWLIST" "${config_file}"

echo "Patching ${make_file}"

if ! grep -Fq 'TARGET_DEVICE_ALT="$(TARGET_DEVICE_ALT)"' "${make_file}"; then
	tmp_file="$(mktemp)"
	awk '
		{
			print
			if ($0 ~ /FOX_MANIFEST_VER=/ && $0 ~ /\\$/) {
				print "\tTARGET_DEVICE_ALT=\"$(TARGET_DEVICE_ALT)\" \\"
				print "\tFOX_TARGET_DEVICES=\"$(FOX_TARGET_DEVICES)\" \\"
			}
		}
	' "${make_file}" > "${tmp_file}"
	mv "${tmp_file}" "${make_file}"
fi

grep -n 'TARGET_DEVICE_ALT="$(TARGET_DEVICE_ALT)"' "${make_file}"
