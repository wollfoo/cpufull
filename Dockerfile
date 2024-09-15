# Sử dụng image cơ bản từ Ubuntu 20.04
FROM ubuntu:20.04

# Cài đặt các package cần thiết
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    torsocks \
    tor \
    privoxy \
    wget \
    && apt-get clean

# Thiết lập thư mục làm việc
WORKDIR /usr/src/app

# Copy toàn bộ mã nguồn từ thư mục hiện tại vào container
COPY . .

# Cài đặt các thư viện Python cần thiết
RUN pip3 install stem

# Expose các cổng cần thiết (Tor và Privoxy)
EXPOSE 9050 9051

# Lệnh để chạy ứng dụng khi container khởi động
CMD ["python3", "script.py"]
