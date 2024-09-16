# Sử dụng image cơ bản từ Ubuntu 20.04
FROM ubuntu:20.04

# Cài đặt các package cần thiết bao gồm Tor và Privoxy
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    torsocks \
    wget \
    tor \
    privoxy \
    && apt-get clean

# Thiết lập thư mục làm việc
WORKDIR /usr/src/app

# Copy toàn bộ mã nguồn từ thư mục hiện tại vào container
COPY . .

# Cài đặt các thư viện Python cần thiết
RUN pip3 install stem

# Cấu hình Privoxy để hoạt động với Tor
RUN grep -qxF 'forward-socks5t / 127.0.0.1:9050 .' /etc/privoxy/config || echo 'forward-socks5t / 127.0.0.1:9050 .' >> /etc/privoxy/config

# Cấu hình Tor để chạy với ControlPort và SocksTimeout
RUN grep -qxF 'ControlPort 9051' /etc/tor/torrc || echo 'ControlPort 9051' >> /etc/tor/torrc \
    && grep -qxF 'SocksTimeout 60' /etc/tor/torrc || echo 'SocksTimeout 60' >> /etc/tor/torrc

# Expose các cổng cần thiết (Tor và Privoxy)
EXPOSE 9050 9051

# Khởi động Tor và Privoxy trước khi chạy script Python
CMD service tor start && service privoxy start && python3 script.py
