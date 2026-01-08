#!/bin/bash
set -euo pipefail

test_dir=4536e1fb-82c1-4fb2-a40e-5a46e4254496

pwd
ls uploads
mkdir -p "./uploads/$test_dir"
cp ./scripts/rabbit/*.png "./uploads/$test_dir/"
cp ./scripts/rabbit/*.json "./uploads/$test_dir"

docker exec -i rabbit sh -c '
  rabbitmqadmin publish \
    exchange=amq.default \
    routing_key="$1" \
    payload="$(cat)"
' sh "$1" < "$2"



