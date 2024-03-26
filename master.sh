sudo swapoff -a
set -euxo pipefail

sudo tee /etc/modules-load.d/kubernetes.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo lsmod | grep netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# 
#   1. Install containerd
#

wget https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.14-linux-amd64.tar.gz

wget https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v1.4.1/cni-plugins-linux-amd64-v1.4.1.tgz

sudo mkdir -p /opt/cni/bin

sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.1.tgz

sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service

sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# 
#   2. Install Kubelet, Kubeadm, Kubectl
#

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

# 
#   3. Init && Apply Calico
#

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/custom-resources.yaml

# watch kubectl get pods -n calico-system

# kubectl taint nodes --all node-role.kubernetes.io/control-plane-
# kubectl taint nodes --all node-role.kubernetes.io/master-