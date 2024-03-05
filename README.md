# la79y-edge-node-v2
```git clone  --recurse-submodules https://github.com/la79y/la79y-origin-node-v2.git```


## Requirement
- docker
- 
# Dependencies
- https://github.com/Eyevinn/node-srt

has been customized to do some fixes:
`git submodule add https://github.com/bander-saeed94/node-srt`


## Build and run origin application
note building docker needs internet as it checkout and clone SRT C library
- With custom origin ID (-i) and exposed port (-p),  (-f) file to start, (-t) image tag:
  ```sh
    ./build_start_edge.sh -i 1 -p 1235 -b kafka-server:9092 -t nodejs-edge-rdkafka-v2 -f edge_docker_server_v2.js
  ```
    ```sh
    ./build_start_edge.sh -i 1 -p 1235 -b kafka-1:9092,kafka-2:9092,kafka-3:9092 -t nodejs-edge-rdkafka-v2 -f edge_docker_server_v2.js
  ```
   ```sh
    ./build_start_edge.sh -i 1 -p 1235 -b kafka-1:9092 -t nodejs-edge-rdkafka-v2 -f edge_docker_server_v2.js
  ```
  ```sh
    ./build_start_edge.sh -i 1 -p 1235 -h 9999 -b kafka-1:9092,kafka-2:9092,kafka-3:9092 -t nodejs-edge-rdkafka-v2 -f edge_docker_server_v2.js
  ```
## To play the stream

to play multiple streams needs to change u(user) in streamId and specify resource:
```sh
    ffplay -fflags nobuffer -err_detect ignore_err -i 'srt://127.0.0.1:1235?streamid=#!::u=bander1234,r=livestream4,m=request,t=stream,s=Session_ID'

```


## Deploy on K8S
```shell
gcloud container clusters get-credentials lahthi-cluster --region me-central1 --project final-project-413218
```
```shell
kubectl apply -f 00-namespace.yaml
kubectl apply -f k8s.yaml

#check service has external ip
kubectl get service -n edge-namespace
kubectl describe service edge-service-udp -n edge-namespace

```


## Play edge k8s
```shell
    ffplay -fflags nobuffer -err_detect ignore_err -i 'srt://34.18.61.144:10081?streamid=#!::u=bander1234,r=livestream4,m=request,t=stream,s=Session_ID' -vf "fps=fps=1"
```
digital ocean
```shell
    ffplay -fflags nobuffer -err_detect ignore_err -i 'srt://164.90.241.38:10081?streamid=#!::u=bander1234,r=livestream4,m=request,t=stream,s=Session_ID' -vf "fps=fps=1"
```

