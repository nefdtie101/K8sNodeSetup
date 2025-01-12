#!/bin/bash

set -e

# Variables
DOCKER_VERSION="20.10"

# Functions
install_dependencies() {
  echo "Installing dependencies..."
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl gpg software-properties-common
}

setup_docker() {
  echo "Installing Docker..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io
  
  # Configure Docker daemon
  cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
  systemctl enable docker
  systemctl restart docker
}

setup_kubernetes() {
  echo "Installing Kubernetes components..."

  # Update apt package index and install Kubernetes components
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl gpg
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
}

disable_swap() {
  echo "Disabling swap..."
  swapoff -a
  sed -i '/ swap / s/^/#/' /etc/fstab
}

configure_sysctl() {
  echo "Configuring sysctl settings for Kubernetes..."
  cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
  sysctl --system
}

fixcontanerd() {
    sudo apt-get update
    sudo apt-get install containerd.io
    sudo mkdir -p /etc/containerd
    sudo containerd config default > /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    sudo systemctl restart containerd
}

main() {
  echo "Preparing the system for Kubernetes..."
  install_dependencies
  setup_docker
  setup_kubernetes
  disable_swap
  configure_sysctl
  echo "Preparation complete. Reboot the system before proceeding with the Kubernetes installation."
}

main
