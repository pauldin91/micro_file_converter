#!/bin/bash
set -euo pipefail
routing_key="$1"
sample_dir="./samples"
json_path="$sample_dir/$2"

while IFS= read -r item; do
  uuid=$(uuidgen)
  echo "id=$uuid"
  upload_dir="./uploads/$uuid"
  
  rm -rf "$upload_dir"
  mkdir -p "$upload_dir"
  
  cp "$sample_dir"/*.png "$upload_dir/"
  echo "$item" > "$upload_dir/$uuid.json"
  payload="$(echo "$item" | jq --arg id "$uuid" '. + {id: $id}+{timestamp: (now|todateiso8601)}')"

  curl -s -u guest:guest \
  -H "Content-Type: application/json" \
  -X POST "http://localhost:15672/api/exchanges/%2F/amq.default/publish" \
  -d "$(jq -n \
    --arg rk "$routing_key" \
    --argjson p "$payload" \
    '{properties: {}, routing_key: $rk, payload: ($p | tojson), payload_encoding: "string"}')"

done < <(jq -c '.[]' "$json_path")

