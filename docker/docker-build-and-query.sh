#!/usr/bin/env bash

set -e

if [ "${1:0:1}" = '-' ]; then
	set -- postgres "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'postgres' ] && [ "$(id -u)" = '0' ]; then

	mkdir -p "$PGDATA"
	chown -R postgres "$PGDATA"
	chmod 700 "$PGDATA"

	mkdir -p /var/run/postgresql
	chown -R postgres /var/run/postgresql
	chmod 775 /var/run/postgresql

	# Create the transaction log directory before initdb is run (below) so the directory is owned by the correct user
	if [ "$POSTGRES_INITDB_WALDIR" ]; then
		mkdir -p "$POSTGRES_INITDB_WALDIR"
		chown -R postgres "$POSTGRES_INITDB_WALDIR"
		chmod 700 "$POSTGRES_INITDB_WALDIR"
	fi

	gosu postgres /start-postgres-db.sh

  # Now run the user scripts.
	psql+=(psql -U "${POSTGRES_USER:-postgres}" -d "$POSTGRES_DB" )
	for f in /scripts/build/* /scripts/run/* ; do
		case "$f" in
			*.sh)     echo "Running user script :: $f"; . "$f" ;;
			*.sql)    echo "Running user script :: $f"; "${psql[@]}" -f "$f"; echo ;;
			*.sql.gz) echo "Running user script :: $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
			*)        echo "Skipping $f -- sql/sh only!!" ;;
		esac
		echo
	done

  gosu postgres /stop-postgres-db.sh 
  exit 0

fi


echo "Running in pass-through mode: $@"
exec "$@"




