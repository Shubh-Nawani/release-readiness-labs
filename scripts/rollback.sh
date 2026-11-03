#!/usr/bin/env bash
set -euo pipefail
PREVIOUS_IMAGE=${1:?Usage: rollback.sh PREVIOUS_IMAGE EXPECTED_VERSION}
export EXPECTED_VERSION=${2:?Supply the previous release version}
echo "Restoring previous local lab image: $PREVIOUS_IMAGE"
bash "$(dirname "$0")/deploy.sh" "$PREVIOUS_IMAGE"
