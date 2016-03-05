#!/bin/bash - 
#===============================================================================
#
#          FILE: sample_config.sh
# 
#         USAGE: source ./sample_config.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tyler Stapler (tstapler), tystapler@gmail.com
#  ORGANIZATION: 
#       CREATED: 03/04/2016 19:44
#      REVISION:  ---
#===============================================================================
if [ -z ${DB_HOST+x} ]; then
	echo export DB_HOST=127.0.0.1
	export DB_HOST=127.0.0.1
fi

if [ -z ${DB_USER+x} ]; then
	echo export DB_USER=postgres export DB_USER=postgres
fi

if [ -z ${DB_PASS+x} ]; then
	echo export DB_PASS=pass
	export DB_PASS=pass
fi

if [ -z ${DB_PORT+x} ]; then
	echo export DB_PORT=5433
	export DB_PORT=5433
fi

if [ -z ${DB_NAME+x} ]; then
	echo export DB_NAME=skydev
	export DB_NAME=skydev
fi



