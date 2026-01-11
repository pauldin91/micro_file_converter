#!/bin/bash
set -euo pipefail

test_dir=4536e1fb-82c1-4fb2-a40e-5a46e4254496
upload_dir=./uploads/$test_dir
sample_dir=./scripts/rabbit/

rm -rf "$upload_dir"
mkdir -p "$upload_dir"

cp "$sample_dir"/*.png "$upload_dir/"
cp "$sample_dir"/*.json "$upload_dir"

docker exec -i rabbit sh -c '
  rabbitmqadmin publish \
    exchange=amq.default \
    routing_key="$1" \
    payload="$(cat)"
' sh "$1" < "$2"



