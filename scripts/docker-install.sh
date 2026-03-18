sudo yum install docker -y
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker
sudo systemctl status docker