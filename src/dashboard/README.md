# Install helm
sudo apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm



# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace monitoring


## Expose the dashboard on a node-port
kubectl patch svc kubernetes-dashboard-kong-proxy -n monitoring \
  -p '{"spec": {"type": "NodePort","ports":[{"name":"kong-proxy-tls","port":443,"targetPort":8443,"nodePort":32043}]}}'

## Generate bearer token for the service account to access dashboard

kubectl -n monitoring port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

https://localhost:8443

## Create a service account and bearer token
kubectl apply -f src/dashboard/dashboard-admin.yml

kubectl -n monitoring create token dashboard-admin