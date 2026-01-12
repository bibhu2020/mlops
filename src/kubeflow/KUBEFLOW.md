## Kubeflow

### Pre-requsite
mincrok8s

### Install kubeflow using juju
```bash
sudo microk8s enable dns hostpath-storage metallb:10.64.140.43-10.64.140.49 rbac
microk8s status

# Install juju
sudo snap install juju --channel=3.6/stable

# folder needed by juju
mkdir -p ~/.local/share

# microk8s does not store config in ~/.kube/config file
# so lets create it.
microk8s config > ~/.kube/config

# 
juju add-k8s my-k8s

# enable juju in microk8s
# k8s substrate "microk8s/localhost" added as cloud "my-k8s".
# microk8s config | juju add-k8s my-k8s --client

# deploy juju controller
# bootstrap my-k8s to juju cloud by running 'juju bootstrap my-k8s'.
juju bootstrap my-k8s uk8sx
# controller "uk8sx" is now available in namespace "controller-uk8sx"
juju controllers

# add kubeflow model (is where all kubeflow applications are attached)
juju add-model kubeflow

juju models

# you should see 2 new namespaes. one for model, and one for controller
kubectl get ns

# at this point, the model is empty
juju status

#
sudo sysctl fs.inotify.max_user_instances=1280
sudo sysctl fs.inotify.max_user_watches=655360

# or add to this file /etc/sysctl.conf:
fs.inotify.max_user_instances=1280
fs.inotify.max_user_watches=655360

# Deploy CKF (Charmed Kubeflow)
juju deploy kubeflow --trust --channel=1.10/stable

juju status --watch 5s

microk8s kubectl edit deployment dex-auth -n kubeflow

# Disable selected services
juju scale-application admission-webhook 0
juju scale-application notebooks-controller 0

juju scale-application ml-pipeline-ui 0
juju scale-application ml-pipeline-api-server 0
juju scale-application ml-pipeline-persistence 0

juju scale-application auth0-controller 0

# Enable selected services
juju scale-application admission-webhook 1
juju scale-application notebooks-controller 1

juju scale-application ml-pipeline-ui 1
juju scale-application ml-pipeline-api-server 1
juju scale-application ml-pipeline-persistence 1

juju scale-application auth0-controller 1

# Configure dashboard
juju config dex-auth static-username=admin@example.com
juju config dex-auth static-password=admin

# find the ip address of the dashboard
microk8s kubectl -n kubeflow get svc istio-ingressgateway-workload -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# default loging admin/admin

# Expose the dashboard on nodeport (by default its clusterIP service)
#kubectl apply -f kubeflow-dashboard-nodeport.yaml

## Find dashboard ip here: kubectl get services -n kubeflow -owide | grep 'istio'
## look for the NODEPORT for LOADBALANCER SERVICE istio-ingressgateway-workload
http://172.19.202.201:31232/

```

### Uninstall Kubeflow
```bash
juju destroy-model kubeflow --destroy-storage --no-prompt

juju destroy-model kubeflow --destroy-storage --force --no-prompt --timeout 10m

juju destroy-controller uk8sx --no-prompt

sudo microk8s disable metallb 
#dns hostpath-storage rbac
```