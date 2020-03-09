sudo cp files/xclip.socket /etc/systemd/system/xclip.socket
sudo cp files/xclip@.service /etc/systemd/system/xclip@.service

sudo systemctl enable xclip.socket
