#Requires -Version 5.0

$ErrorActionPreference = 'Ignore'

Import-Module -WarningAction Ignore -Name "$PSScriptRoot\utils.psm1"
# Invoke-Expression -Command "$PSScriptRoot\version.ps1"

$BIN = "C:\usr\local\bin"
$null = New-Item -Type Directory -Path $BIN -ErrorAction Ignore
$env:PATH += ";$BIN;$Env:ProgramFiles\containerd;$Env:ProgramFiles\containerd\cni\bin;C:\ProgramData\chocolatey\bin;$Env:ProgramFiles\Git\bin;$Env:ProgramFiles\Go\bin"

# check for choco and install if not present
if (-Not (Get-Command choco)) {
    Write-LogWarn "[prepare] failed to find choco in PATH"
    # install choco
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    $(choco -?)
}

# func Invoke-Choco() {
#     [CmdletBinding()]
#     param (
#         [parameter()] [string]$Args
#     )
    
#     try {
#         if (-Not (Get-Command choco)) {
#             Write-LogWarn "[prepare] failed to find choco in PATH"
#             # install choco
#             Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
#             $(choco -?)
#         }
#         $CHOCO_EXEC=$(Get-Command choco)
#         Invoke-Expression -Command ($CHOCO_EXEC $Args)
#         if (-not $?) {
#             Write-LogFatal "Failed to invoke choco"
#         }
#     }
#     catch {
#         Write-LogFatal "Could not invoke choco, $($_.Exception.Message)"
#     }
# }

# check for git and install if not present
if (-Not (Get-Command git)) {
    Write-LogWarn "[prepare] failed to find git in PATH"
    choco install --limitoutput --no-progress git.install --params "'/GitAndUnixToolsOnPath /WindowsTerminal /NoAutoCrlf'" --version ${env:GIT_VERSION} -y
    refreshenv
}

# check for buildkit
if (-Not (Get-Command buildctl)) {
    Write-LogWarn "[prepare] failed to find buildkit in PATH"
    curl.exe -LO https://github.com/moby/buildkit/releases/download/v${env:BUILDKIT_VERSION}/buildkit-v${env:BUILDKIT_VERSION}.windows-amd64.tar.gz
    tar.exe xf buildkit-v${env:BUILDKIT_VERSION}.windows-amd64.tar.gz
    Move-Item -Path ./bin/*.exe -Destination $BIN
    Remove-Item -Force buildkit-v${env:BUILDKIT_VERSION}.windows-amd64.tar.gz

}

# check for nerdctl
if (-Not (Get-Command nerdctl)) {
    Write-LogWarn "[prepare] failed to find nerdctl in PATH"
    curl.exe -LO https://github.com/containerd/nerdctl/releases/download/v${env:NERDCTL_VERSION}/nerdctl-${env:NERDCTL_VERSION}-windows-amd64.tar.gz
    tar.exe xvf nerdctl-${env:NERDCTL_VERSION}-windows-amd64.tar.gz
    Move-Item -Path nerdctl.exe -Destination $BIN
    Remove-Item -Force nerdctl-${env:NERDCTL_VERSION}-windows-amd64.tar.gz
}

# check for go
if (-Not (Get-Command go)) {
    Write-LogWarn "[prepare] failed to find go in PATH"
    choco install --limitoutput --no-progress golang --version $env:GOLANG_VERSION -y
    refreshenv
}

# check for golangci-lint
if (-Not (Get-Command golangci-lint)) {
    Write-LogWarn "[prepare] failed to find golangci-lint in PATH"
}

# check for helm
if (-Not (Get-Command helm)) {
    Write-LogWarn "[prepare] failed to find helm in PATH"
    choco install --limitoutput --no-progress kubernetes-helm --version $env:HELM_VERSION -y
    refreshenv
}

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

if (-Not ("$SRC_DIR\coredns.exe")) {
    # package coredns
    curl.exe -LO https://github.com/coredns/coredns/releases/download/v${env:COREDNS_VERSION}/coredns_${env:COREDNS_VERSION}_windows_amd64.tgz
    tar xf coredns_${env:COREDNS_VERSION}_windows_amd64.tgz
    Copy-Item coredns.exe $OutDir
    Write-Host -ForegroundColor Green "staged coredns binary"
}

$ErrorActionPreference = 'Stop'

# build multi-call cni binary for containerd
if (-Not("$Env:ProgramFiles\containerd\cni\bin\cni.exe")) {
    $PKG_CNI_PLUGINS="github.com/containernetworking/plugins"

    $VERSIONFLAGS = @(
        "-X $PKG_CNI_PLUGINS/pkg/utils/buildversion.BuildVersion=$env:CNI_PLUGINS_VERSION"
        "-X $PKG_CNI_PLUGINS/plugins/meta/flannel.Program=flannel"
        "-X $PKG_CNI_PLUGINS/plugins/meta/flannel.Version=$env:FLANNEL_VERSION"
        "-X $PKG_CNI_PLUGINS/plugins/meta/flannel.Commit=$env:COMMIT"
        "-X $PKG_CNI_PLUGINS/plugins/meta/flannel.buildDate=$(Get-Date  -UFormat "+%Y-%m-%dT%H:%M:%SZ")"    
    )
    Write-Host "Building cni"
    $GO=$(Get-Command go)
    $TMPDIR=$(New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ })
    $WORKDIR="$TMPDIR/$PKG_CNI_PLUGINS"
    mkdir -force "$WORKDIR"
    git clone -b windows https://github.com/rosskirkpat/plugins.git --mirror --depth 1 $WORKDIR
    Push-Location $WORKDIR
    GO111MODULE=off GOPATH=$TMPDIR CGO_ENABLED=0 GOARCH=amd64 GOOS=windows "$GO" build -tags "$TAGS" -gcflags="all=$GCFLAGS" -ldflags "$VERSIONFLAGS $LDFLAGS $STATIC" -o "$Env:ProgramFiles\containerd\cni\bin\cni.exe"
    Pop-Location
}

function Invoke-GitClone {
    param (
        [parameter()] [string]$Repo,
        [parameter()] [string]$Version
    )
    $WORKDIR="$($env:TEMP)$(Split-Path $Repo.Replace('\','/') -NoQualifier)"
    $null = New-Item -Type Directory -Path $WORKDIR -ErrorAction Ignore

    git clone $Repo --depth 1 $WORKDIR
    Push-Location $WORKDIR
    git fetch --tags
    git checkout "v$Version"
    Pop-Location
}

# clone kubernetes
# git clone https://github.com/kubernetes/kubernetes --mirror --depth 1 -and Push-Location kubernetes -and git checkout $KubeVersion -and Pop-Location
Invoke-GitClone -Repo https://github.com/kubernetes/kubernetes -Version $env:KUBE_VERSION

# clone etcd
# git clone https://github.com/etcd-io/etcd --mirror --depth 1 -and Push-Location etcd -and git checkout $EtcdVersion -and Pop-Location
Invoke-GitClone -Repo https://github.com/etcd-io/etcd -Version $env:ETCD_VERSION
# clone coredns
# git clone https://github.com/coredns/coredns --mirror --depth 1 -and Push-Location coredns -and git checkout $CoreDNSVersion -and Pop-Location
# Invoke-GitClone -Repo https://github.com/coredns/coredns -Version $CoreDNSVersion

