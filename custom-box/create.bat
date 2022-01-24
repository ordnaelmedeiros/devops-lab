vagrant up
vagrant package --output devops-lab-rockylinux.box
vagrant box add devops-lab-rockylinux devops-lab-rockylinux.box
vagrant destroy -f