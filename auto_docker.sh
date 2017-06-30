#!/bin/bash


# Check HAproxy Service
pgrep -f "/var/run/haproxy.pid" &>/dev/null
if [ "$?" -eq 1 ]; then
    service haproxy start
fi

# List docker Containers Running
current_app_running=$(docker ps | grep example_APP_name |wc -l)

# Check HAproxy Sessions
connections=$(test -f /var/run/haproxy.sta && echo "show info" | socat unix-connect:/var/run/haproxy.sta stdio | grep CurrConns | sed -e 's/[^0-9]*//g')

if [ -z "$connections" ]; then
connections=20
fi

if [ $current_app_running -lt $connections ] || [  $current_app_running -lt 10 ]
then

 sh scale_docker.sh > /etc/haproxy/haproxy.cfg && haproxy -f /etc/haproxy/haproxy.cfg -c > /dev/null 1>&1 && service haproxy reload  > /dev/null 1>&1

fi
