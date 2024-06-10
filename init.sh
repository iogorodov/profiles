#!/bin/bash

IP=$1

ROOT=root
KEY=~/.ssh/id_rsa

USER=user

SSH_PARAMS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" 
APT_GET_ENV="DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a"
APT_GET_PARAMS="-o Dpkg::Options::=--force-confnew -qy --allow-downgrades --allow-remove-essential --allow-change-held-packages"

INIT_SH="#!/bin/bash
locale-gen \"en_US.UTF-8\"

echo \"INFO: Update packages...\"
$APT_GET_ENV apt-get update
$APT_GET_ENV apt-get $APT_GET_PARAMS upgrade
$APT_GET_ENV apt-get $APT_GET_PARAMS dist-upgrade
$APT_GET_ENV apt-get $APT_GET_PARAMS install unattended-upgrades
$APT_GET_ENV apt-get $APT_GET_PARAMS install nano curl wget micro apt-transport-https software-properties-common

if ! id \"$USER\" > /dev/null 2>&1; then
    echo \"INFO: Create user $USER and make it sudoer...\"
    adduser --disabled-password --gecos \"\" $USER
    adduser $USER sudo
    echo \"user ALL=(ALL) NOPASSWD:ALL\" >>/etc/sudoers
    su $USER -c \"mkdir ~/.ssh && chmod 700 ~/.ssh\"
    cp ~/.ssh/authorized_keys /home/$USER/.ssh
    chown $USER:$USER /home/$USER/.ssh/authorized_keys
    su $USER -c \"chmod 600 ~/.ssh/authorized_keys\"
fi

if [ ! -f /etc/ssh/sshd_config.d/99-init.conf ]; then
    echo \"INFO: Update sshd settings...\"
    echo \"Port 212\" > /etc/ssh/sshd_config.d/99-init.conf
    echo \"PasswordAuthentication no\" >> /etc/ssh/sshd_config.d/99-init.conf
    echo \"AllowUsers $USER\" >> /etc/ssh/sshd_config.d/99-init.conf
fi

echo \"INFO: Update miscellaneous settings...\"
timedatectl set-timezone UTC

ufw --force enable
ufw allow 212/tcp
"

echo -e "$INIT_SH" | ssh $SSH_PARAMS -i $KEY -l $ROOT $IP -T "cat > ~/init.sh && chmod +x ~/init.sh && ~/init.sh && rm ~/init.sh && reboot now"
