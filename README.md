# ELK Stack

This repository contains the ELK (Elasticsearch, Logstash, Kibana) Stack configuration as a starting point to learn the stack. 


## Setup

The [docker-compose.yml](./docker-compose.yml) file contains the configuration for Elasticsearch, Kibana, and Logstash containers.

The configuration is based on the [setup tutorial](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose) as well as the official documentation ([basic setup](https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-elasticsearch-docker-basic) and [docker compose setup](https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-elasticsearch-docker-compose)).
Note that the Logstash configuration provided in the tutorial does not work due to permissions on the certificate files, because the `logstash` container does not (and cannot) run as root (see [this post](https://discuss.elastic.co/t/how-to-use-ssl-certificate-authorities-in-logstash/379517) or [this pull request to the tutorial repo](https://github.com/elkninja/elastic-stack-docker-part-one/pull/37) for the problem explanation). To avoid changing the file and directory permissions, we instead create a separate volume containing only the public CA certificate, which is then used by Logstash (and can be used by other containers) for certificate verification.


## Usage

Use standard Docker (Compose) commands to deploy the stack.

**NB! Make sure to run `source .env`, so that environment variables are set and properly resolved in the docker-compose.yml file.**
Otherwise Elasticsearch will generate a random password and other settings may be incorrect.

Once the Elasticsearch container (`es01`) is running, copy the public CA certificate for verification:
```bash
docker cp es01:/usr/share/elasticsearch/config/certs/ca/ca.crt .
```

To query the Elasticsearch node, run:
```bash
curl --cacert ca.crt -u elastic:$ELASTIC_PASSWORD -XGET 'https://localhost:9200?pretty'
```

To save some typing, you can use `curl.py` and `curl.sh` wrapper scripts in the [utils](./utils/) directory, which predefine some `curl` arguments, e.g.:
```bash
./utils/curl.py GET 'https://localhost:9200/{index}/_search?pretty' '{"query": {"match": {"field": "value"}}}'
./utils/curl.py GET '/{index}/_search?pretty' '{"query": {"match": {"field": "value"}}}'
./utils/curl.sh -XPOST 'https://localhost:9200/_bulk?pretty' --data-binary @documents.ndjson
```
(You can also create a symlink in the repository root directory for easier invocation, e.g. `ln -s utils/curl.py curl.py`.)

To parse or highlight the output, you can use `jq` command-line JSON processor (e.g. `... | jq` or `... | jq -r '.hits.hits.[]._id'`).
