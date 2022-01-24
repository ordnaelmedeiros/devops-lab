# devops-lab

## Dependencies

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

## Config

- Change public ip in Vagrantfile
- Change ip in hosts

## Execute

### Create custom box
```shell
cd custom-box
./create.bat
```

### Up cluster
```shell
vagrant up
vagrant ssh ansible
- cd /vagrant
- ansible-playbook -i hosts cluster.yml
```

## Verify
- Consul: http://localhost:8500
- Nomad: http://localhost:4646
- Traefik: http://localhost:8081
- First app: http://localhost/http-echo
