#Requires -Version 5.0

param (
    [CmdletBinding()]
    [parameter()] [string]$Version,
    [parameter()] [string]$Commit,
    [parameter()] [string]$OutputDir,
    # [parameter()] [string]$Org,
    [parameter()] [string]$Binary
)

$ErrorActionPreference = 'Stop'
Import-Module -WarningAction Ignore -Name "$PSScriptRoot\utils.psm1"
Invoke-Expression -Command "$PSScriptRoot\version.ps1"
$null = New-Item -Type Directory -Path $OutputDir -ErrorAction Ignore
$env:GOARCH = $env:ARCH
$env:GOOS = 'windows'
$env:CGO_ENABLED = 0
$repo = 'k8s.io/kubernetes'

function Invoke-BinaryBuild {
    param (
        [parameter()] [string]$Invocation,
        [parameter()] [string]$LinkFlags,
        [parameter()] [string]$Name
    )

    if (-Not (Get-Command go)) {
        Write-LogFatal "[build] failed to build ($Name.exe), go.exe was not found in PATH"
    }
    # $GO = $(Get-Command go)

    if ($Name.Contains('kube')) {
        Write-Host "Building $Name.exe [$env:KUBE_VERSION]"
        $tmp = ('{0}\{1}' -f ${env:TEMP} , "github.com\kubernetes\kubernetes")
        # $null = New-Item -Type Directory -Path $tmp -ErrorAction Ignore
        Push-Location $tmp
    }
   
    if ($Name.Contains('etcd')) {
        Write-Host "Building $Name.exe [$env:ETCD_VERSION]"
        $tmp = ('{0}\{1}' -f ${env:TEMP} , "github.com\etcd-io\etcd")
        # $null = New-Item -Type Directory -Path $tmp -ErrorAction Ignore
        Push-Location $tmp    
    }

    # if ($Name.Contains('dns')) {
    #     Write-Host "Building $Name.exe [$env:COREDNS_VERSION]"
    #     Push-Location coredns
    # }

    $ldFlags=' -extldflags "-static"'
    GOPATH=$tmp go build -ldflags $linkFlags$ldFlags -o "$OutputDir\$Name.exe" $Invocation
    # if (-not $?) {
    if ($LASTEXITCODE -ne 0) {
        Write-LogFatal "[build] go build failed for ($Name.exe)"
        Pop-Location
    }
    Write-Host -ForegroundColor Green "($Name.exe) has been built successfully."
    Pop-Location
}

function Invoke-EtcdBuild {
    $repo = 'go.etcd.io/etcd'
    $name = 'etcd'
    $linkFlags = ('-s -w -X {0}/version.GitSHA={0}' -f $repo, $Commit)
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "$repo" -Name $name
    $linkFlags = ('-s -w -X {0}/etcdctl/version.GitSHA={0}' -f $repo, $Commit)
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "$repo\etcdctl" -Name ('{0}ctl' -f $name)
    $linkFlags = ('-s -w -X {0}/etcdutl/version.GitSHA={0}' -f $repo, $Commit)
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "$repo\etcdutl" -Name ('{0}utl' -f $name)
}

function Invoke-KubectlBuild {
    $name = 'kubectl'
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "cmd/kubectl" -Name $name
}

function Invoke-KubeletBuild {
    $name = 'kubelet'
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "cmd/kubelet" -Name $name
}

function Invoke-KubeadmBuild {
    $name = 'kubeadm'
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "cmd/kubeadm" -Name $name
}
function Invoke-KubeProxyBuild {
    $name = 'kube-proxy'
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation 'cmd/kube-proxy' -Name $name
}

function Invoke-KubeControllerManagerBuild {
    $name = 'kube-controller-manager'
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "cmd/kube-controller-manager" -Name $name
}

function Invoke-KubeApiserverBuild {
    $name = 'kube-apiserver'
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "cmd/kube-apiserver" -Name $name
}

function Invoke-KubeSchedulerBuild {
    $name = 'kube-scheduler'
    Invoke-BinaryBuild -LinkFlags $linkFlags -Invocation "cmd/kube-scheduler" -Name $name
}

function Invoke-CoreDNSBuild {
    $repo = 'github.com/coredns/coredns'
    $name = 'coredns'
    $linkFlags = ('-s -w -X github.com/coredns/coredns/coremain.GitCommit={0}' -f $Commit)
    Invoke-BinaryBuild -LinkFlags $linkFlags -Name $name
}

# $newName = $Binary.Replace('-','')
# ('Invoke-{0}Build' -f $newName)
# $invoke = $(Invoke-$Binary.Replace('-','')Build)
# $(Invoke-$Binary.Replace('-','')Build)
# Invoke-kubeproxyBuild
# Invoke-$newName


function Invoke-Builds {
    Invoke-Expression -Command "$PSScriptRoot\prepare.ps1"

    try {
    Invoke-KubeSchedulerBuild
    Invoke-KubeApiserverBuild
    Invoke-KubeControllerManagerBuild
    Invoke-KubeProxyBuild
    Invoke-KubeadmBuild
    Invoke-KubeletBuild
    Invoke-KubectlBuild
    Invoke-EtcdBuild
    }
    catch {
        Pop-Location
    }
}

Invoke-Builds