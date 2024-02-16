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

## To play the stream

to play multiple streams needs to change u(user) in streamId and specify resource:
```sh
    ffplay -fflags nobuffer -i 'srt://127.0.0.1:1235?streamid=#!::u=bander1234,r=livestream3,m=request,t=stream,s=Session_ID'

```

