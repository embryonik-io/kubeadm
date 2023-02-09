## process

all binaries are built using the base-image, which contains goboring FIPS 140-3 compliant Go toolchains

1) build multi-platform base image: rosskirkpat/base-image
2) publish base image for windows/linux arm64 + amd64 to rosskirkpat/base-image on DockerHub
3) build all kubernetes binaries for windows
4) publish kubernetes binaries for windows to rosskirkpat/kubernetes on GitHub
5) package windows binaries in windows container images for all kubernetes components w/ tag `rosskirkpat/$Component`
6) package external binary dependencies (coredns) // TODO: compile coredns binary using base-image
7) publish all windows container images to `rosskirkpat/$Component` on DockerHub

base-image build triggers:
- new goboring version available for current minor go version (ex. 1.18.4 is released and previous builds were using 1.18.3)
- manual trigger

kubernetes component build triggers:
- new base-image version published
- manual trigger


Host process containers???


# run kubeadm controlplane on windows

New-Item -Type Directory -Path "C:\winkube\package" -Force

## get etcd binaries for windows

curl.exe -LO https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-windows-amd64.zip
Expand-Archive etcd-v3.5.4-windows-amd64.zip
Copy-Item etcd*.exe C:\winkube\package\

## build etcd image


## get coredns binaries for windows

curl.exe -LO https://github.com/coredns/coredns/releases/download/v1.9.3/coredns_1.9.3_windows_amd64.tgz
tar xz coredns_1.9.3_windows_amd64.tgz
Copy-Item coredns.exe C:\winkube\package\

## build k8s server binaries for windows


make binaries


## build k8s server images

make 

## kubeadm kube-proxy add-on manifest

https://github.com/kubernetes/kubernetes/blob/master/cmd/kubeadm/app/phases/addons/proxy/manifests.go

the manifest currently supports linux only due to node selectors


## core non-kubernetes components

containerd
cni-plugins
calico
flannel + flannel cni plugin

# flannel cni


## flannel

curl.exe -LO https://github.com/flannel-io/flannel/releases/download/v0.20.2/flanneld.exe
Copy-Item coredns.exe C:\winkube\package\


curl.exe -LO https://github.com/flannel-io/flannel/releases/download/v0.20.2/flannel-v0.20.2-windows-amd64.tar.gz
tar xz flannel-v0.20.2-windows-amd64.tar.gz


## troubleshooting components

crictl
ctr


## kubeadm coredns add-on manifest 

https://github.com/kubernetes/kubernetes/blob/master/cmd/kubeadm/app/phases/addons/dns/manifests.go



## OUTSTANDING TASKS

1) add windows node selectors to kube-proxy manifest https://github.com/kubernetes/kubernetes/blob/master/cmd/kubeadm/app/phases/addons/proxy/manifests.go
2) add windows support to coredns manifest https://github.com/kubernetes/kubernetes/blob/master/cmd/kubeadm/app/phases/addons/dns/manifests.go
3) build and publish coredns windows binaries https://coredns.io/2016/10/30/quick-start-for-windows/
4) swap out docker for nerdctl+containerd OR crane OR ko
5) webhook to build when a new stable k8s release is published
6) migrate to host process containers
7) Finish powershell scripts for automated builds


## IDEAS

1) move main functions to utils.psm1 and use them as modules

# Need to make a multi-platform base build image
# ex. rosskirkpat/build-base where a manifest is published containing images for
# windows/amd64, windows/arm64, linux/amd64, and linux/arm64