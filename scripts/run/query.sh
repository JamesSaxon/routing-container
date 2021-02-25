#!/bin/bash 


psql+=(psql -U "${POSTGRES_USER:-postgres}" -d "$POSTGRES_DB" )
for f in /scripts/run/0* ; do
	case "$f" in
		*.sh)     echo "Running user script :: $f"; . "$f" ;;
		*.sql)    echo "Running user script :: $f"; "${psql[@]}" -f "$f"; echo ;;
		*.sql.gz) echo "Running user script :: $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
		*)        echo "Skipping $f -- sql/sh only!!" ;;
	esac
	echo
done

user_script=$1
case "${user_script}" in
	*.sh)     echo "Running user script :: ${user_script}"; . "${user_script}" ;;
	*.sql)    echo "Running user script :: $f"; "${psql[@]}" -f "${user_script}"; echo ;;
	*)        echo "Skipping $f -- sql/sh only!!" ;;
esac


