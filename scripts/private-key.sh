cat /home/vagrant/.ssh/ansible.key | tr -d '\r' > /home/vagrant/.ssh/id_rsa
cat /home/vagrant/.ssh/ansible.pub | tr -d '\r' > /home/vagrant/.ssh/id_rsa.pub

sudo chown vagrant:vagrant /home/vagrant/.ssh/id_rsa
sudo chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub

sudo chmod 600 /home/vagrant/.ssh/id_rsa
sudo chmod 600 /home/vagrant/.ssh/id_rsa.pub
