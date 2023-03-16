cd /vagrant/ansible
ansible-playbook -i hosts.yml cluster.yml

cd /vagrant/jobs
./deploy.sh