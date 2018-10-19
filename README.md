## Running it out of the box


The gist for the non-dockerized solution is here:

https://gist.github.com/JamesSaxon/94d17a1a603439bd4db59b480e0436bb

As of May 11 2018 it seems fine.  But it breaks regularly, as POSTGIS_VERSION updates.  Check this site when that happens:

https://packages.debian.org/sid/postgresql-10-postgis-2.4

You can also run the docker image from before the build fail, to get the right verison number:
```
$ docker run --rm -it XXX /bin/bash
root@XXX:/# apt list -a postgis
```

This solution is based off the standard postgres docker image

https://hub.docker.com/_/postgres/

That image is already a "non-standard" use of docker, and my implementation is even a weird use of _that_.  If you don't understand how the postgres image works, this won't make any sense.  Understand that first.

What the scripts do is to build the a routing database completely from scratch, every time, and then run a cost matrix query.  This is designed for lots of different areas of the OSM network, that you you want to run on many different machines.  If you're doing lots of work on one dedicated area, you would modify the Dockerfile to create the database once, and package that (this would reduce your computation costs at the price of the image size).

The input and output points go in a `scripts/input/chicago_tracts.csv` (I could change the name...).  Each line in that file is an `ID,lat,lon,direction`.  Direction can be 0, 1, or 2, for outgoing, incoming, or both.  If you pre-download an osm file, you can put that there, as well.  Also create the `scripts/output/` directory.  The completed csv will go there.

The folders `prebuild/` and `build/` contain scripts to be run by postgres user and root, respectively.  The former creates the extensions and loads the data in `input`.  The `build/` scripts start by loading the OSM network.  If `inputs/*osm` exists, it will load that.  If it doesn't, it will use `postgres` to buffer the points you just loaded, download an "appopriate" (caveat emptor!  check what OSM ways you want!) osm road network, and load that.  It will then set some default road speeds, and do a knn match from your locations nodes to the OSM nodes.

Finally, `run/01_cost_matrix.sh` runs.  This just uses `pgr_dijkstraCost` to get the answer.  It will write to `scripts/output/cost_matrix.csv`.  So again, make sure `scripts/output/` exists.

To build and run you'll do
```
git clone https://github.com/JamesSaxon/routing.git
cd routing/docker/
docker build --no-cache -t route .
mkdir -p scripts/input scripts/output
## put all your inputs and outputs in order...  
docker run --rm -it --name routing-instance -v $(pwd)/scripts/:/scripts  -e POSTGRES_PASSWORD=mysecretpassword route postgres
```


## On converting this to singularity

Not clear that I can UNEXPOSE from a higher docker container.  Of course, I can always just _not_ map the port.  See this [thread](https://github.com/moby/moby/issues/3465) on the not-yet-implemented UNEXPOSE/UNSET feature, and EXPOSEd ports in particular.

> For those people here asking for UNEXPOSE; the EXPOSE statement only gives a hint which ports are exposed by the container, but does not actually expose those ports; you need to publish those ports (-p / -P) to expose them on the host. In other words; omitting the EXPOSE statement from a Dockerfile does have no direct effect on the image (you can still, e.g. reach "port 80" of the container).
> 
> Additionally, if you want to expose additional ports, just make the service in the container run on those ports, and this will work.

See also the Docker reference on [EXPOSE](https://docs.docker.com/engine/reference/builder/#expose):
> The EXPOSE instruction does not actually publish the port. It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published. To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
