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

if ! grep -q "^  ${missing_lib} \\\\" "${config_file}"; then
	tmp_file="$(mktemp)"
	if ! awk -v lib="${missing_lib}" '
		BEGIN { inserted = 0 }
		/^INTERNAL_PLATFORM_MISSING_USES_LIBRARIES[[:space:]]*:=/ && !inserted {
			print
			print "  " lib " \\"
			inserted = 1
			next
		}
		{ print }
		END { if (!inserted) exit 1 }
	' "${config_file}" > "${tmp_file}"; then
		rm -f "${tmp_file}"
		echo "Unable to patch INTERNAL_PLATFORM_MISSING_USES_LIBRARIES in ${config_file}" >&2
		exit 1
	fi
	mv "${tmp_file}" "${config_file}"
fi

grep -A6 "^INTERNAL_PLATFORM_MISSING_USES_LIBRARIES[[:space:]]*:=" "${config_file}"
