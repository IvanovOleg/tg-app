#! /bin/bash
sudo apt-get update
sudo apt-get install -y python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools
sudo apt install python3-venv
sudo pip3 install flask gunicorn
sudo ufw allow 5000
mkdir /home/ubuntu/src
cd /home/ubuntu/src
git clone https://github.com/IvanovOleg/tg-app.git
cd /home/ubuntu/src/tg-app/developer/app
chmod +x app.py
python3 app.py &
