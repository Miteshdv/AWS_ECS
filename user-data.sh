#!/bin/bash

# Detect the OS and install necessary packages
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s)
fi

if [ "$OS" == "amzn" ]; then
    # Amazon Linux
    sudo yum update -y
    sudo yum install -y python3 python3-pip git
elif [ "$OS" == "ubuntu" ]; then
    # Ubuntu
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-pip git
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Create a directory for the application
mkdir -p /home/ec2-user/python_server
cd /home/ec2-user/python_server

# Clone the repository
git clone https://github.com/Miteshdv/python_server.git .
cd python_server

# Set up a virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install gunicorn

# Create a systemd service for gunicorn
sudo tee /etc/systemd/system/gunicorn.service > /dev/null <<EOT
[Unit]
Description=Gunicorn instance to serve python_server
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/python_server
Environment="PATH=/home/ec2-user/python_server/venv/bin"
ExecStart=/home/ec2-user/python_server/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 wsgi:app

[Install]
WantedBy=multi-user.target
EOT

# Start and enable the gunicorn service
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn