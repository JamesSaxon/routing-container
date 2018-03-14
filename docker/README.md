
docker build --no-cache -t route .

docker run --rm -it --name routing-instance -v `pwd`:/docker-entrypoint-initdb.d  -e POSTGRES_PASSWORD=mysecretpassword route /bin/bash


Not clear that I can UNEXPOSE from a higher docker container.  Of course, I can always just _not_ map the port.  See this [thread](https://github.com/moby/moby/issues/3465) on the not-yet-implemented UNEXPOSE/UNSET feature, and EXPOSEd ports in particular.

> For those people here asking for UNEXPOSE; the EXPOSE statement only gives a hint which ports are exposed by the container, but does not actually expose those ports; you need to publish those ports (-p / -P) to expose them on the host. In other words; omitting the EXPOSE statement from a Dockerfile does have no direct effect on the image (you can still, e.g. reach "port 80" of the container).
> 
> Additionally, if you want to expose additional ports, just make the service in the container run on those ports, and this will work.

