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
cd box/rockylinux
./create.bat

cd box/exec
./create.bat
```

### Up cluster
```shell
vagrant up
vagrant ssh ansible
- cd /vagrant
- ansible-playbook -i hosts.yml cluster.yml
```

## Verify
- Consul: http://consul-web.localhost
- Nomad: http://nomad-web.localhost
- Traefik: http://traefik-web.localhost
- First app: http://whoami.localhost
