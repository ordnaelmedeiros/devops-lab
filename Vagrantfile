Vagrant.configure("2") do |config|

    config.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 1
    end

    config.vm.box = "ubuntu/jammy64"
    config.vm.box_version = "20230314.0.0"
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.provision "file", source: "keys/key.pub", destination: "/home/vagrant/.ssh/ansible.pub"
    config.vm.provision "file", source: "keys/key", destination: "/home/vagrant/.ssh/ansible.key"
    config.vm.provision "shell", path: "scripts/authorized-keys.sh"

    (1..1).each do |i|
        config.vm.define "consul-#{i}" do |m|
            m.vm.hostname = "consul-#{i}"
            m.vm.network "private_network", ip: "192.168.56.10#{i}"
        end
    end
    (1..1).each do |i|
        config.vm.define "nomad-#{i}" do |m|
            m.vm.hostname = "nomad-#{i}"
            m.vm.network "private_network", ip: "192.168.56.11#{i}"
        end
    end
    (1..3).each do |i|
        config.vm.define "worker-#{i}" do |m|
            m.vm.provider "virtualbox" do |vb|
                vb.memory = 1024
                vb.cpus = 1
            end
            m.vm.hostname = "worker-#{i}"
            m.vm.network "private_network", ip: "192.168.56.12#{i}"
        end
    end
    config.vm.define "proxy" do |m|
        m.vm.hostname = "proxy"
        m.vm.network "private_network", ip: "192.168.56.181"
        m.vm.network "forwarded_port", guest: 80, host: 80
    end
    # (1..2).each do |i|
    #     config.vm.define "db-#{i}" do |m|
    #         m.vm.provider "virtualbox" do |vb|
    #             vb.memory = 512
    #             vb.cpus = 1
    #         end
    #         m.vm.hostname = "db-#{i}"
    #         m.vm.network "public_network", ip: "192.168.100.19#{i}"
    #     end
    # end
    # (1..1).each do |i|
    #     config.vm.define "metrics-#{i}" do |m|
    #         m.vm.provider "virtualbox" do |vb|
    #             vb.memory = 1024
    #             vb.cpus = 1
    #         end
    #         m.vm.hostname = "metrics-#{i}"
    #         m.vm.network "public_network", ip: "192.168.100.20#{i}"
    #     end
    # end

    config.vm.define "exec" do |m|
        # m.vm.box = "nomad-exec"
        m.vm.synced_folder '.', '/vagrant', disabled: false
        config.vm.provision "file", source: "files/ansible.cfg", destination: "/home/vagrant/ansible.cfg"
        m.vm.hostname = "ansible"
        m.vm.provision "shell", path: "scripts/private-key.sh"
        m.vm.provision "shell", path: "scripts/install-ansible.sh"
        m.vm.provision "shell", privileged: false, path: "scripts/run-ansible.sh"
    end
end