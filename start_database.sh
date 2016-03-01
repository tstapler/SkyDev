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


PORT=5433
while getopts "p:" opt; do
	case $opt in
		p)
			echo "Running with port $OPTARG"
			PORT=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Setting port to default 5433" >&2
			;;

	esac
done

# Try to start the docker container, if not create it and run
if [ ! $(docker start skydev-postgres) ]; then 
	echo "SkyDev container does not exist, creating and running"
	docker run -p $PORT:5432 --name skydev-postgres -e POSTGRES_PASSWORD=pass -d postgres 
	exit 0
else 
	echo "Database running ..."
	exit 0
fi

