#!/bin/bash 

gosu postgres pg_ctl -D "$PGDATA" -o "-c listen_addresses='localhost'" -w start

