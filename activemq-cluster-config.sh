#!/bin/bash 
BROKER_NAME = $(env|grep "BROKER_NAME")
TCP_CLUSTER_NODES=$(env|grep ":61616"|grep -v `hostname -i`|cut -d \= -f 2)
NC_DUPLEX=$(env|grep "DUPLEX")
declare -i NC_TTL 
NC_TTL=$(env|grep "TTL"|cut -d \= -f 2)

if [ -z $NC_DUPLEX ]
then 
	NC_DUPLEX=false
else
	NC_DUPLEX=true
fi

if [ $NC_TTL -lt 1 ]
then
	NC_TTL=1
fi

sed -i "s/brokerName=\"localhost\"/brokerName=\"$HOSTNAME\"/g" activemq.xml

if [ -z $TCP_CLUSTER_NODES ]
then
	cp activemq.xml activemq-run.xml
else
	echo $TCP_CLUSTER_NODES
	echo "<networkConnectors>" > /tmp/file1
	for OUTPUT in $TCP_CLUSTER_NODES
  	do
    		echo "<networkConnector name=\""$OUTPUT"\" uri=\"static:("$OUTPUT")\" duplex=\""$NC_DUPLEX"\"  networkTTL=\""$NC_TTL"\" decreaseNetworkConsumerPriority=\"true\" >"  >> /tmp/file1
 			
			echo "</networkConnector>">> /tmp/file1
 	done
	echo "</networkConnectors>" >> /tmp/file1

	sed '/<\/destinationPolicy/r /tmp/file1' activemq.xml > activemq-run.xml
fi

env
cat activemq-run.xml
/apache-activemq-5.11.1/bin/activemq console -Dactivemq.brokername=$HOSTNAME xbean:file:./activemq-run.xml
