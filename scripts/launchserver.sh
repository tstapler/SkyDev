#!/bin/bash - 
#===============================================================================
#
#          FILE: launchserver.sh
# 
#         USAGE: ./launchserver.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tyler Stapler (tstapler), tystapler@gmail.com
#  ORGANIZATION: 
#       CREATED: 03/02/2016 15:35
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

sleep 5
ansible-playbook scripts/database_provision.yaml
dart server.dart 

