sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update
sudo apt install sshpass ansible -y

sudo cp /home/vagrant/ansible.cfg /etc/ansible/ansible.cfg