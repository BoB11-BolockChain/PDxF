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
  echo ".q" | apt install sqlite3
fi

echo "Import database schema..." 
sqlite3 schema

echo "Install virtual environment..."
echo "Install Docker..."
if which docker > /dev/null; then
  echo "Docker already installed."
else
  echo "y" | apt install docker
fi

echo "Install NginX"
if which nginx > /dev/null; then
  echo "NginX already installed."
else
  apt install nginx
  currentPath=$(pwd)
  buildRoot="$currentPath+/build"
  sed 's/{{root}}/$buildRoot/g' pdxf.conf > /etc/nginx/sites-available/newpdxf.conf
  ln -s /etc/nginx/sites-available/myapp.conf /etc/nginx/sites-enabled/myapp.conf
fi

echo "Instlall curl"
if which curl > /dev/null; then
  echo "curl already installed."
else
  echo "y" | apt install curl
fi
  echo "Install React.JS"

if which node > /dev/null; then
  echo "node already installed."
else
  curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
  sudo apt-get install -y nodejs
  sudo apt install npm
  sudo apt-get install build-essential
  npm install -g create-react-app
  create-react-app hello-react
  cd frontend
  npm install
  npm install @ant-design/icons --save-dev
  npm run build
  cd ..
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
sudo apt install \
	tigervnc-standalone-server tigervnc-xorg-extension \
	novnc websockify 
cp ./xstartup ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

cd /usr/share/novnc; sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout self.pem -out self.pem -days 365
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
  echo "y" | apt-get install python3-pip
fi

#ssh pass 설치 해야 함

# Caldera install
echo "Caldera install..."
git clone https://github.com/mitre/caldera.git --recursive
cd caldera
pip3 install -r requirements.txt
cd plugins
rm -rf sandcat
git clone https://github.com/mitre/sandcat.git
cd ..
python3 server.py --insecure

echo "Done"
