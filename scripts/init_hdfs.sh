#!/usr/bin/env bash

log () {
    echo $(date "+%y/%m/%d %H:%M:%S") "$1 init_hdfs.sh: $2"
}

export HADOOP_OPTS="-Ddfs.namenode.name.dir=file:///data/hdfs/nn -Dfs.defaultFS=hdfs://localhost:8020"
PATH=$PATH:$HADOOP_COMMON_HOME/bin

log INFO "Format HDFS"
hdfs namenode $HADOOP_OPTS -format -nonInteractive &>/dev/null

log INFO "Start namenode"
hdfs namenode $HADOOP_OPTS &>/dev/null &

log INFO "Wait for namenode"
while test $(curl -s -o /dev/null -w '%{http_code}' localhost:50070) != 200 ; do
    sleep 3
    log INFO "Wait for namenode"
done

# Set attributes on root directory.  It needs to be world writable so that
#  other processes (e.g., solr, spark) can create directories for their storage.
log INFO "Set root directory permissions"
hdfs dfs $HADOOP_OPTS -chmod 777 /

log INFO "Set root directory ownership"
hdfs dfs $HADOOP_OPTS -chown hdfs:hdfs /

log INFO "Terminate namenode"
kill %1
wait %1

log INFO "Done"
exit 0
