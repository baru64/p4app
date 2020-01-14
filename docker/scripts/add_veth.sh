ip link add int-veth0 type veth peer name int-veth1
ip addr add 10.0.128.1/24 dev int-veth0
ip link set up int-veth0
