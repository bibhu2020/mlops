## Getting your laptop ready
Install the following windows software
- [X] VS Code
- [X] Must install the extension WSL, Jupyter, Python
- [X] One Drive
- [X] Google Drive
- Office 365
- [X] Nord VPN
- [X] WSL2 + Ubuntu
- [X] Configure WSL2 to have 4 core and 16 GB

Install the following WSL softwares:
- [X] git
- [X] configure git access using SSH
- [X] configure WSL to work as git agent server
- [X] nodejs
- [X] python
- [X] docker
- [X] MiniK8s
- [DO NOT NEED] Enable Kubeflow on MiniK8s
- Install MLflow and ZenML

---
### Memory Optimization TIPS

- Stop all AI related services (they are unnecessary overload)

- Stop Windows AI Fabric Service (services windows)

- Turn off AI services from Photo > Settings

---


### Installing Nodejs
```bash
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"
# Download and install Node.js:
nvm install 24
# Verify the Node.js version:
node -v # Should print "v24.11.1".
# Verify npm version:
npm -v # Should print "11.6.2".
```

---
### Installing Python
```bash
sudo apt update
sudo apt install python3.14-full

sudo apt update
sudo apt install python-is-python3


sudo apt install python3-pip

```

---
### Installing uv
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv --version
```

---
### Install docker
```bash
# remove old install
sudo apt-get remove docker docker-engine docker.io containerd runc

# install
sudo apt-get update

sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
newgrp docker

sudo docker --version
sudo docker run hello-world

```


---

### Install microk8s
```bash
# install snap
sudo apt update
sudo apt install snapd

# install k8
sudo snap install microk8s --classic #it install 1.32 k8

sudo snap install microk8s --classic --channel=1.33/stable

# start microk8s
sudo microk8s start  
sudo microk8s status --wait-ready  

# enable features
microk8s enable dns hostpath-storage registry istio

microk8s enable observability
microk8s enable calico


# access dashboard

microk8s kubectl describe secret -n kube-system microk8s-dashboard-token

Use this token in the https login UI of the kubernetes-dashboard service.


# test
sudo microk8s kubectl get nodes  

# add user to microsk8s group
sudo usermod -a -G microk8s $USER  
sudo chown -f -R $USER ~/.kube  
newgrp microk8s

```

---

<!-- ## Monitoring
```bash
sudo mkdir /microk8s
sudo chmod 777 /microk8s

#sudo mkdir -p /microk8s/prometheus-data
sudo chown -R 65534:65534 /microk8s/prometheus-data
sudo chmod -R 755 /microk8s/prometheus-data

#sudo mkdir -p /microk8s/grafana-data
sudo chown -R 472:472 /microk8s/grafana-data
sudo chmod -R 755 /microk8s/grafana-data



kubectl apply -f monitor.yml -n monitoring

``` -->

---
## Install zsh
zsh is an interactive CLI on linux. It gives a nice command prompt. 

```bash
## Install zsh
sudo apt update
sudo apt install zsh -y

## Install "Oh My zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## zsh addon: Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

## Run the following command to configure Powerlevel10k theme

p10k configure

## Make zsh as starting CLI
chsh -s $(which zsh)

## Make bash as default CLI
chsh -s $(which bash)

## change from zsh to bash. simply type
bash

## exit from bash to back to zsh
exit

## Follow the same step to go to zsh if bash is the default CLI

## zsh config file
$HOME/.zshrc

# bash config file
$HOME/.bashrc

## Add this to .zshrc file
### Update PATH
export PATH=$PATH:/snap/bin

### Define aliasa
alias kubectl='microk8s kubectl'
alias k='microk8s kubectl'
alias a='source .venv/bin/activate'
alias d='deactivate'

# Always start in ~/ws
cd ~/ws || echo "Directory ~/ws not found"

```

---

## Installing Helm

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh


```

## Installing Prometheus
```bash

Reference: https://www.youtube.com/watch?v=6xmWr7p5TE0&t=105s

kubectl create ns monitoring 

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm show values prometheus-community/kube-prometheus-stack > src/prometheus/values.yml

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f src/prometheus/values.yml

```

**NOTES:**
```bash
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Get your grafana admin user password by running:

  kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo


Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

helm delete prometheus -n monitoring

```

## Installing Grafana
```bash
https://www.youtube.com/watch?v=fzny5uUaAeY

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm show values grafana/grafana > src/grafana/values.yml

kubectl apply -f src/grafana/grafana-pv-pvc.yaml


helm upgrade --install grafana grafana/grafana \
  -n monitoring \
  -f src/grafana/values.yml

# admin user password (ignore the % at the end)
kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode

helm delete grafana -n monitoring

```

