#!/usr/bin/env bash
set -euo pipefail

command="${1:?command is required}"
workspace="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
image="${ORANGEFOX_CONTAINER_IMAGE:-ghcr.io/sushrut1101/docker:arch}"
home_dir="${ORANGEFOX_CONTAINER_HOME:-/tmp/orangefox-home}"
container_command=$'set -eo pipefail\nmkdir -p "${HOME}"\n'"${command}"

docker run --rm \
	--volume "${workspace}:${workspace}" \
	--workdir "${workspace}" \
	--env HOME="${home_dir}" \
	--env GITHUB_WORKSPACE="${workspace}" \
	--env DEVICE \
	--env TARGET_RELEASE \
	--env OEM \
	--env FOX_SYNC_URL \
	--env DEFAULT_SYNC_BRANCH \
	--env DEFAULT_TARGET \
	--env TARGET_DEVICE_ALT \
	--env FOX_TARGET_DEVICES \
	--env SM8350_REPOSITORY_URL \
	--env SM8350_BRANCH \
	--env SYNC_BRANCH \
	--env BUILD_TARGET \
	--env J_VAL \
	--env OF_MAINTAINER \
	--env FOX_BUILD_TYPE \
	--env ALLOW_MISSING_DEPENDENCIES \
	--env FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER \
	--env LC_ALL \
	--env USE_CCACHE \
	--env CCACHE_DIR \
	--env CCACHE_SIZE \
	"${image}" \
	bash -lc "${container_command}"
