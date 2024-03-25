# 
#   3. Init && Apply Calico
#

sudo kubeadm init

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml