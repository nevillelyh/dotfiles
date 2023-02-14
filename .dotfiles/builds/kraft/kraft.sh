#!/bin/bash

set -euo pipefail

bin/kafka-storage format \
    --config etc/kafka/kraft/server.properties \
    --cluster-id "$(bin/kafka-storage random-uuid)"
bin/kafka-server-start etc/kafka/kraft/server.properties "$@"
