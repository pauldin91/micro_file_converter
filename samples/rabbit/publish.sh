#!/bin/bash
set -euo pipefail

docker cp transform.message.json rabbit:/tmp/transform.message.json

docker exec -i rabbit sh -c '
  payload=$(cat /tmp/transform.message.json)
  rabbitmqadmin publish \
    exchange=amq.default \
    routing_key=batch.transform \
    payload="$payload"
'
