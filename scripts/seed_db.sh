#!/bin/bash - 
#===============================================================================
#
#          FILE: seed_db.sh
# 
#         USAGE: ./seed_db.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tyler Stapler (tstapler), tystapler@gmail.com
#  ORGANIZATION: 
#       CREATED: 03/02/2016 15:16
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

dart bin/manage.dart --delete
dart bin/manage.dart --create
dart bin/manage.dart --seed=seeddata.yaml

exit
