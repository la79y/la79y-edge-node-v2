DOCKER_BUILDKIT=1 docker build --platform linux/amd64 . -t nodejs-edge-rdkafka-v4-amd64
docker tag nodejs-edge-rdkafka-v4-amd64:latest bandersaeed94/la79y:edge-v4
docker push bandersaeed94/la79y:edge-v4