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
mkdir $Node_IP
cp config/* $Node_IP
sed -e 's/seeds: "127.0.0.1"/seeds: "'$SEEDS'"/g' -e 's/Test Cluster/'$CLUSTER_NAME'/g' config/cassandra.yaml >$Node_IP/cassandra.yaml
sed -e 's/jmxhost/'$Node_IP'/g' config/cassandra-env.sh >$Node_IP/cassandra-env.sh
