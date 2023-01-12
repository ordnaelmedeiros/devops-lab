export NOMAD_ADDR="http://192.168.56.111:4646"
for i in $(ls | grep .nomad); do nomad job run $i; done;