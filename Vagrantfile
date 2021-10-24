Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 1
    end
    (1..1).each do |i|
        config.vm.define "consul-#{i}" do |m|
            m.vm.box = "centos/7"
            m.vm.hostname = "consul-#{i}"
            m.vm.network "public_network", ip: "192.168.100.15#{i}"
            m.vm.provision "shell", path: "scripts/enable_ssh.sh"
        end
    end
    (1..1).each do |i|
        config.vm.define "nomad-#{i}" do |m|
            m.vm.box = "centos/7"
            m.vm.hostname = "nomad-#{i}"
            m.vm.network "public_network", ip: "192.168.100.16#{i}"
            m.vm.provision "shell", path: "scripts/enable_ssh.sh"
        end
    end
    (1..2).each do |i|
        config.vm.define "worker-#{i}" do |m|
            m.vm.provider "virtualbox" do |vb|
                vb.memory = 1024
                vb.cpus = 1
            end
            m.vm.box = "centos/7"
            m.vm.hostname = "worker-#{i}"
            m.vm.network "public_network", ip: "192.168.100.17#{i}"
            m.vm.provision "shell", path: "scripts/enable_ssh.sh"
        end
    end
    config.vm.define "ansible" do |m|
        m.vm.box = "ubuntu/focal64"
        m.vm.hostname = "ansible"
        m.vm.provision "shell", inline: <<-EOF
            sudo apt update
            sudo apt install -y ansible sshpass
            sed -i 's/#host_key_checking = False/host_key_checking = False/g' /etc/ansible/ansible.cfg
            cd /vagrant
            ansible-playbook -i hosts cluster.yml
        EOF
    end
end