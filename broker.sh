#!/bin/bash 
USAGE="USAGE: run {build|run|clean}"
DEVICE_BROKERS=2
SERVICE_BROKERS=3
NC_TTL=5
DUPLEX=true
alias echo='echo "[INFO]" '
 
function buildImage() 
{
	echo "Building image..."
	docker build -t amq:activeMQ .
}

function startAMQBroker()
{
	startServiceBroker
	startDeviceBroker
}

function startServiceBroker()
{	
	echo "Creating Service Brokers....."
	for ((i = 1; i <= $SERVICE_BROKERS; i++)); 
	do
		docker run -d -P --name service_broker_$i --env BROKER_NAME=service_broker_$i amq:activeMQ 
		transportConnector=$(docker port service_broker_$i)
		echo "Service_Broker_$i : $transportConnector"
	done
}

function startDeviceBroker()
{
	echo "Creating Device Brokers....."
	TCP_CLUSTER_NODES=""
	# TCP_CLUSTER_NODES=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -f "name=service_broker" --format "{{.Names}}")) 
	SERVICE_BROKERS_LIST=$(docker ps -f "name=service_broker" --format "{{.Names}}")
	for i in $SERVICE_BROKERS_LIST
	do
		OUTPUT="--link $i:$i "
		TCP_CLUSTER_NODES="$TCP_CLUSTER_NODES$OUTPUT"
	done

	for ((i = 1; i <= $DEVICE_BROKERS; i++ )); 
	do
		echo $TCP_CLUSTER_NODES
		docker run -d -P --name device_broker_$i $TCP_CLUSTER_NODES --env DUPLEX=$DUPLEX amq:activeMQ
		# docker run -it $TCP_CLUSTER_NODES --env DUPLEX=$DUPLEX --env BROKER_NAME=device_broker_$i amq:activeMQ /bin/bash
		transportConnector=$(docker port device_broker_$i)
		echo "Device_Broker_$i : $transportConnector"
	done
}

function remove(){
	echo "Cleaning brokers..."
	for (( i = 1; i <= $NUM_BROKER; i++ )); do
		docker rm -f "amq$i"
	done
}

function build() 
{
	buildImage
}

function run() 
{
	startAMQBroker
}

function clean() 
{
	remove
}

#Begin
if [[ ! -z $1 ]]; then
	if 	[[ $1 == "build" ]]; then
		build
	elif [[ $1 == "run" ]]; then
		run
	elif [[ $1 == "clean" ]]; then
		clean
	else 
		echo $USAGE
	fi
else
	echo $USAGE
fi

unalias echo
