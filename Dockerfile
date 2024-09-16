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

# Log trạng thái sau khi cài đặt
RUN echo "Packages installed successfully." && ls -la /etc/privoxy && ls -la /etc/tor

# Thiết lập thư mục làm việc
WORKDIR /usr/src/app

# Copy toàn bộ mã nguồn từ thư mục hiện tại vào container
COPY . .

# Log sau khi copy các file mã nguồn
RUN echo "Source files copied to /usr/src/app:" && ls -la /usr/src/app

# Copy file cấu hình Privoxy vào container
COPY privoxy.config /etc/privoxy/config

# Log sau khi copy file cấu hình Privoxy
RUN echo "Privoxy config copied to /etc/privoxy/config:" && cat /etc/privoxy/config

# Copy file cấu hình Tor vào container
COPY torrc /etc/tor/torrc

# Log sau khi copy file cấu hình Tor
RUN echo "Tor config copied to /etc/tor/torrc:" && cat /etc/tor/torrc

# Cài đặt các thư viện Python cần thiết
RUN pip3 install stem

# Log sau khi cài đặt các thư viện Python
RUN echo "Python packages installed successfully."

# Expose các cổng cần thiết cho Tor và Privoxy
EXPOSE 8118 9050 9051

# Khởi động Tor và Privoxy trước khi chạy script Python, và log quá trình chạy
CMD service tor start && service privoxy start && echo "Services started successfully." && python3 script.py
