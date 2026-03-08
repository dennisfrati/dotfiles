#!/usr/bin/env bash
# status.sh by Dennis Frati

set -euo pipefail

#session tmux
SESSION="$(tmux display-message -p -F '#S')"

#date
DATE=$(date +"%d/%m/%Y %H:%M:%S")

#interface
INTERFACE=$(ip route show default 2>/dev/null | grep -oP 'dev \K\S+' | head -n1 || echo "N/A")
if [[ "${INTERFACE}" != "N/A" ]]; then
    ADDR=$(ip addr show "${INTERFACE}" 2>/dev/null | awk '/inet / {print $2; exit}' || echo "N/A")
else
    ADDR="N/A"
fi

#disk space (insert another dir if you want to display info
DISK=$(df -h / | awk '{ if (FNR == 2) print $6" "$3"/"$4}')
DISK_HOME=$(df -h /home | awk '{ if (FNR == 2) print $6" "$3"/"$4}')

#ram
RAM=$(free -h | awk '/Mem/ {print $3"/"$2}')

#cpu (load average 1min, no blocking sleep)
CPU=$(awk '{print $1}' /proc/loadavg)

#package (if you don't find your distro make your personal package number function)
if command -v pacman &> /dev/null; then
    # Arch/Manjaro
    PACKAGE_NUM=$(pacman -Q | wc -l)
elif command -v dpkg &> /dev/null; then
    # Debian/Ubuntu
    PACKAGE_NUM=$(dpkg -l | grep -c '^ii')
elif command -v rpm &> /dev/null; then
    # RedHat/Fedora/CentOS
    PACKAGE_NUM=$(rpm -qa | wc -l)
elif command -v apk &> /dev/null; then
    # Alpine
    PACKAGE_NUM=$(apk list --installed 2>/dev/null | wc -l)
elif command -v xbps-query &> /dev/null; then
    # Void Linux
    PACKAGE_NUM=$(xbps-query -l | wc -l)
else
    # Fallback
    PACKAGE_NUM="N/A"
fi

#systemd
SYSTEMD=$(systemctl status 2>/dev/null | grep -w State: -m 1 | awk '{print $2}' || echo "N/A")

#system info
SYSTEM_INFO="$(hostnamectl --json=short | jq -r '.OperatingSystemPrettyName // "N/A"')"

#ip client
CLIENT_IP="$(echo ${SSH_CONNECTION:-} | awk '{print $1}')"

# status line
if [[ "${SESSION}" == "local_session" ]]; then
	echo "${SYSTEM_INFO} | systemd: ${SYSTEMD} | package: ${PACKAGE_NUM} | load: ${CPU} | ram: ${RAM} | ${DISK} ${DISK_HOME} | ${INTERFACE} ${ADDR} | ${DATE}"
else
	echo "${CLIENT_IP}"
fi
