#!/bin/bash
# ./build_start.sh -p 1234
unset -v id
unset -v port
unset -v brokers
unset -v edge
unset -v tag
unset -v srt_passphrase
unset -v health_port

while getopts i:p:b:f:t:s:h: opt; do
        case $opt in
                i) id=$OPTARG ;;
                p) port=$OPTARG ;;
                b) brokers=$OPTARG ;;
                f) edge=$OPTARG ;;
                t) tag=$OPTARG ;;
                s) srt_passphrase=$OPTARG ;;
                h) health_port=$OPTARG ;;
                *)
                        echo 'Error in command line parsing' >&2
                        exit 1
        esac
done

shift "$(( OPTIND - 1 ))"

if [ -z "$id" ] || [ -z "$port" ] || [ -z "$brokers" ]; then
        echo 'Missing -i or -p' >&2
        exit 1
fi

echo "Server Port: $port";
time DOCKER_BUILDKIT=1 docker build . -t $tag && \
 docker run -it \
 --network app-tier \
 -e SERVER_PORT=$port \
 -e HEALTH_CHECK_PORT=$health_port \
 -e SERVER_ID=$id \
 -e KAFKA_BROKER_LIST=$brokers \
  -e SRT_PASSPHRASE=$srt_passphrase \
 -e DB_USER=admin \
 -e DB_HOST=la79y-postgres \
 -e DB_DATABASE=la79y \
 -e DB_PASSWORD='1234' \
 -e DB_PORT=5432 \
 -p $port:$port/udp \
 -p $health_port:$health_port/tcp \
 $tag node $edge