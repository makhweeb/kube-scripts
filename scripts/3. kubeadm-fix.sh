sudo modprobe br_netfilter
sudo sysctl -w net.ipv4.ip_forward=1

# after instasudo systemctl restart containerdll kube

mkdir $HOME/.kube 
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown 1000:1000 $HOME/.kube/config