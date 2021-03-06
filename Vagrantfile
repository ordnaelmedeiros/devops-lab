Vagrant.configure("2") do |config|

    config.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 1
    end

    config.vm.box = "devops-lab-rockylinux"
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.provision "file", source: "keys/key.pub", destination: "/home/vagrant/.ssh/ansible.pub"
    config.vm.provision "shell", path: "keys/import.sh"

    (1..1).each do |i|
        config.vm.define "consul-#{i}" do |m|
            m.vm.hostname = "consul-#{i}"
            m.vm.network "public_network", ip: "192.168.100.15#{i}"
            m.vm.provision "shell", path: "keys/import.sh"
            if i==1 then
                m.vm.network "forwarded_port", guest: 8500, host: 8500
            end
        end
    end
    (1..1).each do |i|
        config.vm.define "nomad-#{i}" do |m|
            m.vm.hostname = "nomad-#{i}"
            m.vm.network "public_network", ip: "192.168.100.16#{i}"
            if i==1 then
                m.vm.network "forwarded_port", guest: 4646, host: 4646
            end
        end
    end
    (1..4).each do |i|
        config.vm.define "worker-#{i}" do |m|
            m.vm.provider "virtualbox" do |vb|
                vb.memory = 1024
                vb.cpus = 1
            end
            m.vm.hostname = "worker-#{i}"
            m.vm.network "public_network", ip: "192.168.100.17#{i}"
        end
    end
    config.vm.define "proxy" do |m|
        m.vm.hostname = "proxy"
        m.vm.network "public_network", ip: "192.168.100.181"
        m.vm.network "forwarded_port", guest: 80, host: 80
        m.vm.network "forwarded_port", guest: 8081, host: 8081
    end
    (1..2).each do |i|
        config.vm.define "db-#{i}" do |m|
            m.vm.provider "virtualbox" do |vb|
                vb.memory = 512
                vb.cpus = 1
            end
            m.vm.hostname = "db-#{i}"
            m.vm.network "public_network", ip: "192.168.100.19#{i}"
        end
    end
    (1..1).each do |i|
        config.vm.define "metrics-#{i}" do |m|
            m.vm.provider "virtualbox" do |vb|
                vb.memory = 1024
                vb.cpus = 1
            end
            m.vm.hostname = "metrics-#{i}"
            m.vm.network "public_network", ip: "192.168.100.20#{i}"
        end
    end

    config.vm.define "ansible" do |m|
        m.vm.box = "ubuntu/focal64"
        m.vm.box_version = "20211026.0.0"
        m.vm.synced_folder '.', '/vagrant', disabled: false
        m.vm.hostname = "ansible"
        m.vm.provision "shell", inline: <<-EOF
            sudo apt update
            sudo apt install -y ansible sshpass
            
            cat /vagrant/keys/key | tr -d '\r' > /home/vagrant/.ssh/id_rsa
            cat /vagrant/keys/key.pub | tr -d '\r' > /home/vagrant/.ssh/id_rsa.pub
            
            cat /vagrant/keys/key | tr -d '\r' > ~/.ssh/id_rsa
            cat /vagrant/keys/key.pub | tr -d '\r' > ~/.ssh/id_rsa.pub

            #sudo chmod 600 ~/.ssh/id_rsa
            #sudo chmod 600 ~/.ssh/id_rsa.pub

            sed -i 's/#host_key_checking = False/host_key_checking = False/g' /etc/ansible/ansible.cfg
            sed -i 's/#host_key_auto_add = True/host_key_auto_add = True/g' /etc/ansible/ansible.cfg
            su vagrant
            cd /vagrant
            ansible-playbook -i hosts cluster.yml
        EOF
    end
end