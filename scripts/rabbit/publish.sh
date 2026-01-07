#!/bin/bash
set -euo pipefail

docker exec -i rabbit sh -c '
  rabbitmqadmin publish \
    exchange=amq.default \
    routing_key="$1" \
    payload="$(cat)"
' sh "$1" < "$2"

