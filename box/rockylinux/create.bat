vagrant box remove nomad-rockylinux --all -f
vagrant up
vagrant package --output custom.box
vagrant box add nomad-rockylinux custom.box
vagrant destroy -f
del .\custom.box