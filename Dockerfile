FROM postgres:13
MAINTAINER James Saxon <jsaxon@uchicago.edu>

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.1.1+dfsg-1.pgdg100+1
ENV PGROUTING_MAJOR 3.1
ENV PGROUTING_VERSION 3.1.0-2.pgdg100+1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
         postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
         postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
         postgis=$POSTGIS_VERSION \
			   postgresql-$PG_MAJOR-pgrouting \
				 vim wget osmium-tool \
         git pkg-config build-essential

# osm2pgrouting Requirements
RUN apt-get install -y cmake expat libexpat1-dev \
    libboost-dev libboost-program-options-dev libpqxx-dev

##  # compile osm2pgrouting
RUN git clone https://github.com/pgRouting/osm2pgrouting.git && \
    cd osm2pgrouting && cmake -H. -Bbuild && cd build/ && make && make install

COPY docker-build-and-query.sh \
     start-postgres-db.sh \
     stop-postgres-db.sh \
     /usr/local/bin/

RUN ln -s usr/local/bin/docker-build-and-query.sh /
RUN ln -s usr/local/bin/start-postgres-db.sh /
RUN ln -s usr/local/bin/stop-postgres-db.sh /

ENTRYPOINT ["docker-build-and-query.sh"]

