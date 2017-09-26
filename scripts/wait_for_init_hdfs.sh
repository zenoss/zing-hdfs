#!/usr/bin/env bash
# 
# wait_for_init_hdfs.sh - wait until the namenode has started and the filesystem is ready.
#  
# Waits until the actions defined in init_hdfs.sh have finished.
#

log () {
	echo $(date "+%y/%m/%d %H:%M:%S") "$1 $(basename $0): $2"
}

log INFO "Wait for namenode"
while test $(curl -s -o /dev/null -w '%{http_code}' hdfs-namenode:50070) != 200 ; do
	sleep 3
	log INFO "Wait for namenode"
done

log INFO "Wait for filesystem initialization"
while [ $(bin/hdfs dfs -ls -d / | awk '{print $4}') != "hdfs" ]; do
	sleep 3
	log INFO "Wait for filesystem initialization"
done

log INFO "filesystem initialization complete"

