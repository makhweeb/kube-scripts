sudo modprobe br_netfilter
sudo sysctl -w net.ipv4.ip_forward=1


# after install kube

mkdir $HOME/.kube 
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown 1000:1000 $HOME/.kube/config