#!/bin/sh

# registrator uses different docker.sock location than default
DOCKER_SOCK=/tmp/docker.sock

HOST_NAME_TAG=$(curl -s --unix-socket ${DOCKER_SOCK} http:/info | jq '.Name')
HOST_NAME_TAG=${HOST_NAME_TAG//\"}
HOST_NAME_TAG="-tags $HOST_NAME_TAG"

HOST_IP=
if [ -n "$DISCOVER_HOST_IP" ]; then
    host_ip=$(curl -s --unix-socket ${DOCKER_SOCK} http:/info | jq '.Swarm.NodeAddr')
    host_ip=${host_ip//\"}

    if [ -n "$host_ip" ]; then
      HOST_IP="-ip $host_ip"
    fi
fi

CONSUL_AGENT=
if [ -n "$DISCOVER_CONSUL_AGENT" ]; then
    jq_query=".[] | .NetworkSettings.Networks.\"$DISCOVER_NETWORK\".IPAddress"

    consul_agent_ip=$(curl -G -s --unix-socket ${DOCKER_SOCK} http/containers/json --data-urlencode 'filters={"label":["consul=agent"]}' | jq "${jq_query}")
    consul_agent_ip=${consul_agent_ip//\"}

    CONSUL_AGENT="consul://$consul_agent_ip:8500"
fi

set -- ${HOST_IP} ${HOST_NAME_TAG} "$@"

exec /bin/registrator $@ ${CONSUL_AGENT}
