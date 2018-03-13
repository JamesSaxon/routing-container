
docker build --no-cache -t route .

docker run --rm -it --name routing-instance -v `pwd`:/docker-entrypoint-initdb.d  -e POSTGRES_PASSWORD=mysecretpassword route /bin/bash
