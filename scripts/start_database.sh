#!/bin/bash -
#===============================================================================
#
#          FILE: start_database.sh
#
#         USAGE: ./start_database.sh
#
#   DESCRIPTION:
#	For running the postgres docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tyler Stapler (tstapler), tystapler@gmail.com
#  ORGANIZATION:
#       CREATED: 02/28/2016 14:57
#      REVISION:  ---
#===============================================================================

#Find the calling directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Try to start the docker container, if not create it and run
if [ ! $(docker start skydev-postgres) ]; then
	echo "SkyDev container does not exist, creating and running"
	docker run -p $DB_PORT:5432 --name skydev-postgres -e POSTGRES_PASSWORD=$DB_PASS -d postgres 
else 
	echo "Database running ..."
fi
