FROM registry.fedoraproject.org/fedora:rawhide

RUN dnf install -y \
    git \
    openssh-clients \
    openssh-server \
    fedora-packager \
    fedpkg \
    gcc \
    mock \
    rpm-build \
    rpmdevtools \
    sudo \
    vim \
    && dnf clean all

RUN useradd -m -G wheel,mock -s /bin/bash user
    
# Allow mock to run inside a container:
# - disable namespace isolation (use plain chroot)
# - bind-mount host /dev into chroot so /dev/null etc. are accessible
RUN printf "config_opts['isolation'] = 'simple'\n\
config_opts['plugin_conf']['bind_mount_enable'] = True\n\
config_opts['plugin_conf']['bind_mount_opts']['dirs'].append(('/dev', '/dev'))\n\
config_opts['plugin_conf']['bind_mount_opts']['dirs'].append(('/dev/shm', '/dev/shm'))\n" \
    >> /etc/mock/site-defaults.cfg

# Create entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /home/user

ENTRYPOINT ["/entrypoint.sh"]