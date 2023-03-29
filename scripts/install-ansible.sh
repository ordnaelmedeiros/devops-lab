curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-add-repository ppa:ansible/ansible -y

sudo apt update
sudo apt install sshpass ansible consul=*1.14.5-1* nomad=*1.5.2-1* -y

sudo cp /home/vagrant/ansible.cfg /etc/ansible/ansible.cfg

# export CONSUL_HTTP_ADDR="http://192.168.56.101:8500"
# export NOMAD_ADDR="http://192.168.56.111:4646"