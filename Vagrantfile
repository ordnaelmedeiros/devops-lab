require 'yaml'

current_dir = File.dirname(File.expand_path(__FILE__))
configs = YAML.load_file("#{current_dir}/ansible/hosts.yml")
all_child = configs['all']['children']

Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/jammy64"
    config.vm.box_version = "20230314.0.0"
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.provision "file", source: "keys/key.pub", destination: "/home/vagrant/.ssh/ansible.pub"
    config.vm.provision "file", source: "keys/key", destination: "/home/vagrant/.ssh/ansible.key"
    config.vm.provision "shell", path: "scripts/authorized-keys.sh"

    all_child.each do |grupo|
        if grupo[1]['children'] != nil then
            grupo[1]['children'].each do |server|
                hostname = server[1]['vars']['hostname']
                datacenter = server[1]['vars']['datacenter']
                memory = server[1]['vars']['ansible_memory']
                server[1]['hosts'].each_with_index do |host,i|
                    config.vm.provider "virtualbox" do |v|
                        v.memory = "#{memory}"
                        v.cpus = 1
                    end
                    config.vm.define "#{hostname}-#{datacenter}-#{i}" do |m|
                        m.vm.hostname = "#{hostname}-#{datacenter}-#{i}"
                        m.vm.network "private_network", ip: "#{host[0]}"
                    end
                end
            end
        else
            grupo[1]['hosts'].each_with_index  do |host,i|
                hostname = grupo[0]
                memory = grupo[1]['vars']['ansible_memory']
                config.vm.provider "virtualbox" do |v|
                    v.memory = "#{memory}"
                    v.cpus = 1
                end
                config.vm.define "#{hostname}-#{i}" do |m|
                    m.vm.hostname = "#{hostname}-#{i}"
                    m.vm.network "private_network", ip: "#{host[0]}"
                end
            end
        end
    end

    config.vm.define "proxy-0" do |m|
        m.vm.network "forwarded_port", guest: 80, host: 80
    end

    config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
    end
    config.vm.define "exec" do |m|
        m.vm.synced_folder '.', '/vagrant', disabled: false
        config.vm.provision "file", source: "files/ansible.cfg", destination: "/home/vagrant/ansible.cfg"
        m.vm.hostname = "ansible"
        m.vm.provision "shell", path: "scripts/private-key.sh"
        m.vm.provision "shell", path: "scripts/install-ansible.sh"
        m.vm.provision "shell", privileged: false, path: "scripts/run-ansible.sh"
    end

end
