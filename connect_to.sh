#!/bin/bash

# PORTS
PORT_VB=4241 # VirtualBox
PORT_WP=80 # WordPress
PORT_N8N=5678 # n8n

show_help() {
    echo "=================================================================="
    echo "Connect to the VM or access a service."
    echo "Usage: ./connect_to.sh [born2beroot|n8n|wordpress]"
    echo "PS: Make sure the VM is running before connecting."
    echo "=================================================================="
}

set_server_ip() {
    if ! source ./config.local; then
        echo "Error: couldn't find config file"
        exit 1
    fi

    if [ -z "$SERVER_IP" ]; then
        echo "Error: SERVER_IP is missing"
        exit 1
    fi

    if ! ping -c 1 "$SERVER_IP" > /dev/null 2>&1; then
        echo "Error: couldn't reach server at $SERVER_IP"
        exit 1
    fi
}

choose_service() {
    if [[ $1 == 'born2beroot' ]]; then
        echo "Connect to Born2beroot Virtual Machine"
        ssh iualkhim@$SERVER_IP -p $PORT_VB
    elif [[ $1 == 'n8n' ]]; then
        open "http://$SERVER_IP:$PORT_N8N/home/workflows"
    elif [[ $1 == 'wordpress' ]]; then
        open "http://$SERVER_IP:$PORT_WP/wordpress"
    else
        echo "Available Services: [born2beroot|n8n|wordpress]"
    fi
}

if [ -z $1 ] ||  [[ "$1" =~ ^(-?help|--help)$ ]]; then
    show_help
else
    set_server_ip
    choose_service $1
fi




