#!/bin/bash 
USAGE="USAGE: run {build|run|clean}"
NUM_BROKER=2
DUPLEX=true
alias echo='echo "[INFO]" '

function buildImage() 
{
	echo "Building image..."
	docker build -t amq:activemq2 .
}

function startAMQBroker()
{
	echo "Starting brokers..."
	for (( i = 1; i <= $NUM_BROKER; i++ )); do
		startBroker "$i"
	done
}

function startBroker()
{	
	if (( $1 == 1 ));
	then 
		echo "Starting Broker-AMQ_$1 "
		docker run -d -P --name amq$1 -d -P amq:activemq2
	else
		echo "Starting Broker-AMQ_$1 "
		amqLink=$(( $1 - 1 ))
		docker run -d -P --name amq$1 -d -P --link amq$amqLink:amq$amqLink --env DUPLEX=$DUPLEX amq:activemq2
	fi
	echo "Tranport connector of Broker-AMQ_$1"
	docker port amq$1
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
