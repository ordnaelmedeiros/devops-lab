cat /vagrant/keys/key | tr -d '\r' > ~/.ssh/id_rsa
cat /vagrant/keys/key.pub | tr -d '\r' > ~/.ssh/id_rsa.pub

sudo chmod 600 ~/.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa.pub

sudo sed -i 's/#host_key_checking = False/host_key_checking = False/g' /etc/ansible/ansible.cfg
sudo sed -i 's/#host_key_auto_add = True/host_key_auto_add = True/g' /etc/ansible/ansible.cfg

cd /vagrant/ansible
ansible-playbook -i hosts.yml cluster.yml

# cd /vagrant/jobs
# ./deploy.sh