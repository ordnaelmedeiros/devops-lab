vagrant box remove nomad-exec --all -f
vagrant up
vagrant package --output custom.box
vagrant box add nomad-exec custom.box
vagrant destroy -f
del .\custom.box