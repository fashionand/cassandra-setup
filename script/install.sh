#!/bin/bash
Node_IP=""
SEEDS=""
CLUSTER_NAME=""
while getopts i:e:s:m option
do
    case "$option" in
        i)
            Node_IP=$OPTARG
            echo "option:i, value $OPTARG"
            ;;
        e)
            SEEDS=$OPTARG
            echo "option:e, value $OPTARG"
            ;;
        s)
            CLUSTER_NAME=$OPTARG
            echo "option:s, value $OPTARG"
            ;;
        \?)
            echo "Usage: args [-i]"
            echo "-i means docker images name"
            echo "Usage: args [-e]"
            echo "-v means app environment"
            exit 1;;
    esac
done
apt install -y python-pip 
apt install -y openjdk-8-jdk 
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list 
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add - 
apt-get update 
apt-get install -y cassandra

type=ext4
mount_dir=/data
mkfs.$type /dev/vdb 
mkdir -p $mount_dir
echo "/dev/vdb $mount_dir $type defaults 0 0" >> /etc/fstab
mount -a

mkdir /data
mkdir /data/cassandra
mkdir /data/cassandra/data
mkdir /data/cassandra/commitlog
mkdir /data/cassandra/saved_caches
mkdir /data/cassandra/hints

chmod 777 /data
chmod 777 /data/cassandra/
chmod 777 /data/cassandra/*

./generate_node_config.sh -i $Node_IP -e $SEEDS -s $CLUSTER_NAME

cp $Node_IP/config/* /etc/cassandra/

service cassandra restart

cp tp/jmx_prometheus_javaagent-0.3.0.jar /usr/lib/
mkdir /etc/cassandra/prometheus/
cp tp/cassandra.yml /etc/cassandra/prometheus/

mv tp/node_exporter-0.18.1.linux-amd64 /usr/local/bin/node_exporter
cp tp/node_exporter.service /etc/systemd/system/
useradd prometheus
chown prometheus:prometheus /etc/systemd/system/node_exporter.service
chown prometheus:prometheus /usr/local/bin/node_exporter
systemctl daemon-reload
systemctl start node_exporter
systemctl status node_exporter
systemctl enable node_exporter