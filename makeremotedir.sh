#!/bin/env sh

# Variables #
mount_point="/mnt"
ip_address=""
domain=""
username=""
share_path=""

# Check if the user is root #
if [ "$(id -u)" -ne 0 ]; then
	printf "You need to be root to execute this\n"
   exit 0 
fi

# Parse Flags #
while [ $# -gt 0 ]; do
    case "$1" in
        -i) ip_address="$2"; shift 2 ;;  # -i <ip>
        -d) domain="$2"; shift 2 ;;      # -d <domain>
        -u) username="$2"; shift 2 ;;    # -u <username>
        -s) share_path="$2"; shift 2 ;;  # -s <share_path>
        -m) mount_point="$2"; shift 2 ;; # -m <mount_point> (optional)
        *) printf "Usage: $0 -i <ip> -d <domain> -u <user> -s <share_path> [-m <mount_point>]\n"; exit 1 ;;
    esac
done

# Check parameters # 
if [ -z "$ip_address" ] || [ -z "$domain" ] || [ -z "$username" ] || [ -z "$share_path" ]; then
    printf "Missing mandatory parameters.\n"
    printf "Usage: $0 -i <ip> -d <domain> -u <user> -s <share_path> [-m <mount_point>]\n"
    exit 1
fi

# Check if the cifs-utils package is installed #
if dpkg -s cifs-utils >/dev/null 2>&1; then

    # Check if directory is empty #
    if [ -n "$(ls -A /mnt)" ]; then
        mount_point="/mnt/PastaRemota"
        [ -d "$mount_point" ] || mkdir -p "$mount_point"
    fi

    # Mount the remote directory #
    mount -t cifs -o username="$username",domain="$domain" //"${ip_address}/${share_path}" "$mount_point" && \
    clear && \
    echo "Mount successful at $mount_point"

    exit 0
fi

apt-get update && apt-get install samba cifs-utils -y 
exit 0
