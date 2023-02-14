Import-Module -WarningAction Ignore -Name "$PSScriptRoot\utils.psm1"

$env:POD_NAMESPACE = 'kube-system'
$env:KUBE_DIR='c:\etc\kubernetes'
$env:KUBECONFIG='C:\\etc\\kubernetes\\admin.conf'
$env:CNI_BIN_PATH = "C:\\opt\\cni\\bin"
$env:CNI_CONFIG_PATH = "C:\\etc\\cni\\net.d"
$BIN = "C:\usr\local\bin"
$KUBERNETES_MASTER="0.0.0.0"
$env:KUBERNETES_MASTER="0.0.0.0"
$env:KUBE_NETWORK = "Flannel.*"


########################################
### VERSIONS
########################################

$CNI_PLUGINS_VERSION="1.1.1"
$FLANNEL_VERSION="0.21.1"
$CONTAINERD_VERSION="1.6.16"
$ETCD_VERSION="3.5.7"
$KUBE_VERSION="1.24.10"
$COREDNS_VERSION="1.10.1"
$BUILDKIT_VERSION="0.11.2"
$NERDCTL_VERSION="1.2.0"
$GOLANG_VERSION="1.19.5"
$HELM_VERSION="3.11.0"
$GIT_VERSION="2.39.1"

if (-not $Tag) {
    $env:BUILD_TAG="dev"
}
$env:BUILD_TAG=$Tag

if (-not $env:CNI_PLUGINS_VERSION) {
    $env:CNI_PLUGINS_VERSION=$CNI_PLUGINS_VERSION
}

if (-not $env:FLANNEL_VERSION) {
    $env:FLANNEL_VERSION=$FLANNEL_VERSION
}

if (-not $env:CONTAINERD_VERSION) {
    $env:CONTAINERD_VERSION=$CONTAINERD_VERSION
}

if (-not $env:ETCD_VERSION) {
    $env:ETCD_VERSION=$ETCD_VERSION
}

if (-not $env:KUBE_VERSION) {
    $env:KUBE_VERSION=$KUBE_VERSION
}

if (-not $env:COREDNS_VERSION) {
    $env:COREDNS_VERSION=$COREDNS_VERSION
}

if (-not $env:BUILDKIT_VERSION) {
    $env:BUILDKIT_VERSION=$BUILDKIT_VERSION
}

if (-not $env:NERDCTL_VERSION) {
    $env:NERDCTL_VERSION=$NERDCTL_VERSION
}

if (-not $env:GOLANG_VERSION) {
    $env:GOLANG_VERSION=$GOLANG_VERSION
}

if (-not $env:HELM_VERSION) {
    $env:HELM_VERSION=$HELM_VERSION
}

if (-not $env:GIT_VERSION) {
    $env:GIT_VERSION=$GIT_VERSION
}


New-Item -ItemType Directory -Path $env:KUBE_DIR -Force > $null
New-Item -ItemType Directory -Path $env:CNI_BIN_PATH -Force >$null
New-Item -ItemType Directory -Path $env:CNI_CONFIG_PATH -Force > $null

$null = New-Item -Type Directory -Path $BIN -ErrorAction Ignore
$env:PATH += ";$BIN;$Env:ProgramFiles\containerd;$Env:ProgramFiles\containerd\cni\bin;C:\ProgramData\chocolatey\bin;$Env:ProgramFiles\Git\bin;$Env:ProgramFiles\Go\bin;C:\go-1.19.5\bin"

$serviceSubnet = "10.43.0.0/16"
$podSubnet = "10.42.0.0/16"
$na = Get-NetRoute | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' } | Select-Object -Property ifIndex
$managementIP = (Get-NetIPAddress -ifIndex $na[0].ifIndex -AddressFamily IPv4).IPAddress


$resolvConf=@"
nameserver 8.8.8.8
nameserver 8.8.4.4
"@
Set-Content -Path $env:KUBE_DIR\resolv.conf -Value $resolvConf

$kubeletConfig=@"
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
# featureGates:
#     RuntimeClass: true
runtimeRequestTimeout: 20m
resolvConf: $env:KUBE_DIR\resolv.conf
enableDebuggingHandlers: true
clusterDomain: "cluster.local"
# clusterDNS: ["10.43.0.10", "localhost"]
hairpinMode: "promiscuous-bridge"
cgroupsPerQOS: false
enforceNodeAllocatable: []
"@
Set-Content -Path $env:KUBE_DIR\kubelet-config.yaml -Value $kubeletConfig

$kubeadmConfig=@"
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
localAPIEndpoint:
  advertiseAddress: 0.0.0.0
  bindPort: 6443
nodeRegistration:
  criSocket: npipe:////./pipe/containerd-containerd
  imagePullPolicy: IfNotPresent
  name: master-node
  taints: null
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 10m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.k8s.io
kubernetesVersion: v1.26.1
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.43.0.0/12
scheduler: {}
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
caCertPath: C:/etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: 0.0.0.0:6443
    token: abcdef.0123456789abcdef
    unsafeSkipCAVerification: true
  timeout: 10m0s
  tlsBootstrapToken: abcdef.0123456789abcdef
nodeRegistration:
  criSocket: npipe:////./pipe/containerd-containerd
  imagePullPolicy: IfNotPresent
  name: worker-node
  taints: null
"@
Set-Content -Path $env:KUBE_DIR\kubeadm.conf -Value $kubeadmConfig

$cniConf=@"
    {
      "name": "flannel.4096",
      "cniVersion": "0.3.1",
      "type": "flannel",
      "capabilities": {
        "dns": true
      },
      "delegate": {
        "type": "win-overlay",
        "policies": [
          {
            "Name": "EndpointPolicy",
            "Value": {
              "Type": "OutBoundNAT",
              "ExceptionList": []
            }
          },
          {
            "Name": "EndpointPolicy",
            "Value": {
              "Type": "ROUTE",
              "DestinationPrefix": "",
              "NeedEncap": true
            }
          }
        ]
      }
    }
"@
# Set-Content -Path "$Env:ProgramFiles\containerd\cni\conf\cni-conf.json" -Value $cniConf
Set-Content -Path "$env:CNI_CONFIG_PATH\cni-conf.json" -Value $cniConf

$cniConfContainerd=@"
    {
      "name": "flannel.4096",
      "cniVersion": "0.3.1",
      "type": "flannel",
      "capabilities": {
        "portMappings": true,
        "dns": true
      },
      "delegate": {
        "type": "sdnoverlay",
        "AdditionalArgs": [
          {
            "Name": "EndpointPolicy",
            "Value": {
              "Type": "OutBoundNAT",
              "Settings" : {
                "Exceptions": []
              }
            }
          },
          {
            "Name": "EndpointPolicy",
            "Value": {
              "Type": "SDNROUTE",
              "Settings": {
                "DestinationPrefix": "",
                "NeedEncap": true
              }
            }
          },
          {
            "Name":"EndpointPolicy",
            "Value":{
              "Type":"ProviderAddress",
                "Settings":{
                    "ProviderAddress":""
              }
            }
          }
        ]
      }
    }
"@
Set-Content -Path $env:KUBE_DIR\cni-conf-containerd.json -Value $cniConfContainerd


$cniJson = get-content $env:KUBE_DIR\cni-conf-containerd.json | ConvertFrom-Json
$cniJson.delegate.AdditionalArgs[0].Value.Settings.Exceptions = $serviceSubnet, $podSubnet
$cniJson.delegate.AdditionalArgs[1].Value.Settings.DestinationPrefix = $serviceSubnet
$cniJson.delegate.AdditionalArgs[2].Value.Settings.ProviderAddress = $managementIP
Set-Content -Path "$Env:ProgramFiles\containerd\cni\conf\10-flannel.conf" ($cniJson | ConvertTo-Json -depth 100)

curl.exe -LO https://github.com/flannel-io/flannel/releases/download/v${env:FLANNEL_VERSION}/flanneld.exe
Copy-Item -Path flanneld.exe -Destination C:\usr\local\bin

# check for containerd
if (-Not (Get-Command containerd)) {
    Write-LogWarn "[prepare] failed to find containerd in PATH"
    $version=$env:CONTAINERD_VERSION
    Write-Host "Installing containerd $version"
    curl.exe -L "https://github.com/containerd/containerd/releases/download/v${version}/containerd-${version}-windows-amd64.tar.gz" -o containerd-windows-amd64.tar.gz
    tar.exe xf containerd-windows-amd64.tar.gz
    $null = New-Item -Type Directory -Path "$Env:ProgramFiles\containerd" -ErrorAction Ignore
    $null = New-Item -Type Directory -Path "$Env:ProgramFiles\containerd\cni\bin" -ErrorAction Ignore
    $null = New-Item -Type Directory -Path "$Env:ProgramFiles\containerd\cni\conf" -ErrorAction Ignore
    Move-Item -Path ./bin/*.exe -Destination "$Env:ProgramFiles\containerd"
    Remove-Item -Force containerd-windows-amd64.tar.gz
}

if (-Not (Get-Service containerd)) {
    # Register containerd service and start it
    & $Env:ProgramFiles\containerd\containerd.exe config default | Out-File "$Env:ProgramFiles\containerd\config.toml" -Encoding ascii
    & $Env:ProgramFiles\containerd\containerd.exe --register-service
    Set-Service -Name containerd -StartupType Automatic
    Start-Service containerd
}


if (-Not (Get-Command crictl)) {
    curl.exe -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.26.0/crictl-v1.26.0-windows-amd64.tar.gz
    tar -xzf crictl-v1.26.0-windows-amd64.tar.gz
    Move-Item -Path crictl.exe -Destination "$Env:ProgramFiles\containerd"
    Remove-Item -Force crictl-v1.26.0-windows-amd64.tar.gz
}
crictl.exe config --set runtime-endpoint='npipe:////./pipe/containerd-containerd'


& C:\usr\local\bin\flanneld.exe --kube-subnet-mgr --kubeconfig-file $env:KUBECONFIG --iface $managementIP --net-config-path $env:CNI_CONFIG_PATH\cni-conf.json
#  --envs "POD_NAME=$env:POD_NAME POD_NAMESPACE=$env:POD_NAMESPACE"

# & C:\go-1.19.5\bin\kubelet.exe --v=4 --config=$env:KUBE_DIR\kubelet-config.yaml --kubeconfig=$env:KUBECONFIG --hostname-override=$(hostname) --container-runtime-endpoint='npipe:////./pipe/containerd-containerd'