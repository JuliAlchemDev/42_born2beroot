#!/bin/bash

# Architecture
arch=$(uname -a)

# CPU's
cpu_phys=$(lscpu | grep Socket | awk '{print $2}')
cpu_virt=$(lscpu | grep ^CPU\(s\) | awk '{print $2}')
cpu_usage=$(vmstat 1 2 | tail -1 | awk '{printf "%.1f", 100 - $15}')

# Memory(RAM)
total_ram=$(free --mega | grep Mem | awk '{print $2}')
used_ram=$(free --mega | grep Mem | awk '{print $3}')

pct_ram_usage=$(awk "BEGIN {print $used_ram / $total_ram * 100}")
show_pct=$(printf "%.2f" "$pct_ram_usage")

# Memory(Disk Usage)

total_storage=$(df --total --output=size -h| tail -n 1 | awk '{print $1}')
used_storage=$(df --total --output=used --block-size=M | tail -n 1 | awk -FM '{print $1}')
storage_usage=$(df --total --output=pcent -h | tail -n 1 | awk '{print $1}')

# Boot Info
last_boot=$(who -b | awk '{print $3, $4, $5}')

# Logical Volume Manager
count_lvm=$(lsblk | grep lvm | wc -l)
has_lvm() {
    if [ $1 -gt 0 ]; then
        echo "yes"
        else
        echo  "no"
    fi
}

# TCP Connections and Log Info
tcp_count=$(ss -ta | grep ESTAB | wc -l)
logins_count=$(w -h | wc -l)

# IP and MAC
default_route=$(ip route | grep default)
ip_addr=$(echo "$default_route" | awk '{print $9}')
interface=$(echo "$default_route" | awk '{print $5}')
mac=$(ip link show "$interface"| awk '/ether/ {print $2}')

# Sudo Logs info
sudo_count=$(journalctl -q _COMM=sudo | grep COMMAND | wc -l)

echo -e "\t#Architecture: $arch"
echo -e "\t#Physical CPU: $cpu_phys"
echo -e "\t#vCPU: $cpu_virt"
echo -e "\t#Memory Usage: ${used_ram}/${total_ram}MB (${show_pct}%)"
echo -e "\t#Disk Usage: $used_storage/${total_storage}b ($storage_usage)"
echo -e "\t#CPU load: $cpu_usage%"
echo -e "\t#Last boot: $(date -d "$last_boot" "+%Y-%m-%d %H:%M")"
echo -e "\t#LVM use: $(has_lvm $count_lvm)"
echo -e "\t#TCP Connections: $tcp_count ESTABLISHED"
echo -e "\t#User log: $logins_count"
echo -e "\t#Network: IP $ip_addr ($mac)"
echo -e "\t#Sudo: $sudo_count cmd"
