#!/usr/bin/env bash
set -euo pipefail

tree_root="${1:?tree root is required}"
config_file="${tree_root}/build/make/core/config.mk"
missing_lib="androidx.camera.extensions.impl"

test -f "${config_file}"

if ! grep -q "^  ${missing_lib} \\\\" "${config_file}"; then
	sed -i "/^INTERNAL_PLATFORM_MISSING_USES_LIBRARIES := \\\\/a\\  ${missing_lib} \\\\" "${config_file}"
fi

grep -A6 "^INTERNAL_PLATFORM_MISSING_USES_LIBRARIES :=" "${config_file}"
