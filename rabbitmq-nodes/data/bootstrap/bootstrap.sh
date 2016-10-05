#!/usr/bin/env bash

source /bootstrap/functions.sh
get_environment

KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
var1=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/pods/ | jq -c '.items[] | select(.status.containerStatuses[].name | contains("rmq"))' | jq '. | { name: .metadata.name, IP: .status.podIP}' | jq -r '[.IP, .name] | join(" ")')

for i in $var1; do
	echo $i >> /etc/hosts 
done

echo $RABBIT_COOKIE > /var/lib/rabbitmq/.erlang.cookie 
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie 
chmod 400 /var/lib/rabbitmq/.erlang.cookie 

rabbitmq-server -detached 
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@$name_pod
rabbitmqctl start_app

rabbitmqctl stop
sleep 4
rabbitmq-server 






