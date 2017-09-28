#!/usr/bin/env bash
# 
# wait_for_namenode.sh - wait until the namenode is ready.
#  
# If the datanode process starts before the namenode is ready, the datanode
# will wind up in a state where it doesn't connect even after the namenode is
# available.  (Datanode acts as though it only does DNS resolution once at
# startup.)  Solution: wait for the namenode before starting datanode.


log () {
       echo $(date "+%y/%m/%d %H:%M:%S") "$1 $(basename $0): $2"
}

log INFO "Wait for namenode"
while test $(curl -s -o /dev/null -w '%{http_code}' hdfs-namenode:50070) != 200 ; do
       sleep 3
       log INFO "Wait for namenode"
done
