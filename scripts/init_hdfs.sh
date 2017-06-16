#!/usr/bin/env bash

log () {
    echo $(date "+%y/%m/%d %H:%M:%S") "$1 init_hdfs.sh: $2"
}

log INFO "Wait for namenode"
while test $(curl -s -o /dev/null -w '%{http_code}' localhost:50070) != 200 ; do
    sleep 3
    log INFO "Wait for namenode"
done

# Set attributes on root directory.  It needs to be world writable so that
#  other processes (e.g., solr, spark) can create directories for their storage.
log INFO "Setting root directory permissions"
bin/hdfs dfs -chmod 777 /

log INFO "Setting root directory ownership"
bin/hdfs dfs -chown hdfs:hdfs /