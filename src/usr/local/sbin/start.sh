#! /usr/bin/env bash

# Fail hard and fast
set -eo pipefail

echo "Start rukbate zookeeper instance ..."

ZOOKEEPER_ID=${ZOOKEEPER_ID:-1}
echo "ZOOKEEPER_ID=$ZOOKEEPER_ID"

echo $ZOOKEEPER_ID > /var/lib/zookeeper/myid

ZOOKEEPER_TICK_TIME=${ZOOKEEPER_TICK_TIME:-2000}
echo "tickTime=${ZOOKEEPER_TICK_TIME}" > /opt/zookeeper/conf/zoo.cfg
echo "tickTime=${ZOOKEEPER_TICK_TIME}"

ZOOKEEPER_INIT_LIMIT=${ZOOKEEPER_INIT_LIMIT:-10}
echo "initLimit=${ZOOKEEPER_INIT_LIMIT}" >> /opt/zookeeper/conf/zoo.cfg
echo "initLimit=${ZOOKEEPER_INIT_LIMIT}"

ZOOKEEPER_SYNC_LIMIT=${ZOOKEEPER_SYNC_LIMIT:-5}
echo "syncLimit=${ZOOKEEPER_SYNC_LIMIT}" >> /opt/zookeeper/conf/zoo.cfg
echo "syncLimit=${ZOOKEEPER_SYNC_LIMIT}"

echo "dataDir=/var/lib/zookeeper" >> /opt/zookeeper/conf/zoo.cfg
echo "clientPort=2181" >> /opt/zookeeper/conf/zoo.cfg

ZOOKEEPER_CLIENT_CNXNS=${ZOOKEEPER_CLIENT_CNXNS:-60}
echo "maxClientCnxns=${ZOOKEEPER_CLIENT_CNXNS}" >> /opt/zookeeper/conf/zoo.cfg
echo "maxClientCnxns=${ZOOKEEPER_CLIENT_CNXNS}"

ZOOKEEPER_AUTOPURGE_SNAP_RETAIN_COUNT=${ZOOKEEPER_AUTOPURGE_SNAP_RETAIN_COUNT:-3}
echo "autopurge.snapRetainCount=${ZOOKEEPER_AUTOPURGE_SNAP_RETAIN_COUNT}" >> /opt/zookeeper/conf/zoo.cfg
echo "autopurge.snapRetainCount=${ZOOKEEPER_AUTOPURGE_SNAP_RETAIN_COUNT}"

ZOOKEEPER_AUTOPURGE_PURGE_INTERVAL=${ZOOKEEPER_AUTOPURGE_PURGE_INTERVAL:-0}
echo "autopurge.purgeInterval=${ZOOKEEPER_AUTOPURGE_PURGE_INTERVAL}" >> /opt/zookeeper/conf/zoo.cfg
echo "autopurge.purgeInterval=${ZOOKEEPER_AUTOPURGE_PURGE_INTERVAL}"

for VAR in `env`
do
  if [[ $VAR =~ ^ZOOKEEPER_SERVER_[0-9]+= ]]; then
    SERVER_ID=`echo "$VAR" | sed -r "s/ZOOKEEPER_SERVER_(.*)=.*/\1/"`
    SERVER_IP=`echo "$VAR" | sed 's/.*=//'`
    if [ "${SERVER_ID}" = "${ZOOKEEPER_ID}" ]; then
      echo "server.${SERVER_ID}=0.0.0.0:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
      echo "server.${SERVER_ID}=0.0.0.0:2888:3888"
    else
      echo "server.${SERVER_ID}=${SERVER_IP}:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
      echo "server.${SERVER_ID}=${SERVER_IP}:2888:3888"
    fi
  fi
  if [[ $VAR =~ ^GROUP_[0-9]+= ]]; then
    GROUP_ID=`echo "$VAR" | sed -r "s/GROUP_(.*)=.*/\1/"`
    GROUP_MEMBERS=`echo "$VAR" | sed 's/.*=//'`
    echo "server.${GROUP_ID}=${GROUP_MEMBERS}" >> /opt/zookeeper/conf/zoo.cfg
  fi
  if [[ $VAR =~ ^WEIGHT_[0-9]+= ]]; then
    SERVER_ID=`echo "$VAR" | sed -r "s/WEIGHT_(.*)=.*/\1/"`
    SERVER_WEIGHT=`echo "$VAR" | sed 's/.*=//'`
    echo "weight.${SERVER_ID}=${SERVER_WEIGHT}" >> /opt/zookeeper/conf/zoo.cfg
  fi
done

su zookeeper -s /bin/bash -c "/opt/zookeeper/bin/zkServer.sh start-foreground"
