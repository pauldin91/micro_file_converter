#!/bin/bash
set -euo pipefail
routing_key="$1"
sample_dir="./samples"

while IFS= read -r item; do
  uuid=$(uuidgen)
  echo "id=$uuid"
  upload_dir="./uploads/$uuid"
  
  rm -rf "$upload_dir"
  mkdir -p "$upload_dir"
  
  cp "$sample_dir"/*.png "$upload_dir/"
  echo "$item" > "$upload_dir/$uuid.json"
  payload="$(echo "$item" | jq --arg id "$uuid" '. + {id: $id}+{timestamp: (now|todateiso8601)}')"

  docker exec rabbit rabbitmqadmin publish \
    exchange=amq.default \
    routing_key="$routing_key" \
    payload="$payload"
done < <(jq -c '.[]' "$sample_dir"/*.json)
