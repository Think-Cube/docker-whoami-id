#!/usr/bin/env bash
set -euo pipefail

image=${1:?usage: smoke.sh <image>}
name=whoami-smoke-$$

cleanup() {
  docker rm -f "$name" "$name-port" > /dev/null 2>&1 || true
}
trap cleanup EXIT

test "$(docker image inspect -f '{{.Config.User}}' "$image")" = "10001:10001"

# get <container> <container port>: wait for the server, then print its answer.
get() {
  local port
  port=$(docker port "$1" "$2/tcp" | head -1 | cut -d: -f2)
  for _ in $(seq 1 30); do
    curl -fsS "http://127.0.0.1:$port/" 2> /dev/null && return
    sleep 1
  done
  docker logs "$1"
  return 1
}

# Run with the same hardening as whoami@.service.
docker run -d --name "$name" --read-only --cap-drop ALL --security-opt no-new-privileges \
  -p 127.0.0.1::8000 "$image" > /dev/null
body=$(get "$name" 8000)
echo "$body"
test "$body" = "I'm $(docker inspect -f '{{.Config.Hostname}}' "$name")"

# PORT moves the listener.
docker run -d --name "$name-port" -e PORT=9000 -p 127.0.0.1::9000 "$image" > /dev/null
get "$name-port" 9000
