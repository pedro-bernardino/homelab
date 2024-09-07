#!/bin/bash



#############################################
#                   VARS                    #
#############################################

# User of remote machines
user=<vm-user>
#ssh certificate name variable
certName=id_rsa
# Interface used on remotes
interface=eth0

# K3S Version
k3sVersion="v1.29.7+k3s1"
# Version of Kube-VIP to deploy
KVVERSION="v0.8.2"

# Set the virtual IP address (VIP)
vip=xx.xx.xx.60
#Loadbalancer IP range
lbrange=xx.xx.xx.61-xx.xx.xx.79

# Set the IP addresses of the masters and workers
# Reconmendations: 3 master and 3 workers
masterNodes=(xx.xx.xx.41 xx.xx.xx.42 xx.xx.xx.43)
workerNodes=(xx.xx.xx.44 xx.xx.xx.45 xx.xx.xx.46)

#############################################
#                  SCRIPT                   #
#############################################

function printok() {
    echo -e "\033[0;102m$1\033[0m"
}
function printko() {
    echo -e "\033[1;91m$1\033[0m"
}

#Combining all nodes
allNodes=("${masterNodes[@]}" "${workerNodes[@]}")

#printok "${masterNodes[*]}"
#printok "${workersNodes[*]}"
#printok "${allNodes[*]}"

# For testing purposes - in case time is wrong due to VM snapshots
sudo timedatectl set-ntp off
sudo timedatectl set-ntp on

# Looking for the ssh keys
printok "Looking for the ssh keys"
if  ! test -f $HOME/.ssh/$certName && ! test -f $HOME/.ssh/$certName.pub
then
    #no keys in $HOME/.ssh/
    printko "keys not found in $HOME/.ssh/"
    if test -f $HOME/$certName
    then
      #keys found in $HOME
      printok "Moving keys to /.ssh/"
      cp $HOME/{$certName,$certName.pub} $HOME/.ssh
      chmod 600 $HOME/.ssh/$certName 
      chmod 644 $HOME/.ssh/$certName.pub
      rm $HOME/{$certName,$certName.pub}
    else
      printko "ERROR: keys not found in $HOME"
      printko "Move your ssh keys to $HOME folder ----> Exiting..."
      exit
    fi
else
    printok "keys already in $HOME/.ssh/ ----> Skipping"
fi

# Create SSH Config file to ignore checking (don't use in production!)
sed -i '1s/^/StrictHostKeyChecking no\n/' ~/.ssh/config

# add ssh keys for all nodes
for node in "${allNodes[@]}"; do
  ssh-copy-id $user@$node
done

# Install k3sup to local machine if not already present
if ! command -v k3sup version &> /dev/null
then
    printko "sup not found, installing..."
    curl -sLS https://get.k3sup.dev | sh
    sudo install k3sup /usr/local/bin/
    sudo cp k3sup /usr/local/bin/k3sup
else
    printok "sup already installed ----> Skipping"
fi

# Install Kubectl if not already present
if ! command -v kubectl version &> /dev/null
then
    printko "Kubectl not found, installing..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
else
    printok "Kubectl already installed ----> Skipping"
fi

# Install policycoreutils for each node (apt list policycoreutils)
for newnode in "${allNodes[@]}"; do
  printok "Installing policycoreutils on node: $newnode..."
  ssh $user@$newnode -i ~/.ssh/$certName sudo su <<EOF
  NEEDRESTART_MODE=a apt install policycoreutils -y
  exit
EOF
done
printok "PolicyCoreUtils installed!"

# Step 1: Bootstrap First k3s Node 
master1="${masterNodes[0]}"
mkdir ~/.kube
k3sup install \
  --ip $master1 \
  --user $user \
  --tls-san $vip \
  --cluster \
  --k3s-version $k3sVersion \
  --k3s-extra-args "--disable traefik --disable servicelb --flannel-iface=$interface --node-ip=$master1 --node-taint node-role.kubernetes.io/master=true:NoSchedule" \
  --merge \
  --sudo \
  --local-path $HOME/.kube/config \
  --ssh-key $HOME/.ssh/$certName \
  --context k3s-ha
printok "First Node bootstrapped successfully!"

# Step 2: Install Kube-VIP for HA
kubectl apply -f https://kube-vip.io/manifests/rbac.yaml

# Step 3: Download kube-vip
curl -sO https://raw.githubusercontent.com/JamesTurland/JimsGarage/main/Kubernetes/K3S-Deploy/kube-vip
cat kube-vip | sed 's/$interface/'$interface'/g; s/$vip/'$vip'/g' > $HOME/kube-vip.yaml

# Step 4: Copy kube-vip.yaml to master1
scp -i ~/.ssh/$certName $HOME/kube-vip.yaml $user@$master1:~/kube-vip.yaml

# Step 5: Connect to Master1 and move kube-vip.yaml
ssh $user@$master1 -i ~/.ssh/$certName <<- EOF
  sudo mkdir -p /var/lib/rancher/k3s/server/manifests
  sudo mv kube-vip.yaml /var/lib/rancher/k3s/server/manifests/kube-vip.yaml
EOF

# Step 6: Add new master nodes (servers) and workers (agents)
# add masters
for newnode in "${masterNodes[@]}"; do
  if [[ ! "$newnode" == "${masterNodes[0]}" ]] #skipping master node 1
  then
    k3sup join \
      --ip $newnode \
      --user $user \
      --sudo \
      --k3s-version $k3sVersion \
      --server \
      --server-ip $master1 \
      --ssh-key $HOME/.ssh/$certName \
      --k3s-extra-args "--disable traefik --disable servicelb --flannel-iface=$interface --node-ip=$newnode --node-taint node-role.kubernetes.io/master=true:NoSchedule" \
      --server-user $user
    printok "Master $newnode joined successfully!"
  fi
done

# add workers
for newagent in "${workerNodes[@]}"; do
  k3sup join \
    --ip $newagent \
    --user $user \
    --sudo \
    --k3s-version $k3sVersion \
    --server-ip $master1 \
    --ssh-key $HOME/.ssh/$certName \
    --k3s-extra-args "--node-label \"longhorn=true\" --node-label \"worker=true\""
  printok "Worker $newnode joined successfully!"
done

# Step 7: Install kube-vip as network LoadBalancer - Install the kube-vip Cloud Provider
kubectl apply -f https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml

# Step 8: Install Metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
# Download ipAddressPool and configure using lbrange above
curl -sO https://raw.githubusercontent.com/JamesTurland/JimsGarage/main/Kubernetes/K3S-Deploy/ipAddressPool
cat ipAddressPool | sed 's/$lbrange/'$lbrange'/g' > $HOME/ipAddressPool.yaml
kubectl apply -f $HOME/ipAddressPool.yaml

# Step 9: Test with Nginx
kubectl apply -f https://raw.githubusercontent.com/inlets/inlets-operator/master/contrib/nginx-sample-deployment.yaml -n default
kubectl expose deployment nginx-1 --port=80 --type=LoadBalancer -n default

printok "Waiting for K3S to sync and LoadBalancer to come online"

while [[ $(kubectl get pods -l app=nginx -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
   sleep 1
done

# Step 10: Deploy IP Pools and l2Advertisement
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=component=controller \
                --timeout=120s
#kubectl apply -f ipAddressPool.yaml
kubectl apply -f https://raw.githubusercontent.com/JamesTurland/JimsGarage/main/Kubernetes/K3S-Deploy/l2Advertisement.yaml

printok "#############################################"
printok "#                   nodes                   #"
printok "#############################################"
kubectl get nodes
printok "#############################################"
printok "#                    svc                    #"
printok "#############################################"
kubectl get svc
printok "#############################################"
printok "#                    pods                   #"
printok "#############################################"
kubectl get pods --all-namespaces -o wide


#Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


#Add Rancher Helm Repository
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system


#Install Cert-Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.13.2

kubectl get pods --namespace cert-manager


#Install Rancher
helm install rancher rancher-latest/rancher \
 --namespace cattle-system \
 --set hostname=rancher.my.org \
 --set bootstrapPassword=admin

kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system get deploy rancher


#Expose Rancher via Loadbalancer
kubectl expose deployment rancher --name=rancher-lb --port=443 --type=LoadBalancer -n cattle-system
kubectl get svc -n cattle-system


# Install Longhorn (using modified Official to pin to Longhorn Nodes)
kubectl apply -f ./longhorn.yaml
kubectl get pods \
--namespace longhorn-system \
--watch

# Print out confirmation
kubectl get nodes
kubectl get svc -n longhorn-system

printok "Access Longhorn through Rancher UI"

exit


