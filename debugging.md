echo "export MAJOR=$(/semver-parse.sh ${TAG} major)" \
    >> /usr/local/go/bin/go-build-static-k8s.sh
echo "export MINOR=$(/semver-parse.sh ${TAG} minor)" \
    >> /usr/local/go/bin/go-build-static-k8s.sh
echo "export GIT_COMMIT=$(git rev-parse HEAD)" \
    >> /usr/local/go/bin/go-build-static-k8s.sh
echo "export KUBERNETES_VERSION=$(/semver-parse.sh ${TAG} k8s)" \
    >> /usr/local/go/bin/go-build-static-k8s.sh
echo "export BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    >> /usr/local/go/bin/go-build-static-k8s.sh
echo "export GO_LDFLAGS=\"-linkmode=external \
    -X k8s.io/component-base/version.gitVersion=\${KUBERNETES_VERSION} \
    -X k8s.io/component-base/version.gitMajor=\${MAJOR} \
    -X k8s.io/component-base/version.gitMinor=\${MINOR} \
    -X k8s.io/component-base/version.gitCommit=\${GIT_COMMIT} \
    -X k8s.io/component-base/version.gitTreeState=clean \
    -X k8s.io/component-base/version.buildDate=\${BUILD_DATE} \
    -X k8s.io/client-go/pkg/version.gitVersion=\${KUBERNETES_VERSION} \
    -X k8s.io/client-go/pkg/version.gitMajor=\${MAJOR} \
    -X k8s.io/client-go/pkg/version.gitMinor=\${MINOR} \
    -X k8s.io/client-go/pkg/version.gitCommit=\${GIT_COMMIT} \
    -X k8s.io/client-go/pkg/version.gitTreeState=clean \
    -X k8s.io/client-go/pkg/version.buildDate=\${BUILD_DATE} \
    \"" >> /usr/local/go/bin/go-build-static-k8s.sh
echo 'go-build-static.sh -gcflags=-trimpath=${GOPATH}/src/kubernetes -mod=vendor -tags=selinux,osusergo,netgo ${@}' \
    >> /usr/local/go/bin/go-build-static-k8s.sh
chmod -v +x /usr/local/go/bin/go-*.sh


export MAJOR=
export MINOR=
export GIT_COMMIT=
export KUBERNETES_VERSION=
export BUILD_DATE=2023-02-10T07:44:23Z
export GO_LDFLAGS="-linkmode=external     -X k8s.io/component-base/version.gitVersion=${KUBERNETES_VERSION}     -X k8s.io/component-base/version.gitMajor=${MAJOR}     -X k8s.io/component-base/version.gitMinor=${MINOR}     -X k8s.io/component-base/version.gitCommit=${GIT_COMMIT}     -X k8s.io/component-base/version.gitTreeState=clean     -X k8s.io/component-base/version.buildDate=${BUILD_DATE}     -X k8s.io/client-go/pkg/version.gitVersion=${KUBERNETES_VERSION}     -X k8s.io/client-go/pkg/version.gitMajor=${MAJOR}     -X k8s.io/client-go/pkg/version.gitMinor=${MINOR}     -X k8s.io/client-go/pkg/version.gitCommit=${GIT_COMMIT}     -X k8s.io/client-go/pkg/version.gitTreeState=clean     -X k8s.io/client-go/pkg/version.buildDate=${BUILD_DATE}     "
go-build-static.sh -gcflags=-trimpath=${GOPATH}/src/kubernetes -mod=vendor -tags=selinux,osusergo,netgo ${@}

# go-build-static.sh
exec go build -ldflags "-linkmode=external -extldflags \"-static -Wl,--fatal-warnings\" ${GO_LDFLAGS}" "${@}"


rosskirk@LAPTOP-3AE1SB33:~$ ./go-build-static-k8s.sh -o bin/kube-apiserver           ./cmd/kube-apiserver


+ exec go build -ldflags -linkmode=external -extldflags "-static -Wl,--fatal-warnings" -linkmode=external     -X k8s.io/component-base/version.gitVersion=     -X k8s.io/component-base/version.gitMajor=     -X k8s.io/component-base/version.gitMinor=     -X k8s.io/component-base/version.gitCommit=     -X k8s.io/component-base/version.gitTreeState=clean     -X k8s.io/component-base/version.buildDate=2023-02-10T07:44:23Z     -X k8s.io/client-go/pkg/version.gitVersion=     -X k8s.io/client-go/pkg/version.gitMajor=     -X k8s.io/client-go/pkg/version.gitMinor=     -X k8s.io/client-go/pkg/version.gitCommit=     -X k8s.io/client-go/pkg/version.gitTreeState=clean     -X k8s.io/client-go/pkg/version.buildDate=2023-02-10T07:44:23Z      -gcflags=-trimpath=/src/kubernetes -mod=vendor -tags=selinux,osusergo,netgo -o bin/kube-apiserver ./cmd/kube-apiserver



-linkmode=external -extldflags "-static -Wl,--fatal-warnings" "-linkmode=external -X k8s.io/component-base/version.gitVersion=v1.26.1 -X k8s.io/component-base/version.gitMajor=1 -X k8s.io/component-base/version.gitMinor=26 -X k8s.io/component-base/version.gitCommit=8f94681cd294aa8cfd3407b8191f6c70214973a4 -X k8s.io/component-base/version.gitTreeState=clean -X k8s.io/component-base/version.buildDate=2023-02-10T03:47:18Z -X k8s.io/client-go/pkg/version.gitVersion=v1.26.1 -X k8s.io/client-go/pkg/version.gitMajor=1 -X k8s.io/client-go/pkg/version.gitMinor=26 -X k8s.io/client-go/pkg/version.gitCommit=8f94681cd294aa8cfd3407b8191f6c70214973a4 -X k8s.io/client-go/pkg/version.gitTreeState=clean -X k8s.io/client-go/pkg/version.buildDate=$BUILD_DATE " "-gcflags=-trimpath=go-1.19.5\\src\\kubernetes" -mod=vendor -tags=osusergo,netgo -extld=gcc 


"C:\\Program Files\\Go\\pkg\\tool\\windows_amd64\\link.exe" -o "$WORK\\b001\\exe\\a.out.exe" -importcfg "$WORK\\b001\\importcfg.link" -buildmode=pie -buildid=wSIIVTibRUC1o-zNX5x6/Grxmt3DH7YrH2xFpOli5/Cih9km2GaOMe0kdGcmnD/wSIIVTibRUC1o-zNX5x6 -linkmode=external -extldflags "-static -Wl,--fatal-warnings" -linkmode=external -X k8s.io/component-base/version.gitVersion=v1.26.1 -X k8s.io/component-base/version.gitMajor=1 -X k8s.io/component-base/version.gitMinor=26 -X k8s.io/component-base/version.gitCommit=8f94681cd294aa8cfd3407b8191f6c70214973a4 -X k8s.io/component-base/version.gitTreeState=clean -X k8s.io/component-base/version.buildDate=2023-02-10T04:28:00Z -X k8s.io/client-go/pkg/version.gitVersion=v1.26.1 -X k8s.io/client-go/pkg/version.gitMajor=1 -X k8s.io/client-go/pkg/version.gitMinor=26 -X k8s.io/client-go/pkg/version.gitCommit=8f94681cd294aa8cfd3407b8191f6c70214973a4 -X k8s.io/client-go/pkg/version.gitTreeState=clean -X k8s.io/client-go/pkg/version.buildDate=2023-02-10T04:28:00Z -gcflags=-trimpath=/go-1.19.5/src/kubernetes -mod=vendor -tags=osusergo,netcgo,static_build -extld=x86_64-w64-mingw32-gcc "$WORK\\b001\\_pkg_.a"
# k8s.io/kubernetes/cmd/kubeadm
flag provided but not defined: -gcflags


"C:\\Program Files\\Go\\pkg\\tool\\windows_amd64\\link.exe" -o "$WORK\\b001\\exe\\a.out.exe" -importcfg "$WORK\\b001\\importcfg.link" -buildmode=pie -buildid=wSIIVTibRUC1o-zNX5x6/Grxmt3DH7YrH2xFpOli5/Cih9km2GaOMe0kdGcmnD/wSIIVTibRUC1o-zNX5x6 -linkmode=external -extldflags "-static -Wl,--fatal-warnings" -linkmode=external -X k8s.io/component-base/version.gitVersion=v1.26.1 -X k8s.io/component-base/version.gitMajor=1 -X k8s.io/component-base/version.gitMinor=26 -X k8s.io/component-base/version.gitCommit=8f94681cd294aa8cfd3407b8191f6c70214973a4 -X k8s.io/component-base/version.gitTreeState=clean -X k8s.io/component-base/version.buildDate=2023-02-10T04:28:00Z -X k8s.io/client-go/pkg/version.gitVersion=v1.26.1 -X k8s.io/client-go/pkg/version.gitMajor=1 -X k8s.io/client-go/pkg/version.gitMinor=26 -X k8s.io/client-go/pkg/version.gitCommit=8f94681cd294aa8cfd3407b8191f6c70214973a4 -X k8s.io/client-go/pkg/version.gitTreeState=clean -X k8s.io/client-go/pkg/version.buildDate=2023-02-10T04:28:00Z -gcflags=-trimpath=/go-1.19.5/src/kubernetes -mod=vendor -tags=osusergo,netcgo,static_build -extld=x86_64-w64-mingw32-gcc "C:\\Users\\rosskirk\\AppData\\Local\\go-build\\71\\71ec8009022a2a8bb4989af730dfed2512aadb62dbf5c85491b58e1fff3d04e2-d"
# k8s.io/kubernetes/cmd/kubeadm
flag provided but not defined: -gcflags




# kube::golang::build_some_binaries() 
      GO111MODULE=on GOPROXY=off go install "${build_args[@]}" "$@"



    # These are "local" but are visible to and relied on by functions this
    # function calls.  They are effectively part of the calling API to
    # build_binaries_for_platform.
    local goflags goldflags goasmflags gogcflags gotags

    # This is $(pwd) because we use run-in-gopath to build.  Once that is
    # excised, this can become ${KUBE_ROOT}.
    local trimroot # two lines to appease shellcheck SC2155
    trimroot=$(pwd)

    goasmflags="all=-trimpath=${trimroot}"

    gogcflags="all=-trimpath=${trimroot} ${GOGCFLAGS:-}"
    if [[ "${DBG:-}" == 1 ]]; then
        # Debugging - disable optimizations and inlining and trimPath
        gogcflags="${GOGCFLAGS:-} all=-N -l"
        goasmflags=""
    fi

    goldflags="all=$(kube::version::ldflags) ${GOLDFLAGS:-}"
    if [[ "${DBG:-}" != 1 ]]; then
        # Not debugging - disable symbols and DWARF.
        goldflags="${goldflags} -s -w"
    fi

    # Extract tags if any specified in GOFLAGS
    gotags="selinux,notest,$(echo "${GOFLAGS:-}" | sed -ne 's|.*-tags=\([^-]*\).*|\1|p')"

## upstream hack/lib/golang.sh

  if [[ "${#statics[@]}" != 0 ]]; then
    build_args=(
      -installsuffix=static
      ${goflags:+"${goflags[@]}"}
      -gcflags="${gogcflags}"
      -asmflags="${goasmflags}"
      -ldflags="${goldflags}"
      -tags="${gotags:-}"
    )
    CGO_ENABLED=0 kube::golang::build_some_binaries "${statics[@]}"
  fi


```shell
```


```powershell
$env:GOLANG_VERSION="1.19.5"
$GOPATH="C:\go-$env:GOLANG_VERSION"
$env:GOPATH=$GOPATH
$env:GO15VENDOREXPERIMENT=1
$env:GOROOT=$(go env GOROOT)
$env:GO111MODULE='on'

# cgo requirements
$env:CXX = 'x86_64-w64-mingw32-g++'
$env:CC = 'x86_64-w64-mingw32-gcc'
$env:GOARCH = $env:ARCH
$env:GOOS = 'windows'
$env:CGO_ENABLED = 1

$GIT_COMMIT=$(git rev-parse HEAD)
$BUILD_DATE=$(Get-Date  -UFormat "+%Y-%m-%dT%H:%M:%SZ") 
$MAJOR='1'
$MINOR='26'
$KUBERNETES_VERSION='v1.26.1'
$KUBE_GO_PACKAGE='k8s.io/kubernetes'

go mod vendor

$env:GOPROXY='off'
$GO_FLAGS=""
$GO_ASM_FLAGS="all=-trimpath=$GOPATH\src\kubernetes"
$GO_GC_FLAGS="all=-trimpath=$GOPATH\src\kubernetes"
# testing removal of mod=vendor to see if version linking is fixed
# $GO_LD_FLAGS='all=-linkmode=external -extldflags \"-static -Wl,--fatal-warnings\" -mod=vendor'
$GO_LD_FLAGS='all=-linkmode=external -extldflags \"-static -Wl,--fatal-warnings\"'
$LD_FLAGS=('-linkmode=external' +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/client-go/pkg/version.gitVersion=$KUBERNETES_VERSION" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/client-go/pkg/version.gitMajor=$MAJOR" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/client-go/pkg/version.gitMinor=$MINOR" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/client-go/pkg/version.gitCommit=$GIT_COMMIT" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/client-go/pkg/version.gitTreeState=clean" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/client-go/pkg/version.buildDate=$BUILD_DATE" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/component-base/pkg/version.gitVersion=$KUBERNETES_VERSION" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/component-base/pkg/version.gitMajor=$MAJOR" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/component-base/pkg/version.gitMinor=$MINOR" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/component-base/pkg/version.gitCommit=$GIT_COMMIT" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/component-base/pkg/version.gitTreeState=clean" +
    " -X ${KUBE_GO_PACKAGE}/vendor/k8s.io/component-base/pkg/version.buildDate=$BUILD_DATE" +
    " -X k8s.io/component-base/version.gitVersion=$KUBERNETES_VERSION" +
    " -X k8s.io/component-base/version.gitMajor=$MAJOR" +
    " -X k8s.io/component-base/version.gitMinor=$MINOR" +
    " -X k8s.io/component-base/version.gitCommit=$GIT_COMMIT" +
    " -X k8s.io/component-base/version.gitTreeState=clean" +
    " -X k8s.io/component-base/version.buildDate=$BUILD_DATE" +
    " -X k8s.io/client-go/pkg/version.gitVersion=$KUBERNETES_VERSION" +
    " -X k8s.io/client-go/pkg/version.gitMajor=$MAJOR" +
    " -X k8s.io/client-go/pkg/version.gitMinor=$MINOR" +
    " -X k8s.io/client-go/pkg/version.gitCommit=$GIT_COMMIT" +
    " -X k8s.io/client-go/pkg/version.gitTreeState=clean" +
    " -X k8s.io/client-go/pkg/version.buildDate=$BUILD_DATE " 
)
$GO_TAGS="osusergo,netcgo,static_build"

# go install "-installsuffix=static -gcflags='$GO_GC_FLAGS' -asmflags='$GO_ASM_FLAGS' -ldflags='$LD_FLAGS $GO_LD_FLAGS' -tags='$GO_TAGS'" ./cmd/kubeadm

$Binaries = @("kubelet", "kube-apiserver", "kube-scheduler", "kube-controller-manager", "kube-proxy", "kubeadm", "kubectl")
foreach ($BINARY in $Binaries) {
    go install "-installsuffix=static -gcflags='$GO_GC_FLAGS' -asmflags='$GO_ASM_FLAGS' -ldflags='$LD_FLAGS $GO_LD_FLAGS' -tags='$GO_TAGS'" ./cmd/$BINARY
}

```

```powershell

$env:POD_NAMESPACE = 'kube-system'
$env:KUBE_DIR='c:\etc\kubernetes'
$env:KUBECONFIG='C:\\etc\\kubernetes\\admin.conf'
$env:CNI_BIN_PATH = "C:\\opt\\cni\\bin"
$env:CNI_CONFIG_PATH = "C:\\etc\\cni\\net.d"
$env:CONTAINER_RUNTIME_ENDPOINT = "npipe:////.//pipe//containerd-containerd"

New-Item -ItemType Directory -Path $env:KUBE_DIR -Force > $null
New-Item -ItemType Directory -Path $env:CNI_BIN_PATH -Force >$null
New-Item -ItemType Directory -Path $env:CNI_CONFIG_PATH -Force > $null

$serviceSubnet = "10.43.0.0/16"
$podSubnet = "10.42.0.0/16"
$na = Get-NetRoute | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' } | Select-Object -Property ifIndex
$managementIP = (Get-NetIPAddress -ifIndex $na[0].ifIndex -AddressFamily IPv4).IPAddress

$kubeletConfig=@"
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
featureGates:
    RuntimeClass: true
runtimeRequestTimeout: 20m
resolverConfig: ""
enableDebuggingHandlers: true
clusterDomain: "cluster.local"
hairpinMode: "promiscuous-bridge"
cgroupsPerQOS: false
enforceNodeAllocatable: []
"@
Add-Content -Path $env:KUBE_DIR\kubelet-config.yaml -Value $kubeletConfig

$resolvConf=@"
nameserver 8.8.8.8
nameserver 8.8.4.4
"@
Add-Content -Path $env:KUBE_DIR\resolv.conf -Value $resolvConf

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
  criSocket: $env:CONTAINER_RUNTIME_ENDPOINT
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
  serviceSubnet: 10.43.0.0/16
  podSubnet: 10.42.0.0/16
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
  criSocket: $env:CONTAINER_RUNTIME_ENDPOINT
#   criSocket: \\.\\pipe\\containerd-containerd
  imagePullPolicy: IfNotPresent
  name: worker-node
  taints: null
"@
Add-Content -Path $env:KUBE_DIR\kubeadm.conf -Value $kubeadmConfig

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
Add-Content -Path $env:CNI_CONFIG_PATH\cni-conf.json -Value $cniConf

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
Add-Content -Path $env:KUBE_DIR\cni-conf-containerd.json -Value $cniConfContainerd


$cniJson = get-content $env:KUBE_DIR\cni-conf-containerd.json | ConvertFrom-Json
$cniJson.delegate.AdditionalArgs[0].Value.Settings.Exceptions = $serviceSubnet, $podSubnet
$cniJson.delegate.AdditionalArgs[1].Value.Settings.DestinationPrefix = $serviceSubnet
$cniJson.delegate.AdditionalArgs[2].Value.Settings.ProviderAddress = $managementIP
Set-Content -Path $env:CNI_CONFIG_PATH\10-flannel.conf ($cniJson | ConvertTo-Json -depth 100)

curl.exe -LO https://github.com/flannel-io/flannel/releases/download/v${env:FLANNEL_VERSION}/flanneld.exe
Copy-Item -Path flanneld.exe -Destination C:\usr\local\bin

& C:\usr\local\bin\flanneld.exe --kube-subnet-mgr --kubeconfig-file $env:KUBECONFIG --iface $managementIP
#  --envs "POD_NAME=$env:POD_NAME POD_NAMESPACE=$env:POD_NAMESPACE"


$Env:ProgramFiles\containerd\crictl.exe config --set runtime-endpoint='npipe:////./pipe/containerd-containerd'

& C:\go-1.19.5\bin\kubelet.exe --v=4 --config=c:\kube\kubelet-config.yaml --kubeconfig='C:\\etc\\kubernetes\\admin.conf' --hostname-override=$(hostname) --container-runtime=remote --container-runtime-endpoint='npipe:////./pipe/containerd-containerd' --cluster-dns=10.43.0.10 --resolv-conf=c:\kube\etc\resolv.conf

& C:\go-1.19.5\bin\kube-proxy.exe --kubeconfig='C:\\etc\\kubernetes\\admin.conf' --source-vip 10.42.89.130 --hostname-override=$(hostname) --proxy-mode=kernelspace --v=4 --cluster-cidr=10.42.0.0/16 --network-name=Flannel --feature-gates="WinOverlay=true" --masquerade-all="false"
```



## images to build
```console
PS C:\Users\rosskirk\projects\kubeadm> kubeadm config images list
W0210 15:15:22.304710   19748 initconfiguration.go:119] Usage of CRI endpoints without URL scheme is deprecated and can cause kubelet errors in the future. Automatically prepending scheme "npipe" to the "criSocket" with value "unix:///var/run/unknown.sock". Please update your configuration!
W0210 15:15:23.147084   19748 version.go:116] could not obtain client version; using remote version: v1.26.1
registry.k8s.io/kube-apiserver:v1.26.1
registry.k8s.io/kube-controller-manager:v1.26.1
registry.k8s.io/kube-scheduler:v1.26.1
registry.k8s.io/kube-proxy:v1.26.1
registry.k8s.io/pause:3.9
registry.k8s.io/etcd:3.5.6-0
registry.k8s.io/coredns/coredns:v1.9.3
```

