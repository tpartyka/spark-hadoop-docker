#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service ssh start

if [[ $1 = "-namenode" || $2 = "-namenode" ]]; then
  $HADOOP_PREFIX/sbin/start-dfs.sh
  $HADOOP_PREFIX/sbin/start-yarn.sh
fi

#if [[ $1 = "-datanode" || $2 = "-datanode" ]]; then
#  $HADOOP_PREFIX/sbin/start-dfs.sh
#fi

if [[ $1 = "-d" || $2 = "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 = "-bash" || $2 = "-bash" ]]; then
  /bin/bash
fi