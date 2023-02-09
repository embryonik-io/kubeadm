#Requires -Version 5.0

$ErrorActionPreference = 'Stop'

Import-Module -WarningAction Ignore -Name "$PSScriptRoot\utils.psm1"
Invoke-Script -File "$PSScriptRoot\version.ps1"

$BIN = "\usr\local\bin"
mkdir -force $BIN

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
    choco install --limitoutput --no-progress git.install --params "'/GitAndUnixToolsOnPath /WindowsTerminal /NoAutoCrlf'" --version 2.39.1 -y
    refreshenv
}

# check for buildkit
if (-Not (Get-Command buildkit)) {
    Write-LogWarn "[prepare] failed to find buildkit in PATH"
    curl.exe -LO https://github.com/moby/buildkit/releases/download/v0.11.2/buildkit-v0.11.2.windows-amd64.tar.gz
    tar.exe xvf buildkit-v0.11.2.windows-amd64.tar.gz
    mv ./bin/* $BIN
    Remove-Item -Force buildkit-v0.11.2.windows-amd64.tar.gz

}

# check for nerdctl
if (-Not (Get-Command nerdctl)) {
    Write-LogWarn "[prepare] failed to find nerdctl in PATH"
    curl.exe -LO https://github.com/containerd/nerdctl/releases/download/v1.2.0/nerdctl-1.2.0-windows-amd64.tar.gz
    tar.exe xvf nerdctl-1.2.0-windows-amd64.tar.gz
    mv nerdctl.exe $BIN
    Remove-Item -Force nerdctl-1.2.0-windows-amd64.tar.gz
}

# check for containerd
if (-Not (Get-Command containerd)) {
    Write-LogWarn "[prepare] failed to find containerd in PATH"
}

# check for go
if (-Not (Get-Command go)) {
    Write-LogWarn "[prepare] failed to find go in PATH"
    choco install --limitoutput --no-progress golang --version 1.19.5 -y
    refreshenv
}

# check for golangci-lint
if (-Not (Get-Command golangci-lint)) {
    Write-LogWarn "[prepare] failed to find golangci-lint in PATH"
}

# check for helm
if (-Not (Get-Command helm)) {
    Write-LogWarn "[prepare] failed to find helm in PATH"
    choco install --limitoutput --no-progress kubernetes-helm --version 3.11.1 -y
    refreshenv
}

# check for containerd
if (-Not (Get-Command containerd)) {
    Write-LogWarn "[prepare] failed to find containerd in PATH"
    $version=$env:CONTAINERD_VERSION
    echo "Installing containerd $version"
    curl.exe -L "https://github.com/containerd/containerd/releases/download/v$version/containerd-$version-windows-amd64.tar.gz" -o containerd-windows-amd64.tar.gz
    tar.exe xvf containerd-windows-amd64.tar.gz
    mkdir -force "$Env:ProgramFiles\containerd"
    mkdir -force "$Env:ProgramFiles\containerd\cni\bin"
    mkdir -force "$Env:ProgramFiles\containerd\cni\conf"
    mv ./bin/* "$Env:ProgramFiles\containerd"
    Remove-Item -Force containerd-windows-amd64.tar.gz
}

if (-Not (Get-Service containerd)) {
    # Register containerd service and start it
    & $Env:ProgramFiles\containerd\containerd.exe config default | Out-File "$Env:ProgramFiles\containerd\config.toml" -Encoding ascii
    & $Env:ProgramFiles\containerd\containerd.exe --register-service
    Start-Service containerd
}

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
    $TMPDIR=$(New-TemporaryFile | % { Remove-Item $_; New-Item -ItemType Directory -Path $_ })
    $WORKDIR="$TMPDIR/$PKG_CNI_PLUGINS"
    mkdir -force $WORKDIR
    git clone -b windows https://github.com/rosskirkpat/plugins.git --mirror --depth 1 $WORKDIR
    Push-Location $WORKDIR
    GO111MODULE=off GOPATH=$TMPDIR CGO_ENABLED=0 GOARCH=amd64 GOOS=windows "$GO" build -tags "$TAGS" -gcflags="all=$GCFLAGS" -ldflags "$VERSIONFLAGS $LDFLAGS $STATIC" -o "$Env:ProgramFiles\containerd\cni\bin\cni.exe"
    Pop-Location
}

function Invoke-Git-Clone {
    param (
        [parameter()] [string]$Repo,
        [parameter()] [string]$Version
    )
    git clone $Repo --mirror --depth 1
    Push-Location $(Split-Path $Repo -Leaf)
    git checkout $Version
    Pop-Location
}

# clone kubernetes
# git clone https://github.com/kubernetes/kubernetes --mirror --depth 1 -and Push-Location kubernetes -and git checkout $KubeVersion -and Pop-Location
Invoke-Git-Clone -Repo https://github.com/kubernetes/kubernetes -Version $KubeVersion

# clone etcd
# git clone https://github.com/etcd-io/etcd --mirror --depth 1 -and Push-Location etcd -and git checkout $EtcdVersion -and Pop-Location
Invoke-Git-Clone -Repo https://github.com/etcd-io/etcd -Version $EtcdVersion
# clone coredns
# git clone https://github.com/coredns/coredns --mirror --depth 1 -and Push-Location coredns -and git checkout $CoreDNSVersion -and Pop-Location
Invoke-Git-Clone -Repo https://github.com/coredns/coredns -Version $CoreDNSVersion

