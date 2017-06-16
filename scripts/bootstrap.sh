#!/bin/bash


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
      echo "Format Namenode.."
      $HADOOP_PREFIX/bin/hdfs namenode -format

      echo "Format Zookeeper for Fast failover.."
      $HADOOP_PREFIX/bin/hdfs zkfc -formatZK

      echo "InitializeSharedEdits.."
      $HADOOP_PREFIX/bin/hdfs namenode -initializeSharedEdits
    fi
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start zkfc
    $HADOOP_PREFIX/bin/hdfs namenode
    ;;
  standby)
    if [[ ! -a /data/hdfs/nn/current/VERSION ]]; then
      echo "Bootstrap Standby Namenode.."
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
      echo "Format Namenode.."
      $HADOOP_PREFIX/bin/hdfs namenode -format
    fi
    init_hdfs.sh &
    $HADOOP_PREFIX/bin/hdfs namenode
    ;;
  datanode)
    $HADOOP_PREFIX/bin/hdfs datanode
    ;;
  *)
    echo $"Usage: {active|standby|zkfc|journalnode|datanode|bash|namenode}"
    eval $*
esac
