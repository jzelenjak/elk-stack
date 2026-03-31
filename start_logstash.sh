#!/bin/bash
# Creates a Logstash container.
# To test connectivity to Elasticsearch, you can run:
#  curl --cacert /usr/share/logstash/config/certs/ca.crt -u "elastic:${ELASTIC_PASSWORD}" -XGET https://es01:9200/

set -euo pipefail
IFS=$'\n\t'


LOGSTASH_DIR="/usr/share/logstash"
LOGSTASH_PIPELINE_DIR="${LOGSTASH_DIR}/pipeline"
LOGSTASH_CONF_DIR="${LOGSTASH_DIR}/config"
LOGSTASH_CERT_DIR="${LOGSTASH_CONF_DIR}/certs"
LOGSTASH_CONF="logstash.conf"

[ -f .env ] && source .env || { echo "$0: cannot find .env file" >&2; exit 1; }

docker run --rm --name "logstash02" --network "elk-net" \
    -v "$(pwd)/${LOGSTASH_CONF}:${LOGSTASH_PIPELINE_DIR}/${LOGSTASH_CONF}" \
    -v "elk_stack_pubcerts:${LOGSTASH_CERT_DIR}" \
    -v "elk_stack_logstashdata02:${LOGSTASH_DIR}/data" \
    -v "$(pwd)/logstash_ingest_data:${LOGSTASH_DIR}/ingest_data" \
    -e ELASTIC_HOSTS="https://es01:9200" \
    -e ELASTIC_USER="elastic" \
    -e ELASTIC_PASSWORD="${ELASTIC_PASSWORD}" \
    -e ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES="${LOGSTASH_CERT_DIR}/ca.crt" \
    --memory "${LS_MEM_LIMIT}" \
    docker.elastic.co/logstash/logstash:${STACK_VERSION}

