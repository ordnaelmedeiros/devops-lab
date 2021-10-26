# devops-lab

## Dependencies

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

## Config

- Change public ip in Vagrantfile
- Change ip in hosts

## Execute

```shell
vagrant up
```

## Verify
- Consul: http://localhost:8500
- Nomad: http://localhost:4646
- Traefik: http://localhost:8081
- First app: http://localhost/http-echo
