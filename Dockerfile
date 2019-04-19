FROM debian:latest

WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
    software-properties-common openssh-server wget zip git gnupg default-jdk default-jdk-headless

RUN wget https://www-eu.apache.org/dist/spark/spark-2.4.1/spark-2.4.1-bin-hadoop2.7.tgz && \
    tar -xzvf spark-2.4.1-bin-hadoop2.7.tgz && \
    mv spark-2.4.1-bin-hadoop2.7 /usr/local/spark && \
    rm spark-2.4.1-bin-hadoop2.7.tgz

RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.4/hadoop-2.7.4.tar.gz  && \
    tar -xzvf hadoop-2.7.4.tar.gz && \
    mv hadoop-2.7.4 /usr/local/hadoop && \
    rm hadoop-2.7.4.tar.gz

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/
ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:/usr/local/spark/bin:$JAVA_HOME/bin

# RUN mkdir $SPARK_HOME/yarn-remote-client
# ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/


RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/bootstrap.sh ~/bootstrap.sh

RUN chmod +x ~/run-wordcount.sh && \
    chmod +x ~/bootstrap.sh && \
    chmod +x $HADOOP_HOME/etc/hadoop/* && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

