FROM postgres:10
MAINTAINER James Saxon <jsaxon@uchicago.edu>

ENV POSTGIS_MAJOR 2.4
ENV POSTGIS_VERSION 2.4.3+dfsg-4.pgdg90+1
ENV PGROUTING_MAJOR 2.3
ENV PGROUTING_VERSION 2.3.0-1

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
           postgis=$POSTGIS_VERSION \
			     postgresql-$PG_MAJOR-pgrouting \
					 vim wget \
           git pkg-config build-essential

# osm2pgrouting Requirements
RUN apt-get install -y  cmake expat libexpat1-dev \
  libboost-dev libboost-program-options-dev libpqxx-dev

# compile osm2pgrouting
ENV OSM_2_PGROUTING_VERSION=2.3.3
RUN git clone https://github.com/pgRouting/osm2pgrouting.git
RUN cd osm2pgrouting && \
    git fetch --all && git checkout v${OSM_2_PGROUTING_VERSION} && \
    cmake -H. -Bbuild && \
    cd build/ && make && make install

COPY docker-build-and-query.sh \
     start-postgres-db.sh \
     stop-postgres-db.sh \
     /usr/local/bin/

RUN ln -s usr/local/bin/docker-build-and-query.sh /
RUN ln -s usr/local/bin/start-postgres-db.sh /
RUN ln -s usr/local/bin/stop-postgres-db.sh /

ENTRYPOINT ["docker-build-and-query.sh"]


