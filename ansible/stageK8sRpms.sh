#!/bin/bash
declare -a packages=("docker-ce" "kubeadm" "kubectl" "kubelet" "docker-ce-cli" "containerd.io" "cri-tools")
dir=$1
if [[ "$dir" == "" ]]; then
  echo "Taret dir for package staging is needed"
  exit 1
fi
if [[ ! -e "$dir" ]]; then
  echo "Making dir $dir"
  mkdir -p "$dir"
fi


for package in "${packages[@]}"
do
  yumdownloader --resolve --destdir $dir $package
done
