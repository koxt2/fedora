#!/bin/bash

# Start SSH server
start_sshd() {
    ssh-keygen -A  # generate host keys if missing
    # Fedora's sshd_config includes sshd_config.d/*.conf first and the first value wins,
    # so a drop-in sorted before the distro ones is the reliable way to override.
    mkdir -p /run/sshd /etc/ssh/sshd_config.d
    printf 'PermitRootLogin yes\nPasswordAuthentication yes\nPubkeyAuthentication yes\nAllowAgentForwarding yes\nKbdInteractiveAuthentication yes\nUsePAM yes\n' \
        > /etc/ssh/sshd_config.d/00-container.conf
    # Optional: set passwords from env (e.g. a k8s Secret) instead of the baked-in 'pass'
    if [ -n "$USER_PASSWORD" ]; then echo "user:$USER_PASSWORD" | chpasswd; fi
    if [ -n "$ROOT_PASSWORD" ]; then echo "root:$ROOT_PASSWORD" | chpasswd; fi
    exec /usr/sbin/sshd -D -e
}

# Fix ownership of /home/user when running rootful (volume may be owned by root)
fix_home_ownership() {
    mkdir -p /home/user
    if [ "$(stat -c '%u' /home/user)" != "$(id -u user)" ]; then
        chown -R user:user /home/user
    fi
}

main() {
    fix_home_ownership
    start_sshd
}

main