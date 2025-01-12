# K8sNodeSetup
K8sNodeSetup is a script that automates the preparation of nodes for Kubernetes clusters. It handles system updates, package installations, and necessary configurations to ensure nodes are ready to join your cluster, streamlining the process and ensuring consistency across your infrastructure.


# How to Run `start.sh`

1. **Make the script executable**  
   First, ensure that your script has executable permissions. Run the following command in your terminal:
   ```bash
   chmod +x start.sh


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
