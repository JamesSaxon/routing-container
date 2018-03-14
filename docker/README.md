
docker build --no-cache -t route .

docker run --rm -it --name routing-instance -v `pwd`:/docker-entrypoint-initdb.d  -e POSTGRES_PASSWORD=mysecretpassword route /bin/bash


Not clear that I can UNEXPOSE from a higher docker container.  Of course, I can always just _not_ map the port:

https://github.com/moby/moby/issues/3465
