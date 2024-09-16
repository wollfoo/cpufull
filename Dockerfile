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

# Sao chép file cấu hình Privoxy tùy chỉnh
COPY privoxy_config.conf /etc/privoxy/config

# Sao chép file cấu hình Tor tùy chỉnh
COPY torrc /etc/tor/torrc

# Cài đặt các thư viện Python cần thiết
RUN pip3 install stem

# Expose các cổng cần thiết cho Tor và Privoxy
EXPOSE 8118 9050 9051

# Khởi động Tor và Privoxy trước khi chạy script Python
CMD service tor start && service privoxy start && python3 script.py
