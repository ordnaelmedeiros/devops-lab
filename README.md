# devops-lab

## Dependencies

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

## Install

### Vagrant
```shell
vagrant up
```

### Retry install
```shell
vagrant ssh exec -c /vagrant/scripts/run-ansible.sh
```

## Verify
- Consul: http://consul-web.localhost
- Nomad: http://nomad-web.localhost
- Traefik: http://traefik-web.localhost
- First app: http://whoami.localhost
