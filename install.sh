#!/bin/bash

echo "Deploy PDxF Backend Server"

Front_REPOSITORY="https://github.com/BoB11-BolockChain/frontend.git"
Back_REPOSITORY="https://github.com/BoB11-BolockChain/backend.git"

git clone $Front_REPOSITORY
git clone $Back_REPOSITORY


echo "apt update"
apt update

echo "Install Golang..."
if which go > /dev/null; then
  echo "Golang already installed."
else
  rm -rf /usr/local/go
  latest=$(curl https://go.dev/VERSION?m=text)
  wget "https://dl.google.com/go/$latest.linux-amd64.tar.gz"
  tar -C /usr/local -xzf $latest.linux-amd64.tar.gz
  printf "\nPATH=\$PATH:/usr/local/go/bin" >> home.profile / etc.profile
fi

echo "Install golang dependencies..."
go get ./...

echo "Install sqlite3 database..."
if which sqlite3 > /dev/null; then
  echo "sqlite3 already installed."
else
  apt install sqlite3
fi

echo "Import database schema..." 
sqlite3 schema

echo "Install virtual environment..."
echo "Install Docker..."
if which docker > /dev/null; then
  echo "Docker already installed."
else
  apt install docker
fi

echo "Install libvirt..."
if which virsh > /dev/null; then
  echo "virsh already installed."
else
  # apt install qemu-kvm libvirt-daemon-system
  apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
  systemctl enable --now libvirtd
fi

echo "Install GoTTY..."
if which gotty > /dev/null; then
  echo "GoTTY already installed."
else
  wget -qO gotty.tar.gz https://github.com/yudai/gotty/releases/latest/download/gotty_linux_amd64.tar.gz
  tar xf gotty.tar.gz -C /usr/local/bin
  gotty --version
  rm -rf gotty.tar.gz
fi

echo "Install novnc..."
tigervnc-standalone-server tigervnc-xorg-extension \
novnc websockify 
cp ./xstartup ~/.vnc/xstartup   # 그놈 데스크탑 정보 pdxf폴더에서 옮기는 작업 진행 넣어야 함
chmod +x ~/.vnc/xstartup

cd /usr/share/novnc; sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout self.pem -out self.pem -days 365
echo "KR"
echo "--"
echo "Seoul"
echo "pdxf"
echo "pdxf"
echo "pdxf"
echo "pdxf"

cd /usr/share/novnc; ./utils/launch.sh --vnc localhost:5901 --ssl-onl

echo "python3 install..."
if which python3 > /dev/null; then
  echo "python3 already installed."
else
  apt install python3.8.10
fi

echo "pip install..."
if which pip > /dev/null; then
  echo "pip3 already installed."
else
  apt install pip
fi

# Caldera install
echo "Caldera install..."
git clone https://github.com/mitre/caldera.git --recursive
cd caldera/plugins
rm -rf sandcat
git clone https://github.com/mitre/sandcat.git
cd ..
python3 server.py --insecure

echo "Done"
