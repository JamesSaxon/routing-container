#!/bin/bash 

gosu postgres pg_ctl -U ${PGUSER:-postgres} -D "$PGDATA" -m fast -w stop

