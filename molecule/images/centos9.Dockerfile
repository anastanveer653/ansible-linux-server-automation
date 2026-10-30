# CentOS Stream 9 with systemd as PID 1, for Molecule (no maintained public image exists).
#   docker build -t localhost/molecule-centos9:latest -f molecule/images/centos9.Dockerfile molecule/images
FROM quay.io/centos/centos:stream9

RUN dnf -y install systemd python3 sudo which iproute \
    && dnf clean all \
    && (cd /lib/systemd/system/sysinit.target.wants/ \
        && for unit in *; do [ "$unit" = systemd-tmpfiles-setup.service ] || rm -f "$unit"; done) \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
             /etc/systemd/system/*.wants/* \
             /lib/systemd/system/local-fs.target.wants/* \
             /lib/systemd/system/sockets.target.wants/*udev* \
             /lib/systemd/system/sockets.target.wants/*initctl* \
             /lib/systemd/system/basic.target.wants/*

# Every real host runs D-Bus; timedatectl and node_exporter's systemd collector need it.
RUN systemctl enable dbus-broker.service dbus.socket

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
