#!/bin/bash

log () {
	echo $(date "+%y/%m/%d %H:%M:%S") "$1 $(basename $0): $2"
}

# Render the templates into place
SOURCE=${CONFIG_TYPE:=dev}
( cd /usr/local/hadoop/etc/hadoop
    envsubst <$SOURCE/core-site.xml.template >core-site.xml
    envsubst <$SOURCE/hdfs-site.xml.template >hdfs-site.xml
)

# Read the 1st arg, and based upon one of the five: format or bootstrap or start the particular service
# NN and ZKFC stick together
MODE=$1
case "$MODE" in
  active)
    if [[ ! -a /data/hdfs/nn/current/VERSION ]]; then
      log INFO "Format Namenode.."
      $HADOOP_PREFIX/bin/hdfs namenode -format

      log INFO "Format Zookeeper for Fast failover.."
      $HADOOP_PREFIX/bin/hdfs zkfc -formatZK

      log INFO "InitializeSharedEdits.."
      $HADOOP_PREFIX/bin/hdfs namenode -initializeSharedEdits
    fi
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start zkfc
    $HADOOP_PREFIX/bin/hdfs namenode
    ;;
  standby)
    if [[ ! -a /data/hdfs/nn/current/VERSION ]]; then
      log INFO "Bootstrap Standby Namenode.."
      $HADOOP_PREFIX/bin/hdfs namenode -bootstrapStandby
    fi
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start zkfc
    $HADOOP_PREFIX/bin/hdfs namenode
    ;;
  zkfc)
    $HADOOP_PREFIX/bin/hdfs zkfc
    ;;
  journalnode)
    $HADOOP_PREFIX/bin/hdfs journalnode
    ;;
  bash)
    /bin/bash
    ;;
  namenode)
    if [[ ! -a /data/hdfs/nn/current/VERSION ]]; then
      log INFO "Format Namenode.."
      $HADOOP_PREFIX/bin/hdfs namenode -format
    fi
    init_hdfs.sh &
    $HADOOP_PREFIX/bin/hdfs namenode
    ;;
  datanode)
    wait_for_init_hdfs.sh
    sleep 30
    $HADOOP_PREFIX/bin/hdfs datanode
    ;;
  *)
    echo $"Usage: {active|standby|zkfc|journalnode|datanode|bash|namenode}"
    eval $*
esac
