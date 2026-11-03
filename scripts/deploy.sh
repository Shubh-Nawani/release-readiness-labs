#!/usr/bin/env bash
set -euo pipefail
IMAGE=${1:?Usage: deploy.sh IMAGE}
PORT=${LAB_PORT:-38080}
EXPECTED_VERSION=${EXPECTED_VERSION:-2.3.0}
docker image inspect "$IMAGE" >/dev/null
docker rm -f orderflow-ca3 >/dev/null 2>&1 || true
docker run -d --name orderflow-ca3 -p "127.0.0.1:${PORT}:3000" "$IMAGE" >/dev/null
for attempt in {1..30}; do
  if RESPONSE=$(curl -fsS "http://127.0.0.1:${PORT}/health" 2>/dev/null); then
    if printf '%s' "$RESPONSE" | EXPECTED_VERSION="$EXPECTED_VERSION" node -e '
      let body=""; process.stdin.on("data", c=>body+=c);
      process.stdin.on("end", ()=>{ const r=JSON.parse(body);
        if(r.status!=="ok" || r.version!==process.env.EXPECTED_VERSION) process.exit(1); });'; then
      echo "Local lab verified: $IMAGE on port $PORT"
      echo "$RESPONSE"
      exit 0
    fi
  fi
  sleep 1
done
echo 'Health/version check failed; inspect logs and consider rollback.' >&2
docker logs orderflow-ca3 >&2
exit 1
