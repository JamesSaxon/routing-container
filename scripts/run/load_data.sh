#!/bin/bash 

psql+=(psql -U postgres -d postgres -p 5432 -h localhost)
for f in ./scripts/run/0* ; do
	case "$f" in
		*.sh)     echo "Running user script :: $f"; . "$f" ;;
		*.sql)    echo "Running user script :: $f"; "${psql[@]}" -f "$f"; echo ;;
		*.sql.gz) echo "Running user script :: $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
		*)        echo "Skipping $f -- sql/sh only!!" ;;
	esac
	echo
done


# user_script=$1
for user_script in ./scripts/run/driving* ; do
  case "${user_script}" in
  	*.sh)     echo "Running user script :: ${user_script}"; . "${user_script}" ;;
  	*.sql)    echo "Running user script :: ${user_script}"; "${psql[@]}" -f "${user_script}"; echo ;;
  	*.sql.gz) echo "Running user script :: ${user_script}"; gunzip -c "$f" | "${psql[@]}"; echo ;;
  	*)        echo "Skipping $f -- sql/sh only!!" ;;
  esac
done

# psql -U postgres -d postgres -p 5432 -h localhost -f scripts/run/driving.sql


