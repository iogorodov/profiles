#!/bin/bash

# Небольшой локальный cloud-init для Rocky Linux
# - Устанавливает nano, micro, curl, wget, firewalld
# - Добавляет пользователя brownie (см. USER) с правом запускать sudo без пароля
# - Разрешает ssh доступ только для этого пользователя и только по ключу
# - Копирует 

IP=$1
ROOT=$2
KEY=$3

USER=brownie

SSH_PARAMS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" 
AUTH_KEYS=`cat ~/.ssh/id_rsa.pub`

INIT_SH="#!/bin/bash

AUTH_KEYS=\"$AUTH_KEYS\"

echo \"INFO: Update packages...\"
sudo dnf upgrade -y
sudo dnf install tar curl nano wget -y
curl https://getmic.ro | bash
sudo mv micro /usr/bin/

if ! id \"$USER\" > /dev/null 2>&1; then
    echo \"INFO: Create user $USER and make it sudoer...\"

    sudo adduser $USER
    sudo usermod -aG wheel $USER
    sudo echo \"$USER ALL=(ALL) NOPASSWD:ALL\" >>/etc/sudoers

    sudo su $USER -c \"mkdir ~/.ssh && chmod 700 ~/.ssh\"
    echo \"$AUTH_KEYS\" > /home/$USER/.ssh/authorized_keys
    sudo chown $USER:$USER /home/$USER/.ssh/authorized_keys
    sudo su $USER -c \"chmod 600 ~/.ssh/authorized_keys\"
fi

if [ ! -f /etc/ssh/sshd_config.d/99-init.conf ]; then
    echo \"INFO: Update sshd settings...\"
    echo \"Port 212\" > /etc/ssh/sshd_config.d/99-init.conf
    echo \"PasswordAuthentication no\" >> /etc/ssh/sshd_config.d/99-init.conf
    echo \"AllowUsers $USER\" >> /etc/ssh/sshd_config.d/99-init.conf
fi

echo \"INFO: Update miscellaneous settings...\"
timedatectl set-timezone UTC
"

echo -e "$INIT_SH" | ssh $SSH_PARAMS -l $ROOT $IP -T "cat > ~/init.sh && chmod +x ~/init.sh && sudo ~/init.sh && rm ~/init.sh && reboot now"
