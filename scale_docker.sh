#!/bin/bash

# List the Containers, ex: Container APP Name
list=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -a | grep example_APP_name  | awk  '{print $1}'))

# Check HAproxy Current Sessions
connections=$(test -f /var/run/haproxy.sta && echo "show info" | socat unix-connect:/var/run/haproxy.sta stdio | grep CurrConns | sed -e 's/[^0-9]*//g')

# Scale Docker Containers
if [ -z "$connections" ]
then
connections=5
fi

if [ $connections -lt 10 ]
then
  connections=10
 docker-compose -f docker-compose.yml scale app=$connections > /dev/null 2>&1
fi

if [ $connections -gt 100 ] 
then
  connections=100
fi

if [ $connections -gt 15 ] 
then
  docker-compose -f docker-compose.yml scale app=$connections > /dev/null 2>&1
fi

sleep 30

echo "
global
        user haproxy
        group haproxy
        daemon
        maxconn 16384
        pidfile /var/run/haproxy.pid
        stats socket /var/run/haproxy.sta

defaults
        balance roundrobin
        mode tcp
        retries 3
        option redispatch
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms


listen http_80
        bind 0.0.0.0:80
        mode http
        balance roundrobin
        option httpclose
        option forwardfor
        cookie SERVERNAME insert indirect nocache"

for ip in $list
do
      echo "server $ip $ip:3838 cookie $ip check"
done
echo "listen stats
        bind 0.0.0.0:8080
        mode http
        stats enable
        stats auth admin:password"
