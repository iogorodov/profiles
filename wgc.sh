#!/bin/bash

ADDRESS=10.1.1.1/24
PORT=51234

function print_usage {
    echo "CLI for WireGurad server"
    echo "Usage: wgc.sh <command> <options>"
    echo "Commands:"
    echo "  setup [<address>] - setup WireGurad server"
}

function setup {
    local address=$1
    local port=$2

    apt update
    apt install -y wireguard
    local private_key=$(wg genkey)

    echo "[Interface]" > /etc/wireguard/wg0.conf
    echo "PrivateKey = $(echo $private_key)" >> /etc/wireguard/wg0.conf
    echo "Address = $address" >> /etc/wireguard/wg0.conf
    echo "ListenPort = $port" >> /etc/wireguard/wg0.conf
    echo "SaveConfig = true" >> /etc/wireguard/wg0.conf

    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    local interface=$(ip route list default | grep -o "dev [^ ]\+" | cut -c 5-)

    echo >> /etc/wireguard/wg0.conf
    echo "PostUp = ufw route allow in on wg0 out on $interface to any port 1:1024 proto tcp" >> /etc/wireguard/wg0.conf
    echo "PostUp = ufw route allow in on wg0 out on $interface to any port 1:1024 proto udp" >> /etc/wireguard/wg0.conf
    echo "PostUp = ufw route allow in on wg0 out on $interface to any port 9339 proto tcp" >> /etc/wireguard/wg0.conf
    echo "PostUp = iptables -t nat -I POSTROUTING -o $interface -j MASQUERADE" >> /etc/wireguard/wg0.conf
    echo "PreDown = ufw route delete allow in on wg0 out on $interface to any port 1:1024 proto tcp" >> /etc/wireguard/wg0.conf
    echo "PreDown = ufw route delete allow in on wg0 out on $interface to any port 1:1024 proto udp" >> /etc/wireguard/wg0.conf
    echo "PreDown = ufw route delete allow in on wg0 out on $interface to any port 9339 proto udp" >> /etc/wireguard/wg0.conf
    echo "PreDown = iptables -t nat -D POSTROUTING -o $interface -j MASQUERADE" >> /etc/wireguard/wg0.conf

    ufw allow $port/udp
    ufw allow OpenSSH

    ufw disable
    ufw --force enable

    systemctl enable wg-quick@wg0.service
    systemctl start wg-quick@wg0.service
    systemctl status wg-quick@wg0.service
}

function find_peer_ip {
    local ip_server=`cat /etc/wireguard/wg0.conf | grep "Address = " | cut -c 11- | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+"`
    local allowed_ips=`wg show wg0 allowed-ips`

    for i in {2..255}; do
        local ip=$ip_server.$i
        echo $allowed_ips | grep "$ip/" > /dev/null
        if [[ $? -ne 0 ]]; then
            echo $ip
            return 0
        fi
    done

    return 1
}

function add {
    local peer_ip=$(find_peer_ip)
    if [[ $? -ne 0 ]]; then
        echo "Cannot find free ip address for new peer"
        return 1
    fi

    local server_public_key=$(wg showconf wg0 | grep "PrivateKey = " | cut -c 14- | wg pubkey)
    local server_port=$(wg showconf wg0 | grep "ListenPort = " | cut -c 14-)
    local peer_private_key=$(wg genkey)
    local peer_public_key=$(echo $peer_private_key | wg pubkey)

    local interface=$(ip route list default | grep -o "dev [^ ]\+" | cut -c 5-)
    local gateway=$(ip route list table main default | grep -o "via [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]" | cut -c 5-)
    local public_ip=$(ip -brief address show $interface | sed "s/.*UP[ ]\+\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/")
    local dns_server=$(nmcli device show $interface | grep IP4.DNS | head -1 | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+")

    wg set wg0 peer $peer_public_key allowed-ips $peer_ip

    echo "[Interface]"
    echo "PrivateKey = $peer_private_key"
    echo "Address = $peer_ip/32"
    echo "DNS = $dns_server"

    echo "[Peer]"
    echo "PublicKey = $server_public_key"

    echo "AllowedIPs = $dns_server/32, 1.0.0.0/8, 2.0.0.0/8, 3.0.0.0/8, 4.0.0.0/6, 8.0.0.0/7, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/2, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/6, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4"
    echo "Endpoint = $public_ip:$server_port"
}

if [ "$1" == "setup" ]; then
    setup $ADDRESS $PORT
elif [ "$1" == "add" ]; then
    add
else
    print_usage
fi