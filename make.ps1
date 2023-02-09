<#
.SYNOPSIS 
    Builds kubeadm components from upstream kubernetes, including the controlplane.
.DESCRIPTION 
    Run the script to build kubeadm images and binaries for windows from upstream kubernetes, including the controlplane. 
.NOTES
    Environment variables:
    - CNI_PLUGINS_VERSION (default: 1.1.1)
    - FLANNEL_VERSION (default: 0.21.1)
    - CONTAINERD_VERSION (default: 1.6.16)
    - ETCD_VERSION (default: 3.5.3)
    - KUBE_VERSION (default: 1.26.1)
    - COREDNS_VERSION (default: 1.10.1)
    - BUILDKIT_VERSION (default: 0.11.2)
    - NERDCTL_VERSION (default: 1.2.0)
    - GOLANG_VERSION (default: 1.19.5)
    - HELM_VERSION (default: 3.11.1)
    - GIT_VERSION (default: 2.39.1)
.EXAMPLE 
    make.ps1 -Tag v0.0.1-alpha
#>

param (
    [CmdletBinding]
    [parameter()] [string]$Tag,
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

Import-Module -WarningAction Ignore -Name "$PSScriptRoot\utils.psm1"

#######################################
### COMMON
#######################################

$Registry = "docker.io"
$DockerOrg = "embryonik"
$GithubOrg = "embryonik-io"
$InputDir = ('C:/{0}/bin' -f $Org)

#######################################
### COMPONENTS
#######################################

$Images = @("kubelet", "kube-apiserver", "kube-scheduler", "kube-controller-manager", "kube-proxy", "etcd")
$Binaries = @("kubelet", "kube-apiserver", "kube-scheduler", "kube-controller-manager", "kube-proxy", "etcd")
$Components = @("kubelet", "kube-apiserver", "kube-scheduler", "kube-controller-manager", "kube-proxy", "etcd", "etcdctl", "etcdutl")

#######################################
### VERSIONS
#######################################

$CNI_PLUGINS_VERSION="1.1.1"
$FLANNEL_VERSION="0.21.1"
$CONTAINERD_VERSION="1.6.16"
$ETCD_VERSION="3.5.7"
$KUBE_VERSION="1.24.10"
$COREDNS_VERSION="1.10.1"
$BUILDKIT_VERSION="0.11.2"
$NERDCTL_VERSION="1.2.0"
$GOLANG_VERSION="1.19.5"
$HELM_VERSION="3.11.1"
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

function Invoke-BinaryBuilder {
param (
    [CmdletBinding]
    [parameter()] [array]$Binaries,
    [parameter()] [array]$OutputDir,
    [parameter()] [string]$Version,
    [parameter()] [string]$Org
)
    Invoke-Expression -Command "$PSScriptRoot\version.ps1"
    Write-Host "List of binaries to build ($Binaries)"
    Write-Host "App Version: $env:TAG"

    foreach ($BINARY in $Binaries) {
        try {
            Write-Host -ForegroundColor Yellow "Starting binary build of $BINARY v$Version`n"
            Invoke-Script -Path build.ps1 -Org $Org -Version $Version -Binary $BINARY -OutputDir $InputDir -Commit $env:COMMIT
        } catch {    
            Write-Host -NoNewline -ForegroundColor Red "[Error] while building binary: $BINARY: "
            Write-Host -ForegroundColor Red "$_`n"
            exit 1
        }
        Write-Host -ForegroundColor Green "Successfully built binary: $BINARY v$Version`n"
    }
}

# TODO add calico support
function Export-Binaries() {
    param (
        [parameter()] [array]$Components,
        [parameter()] [string]$OutDir,
        [parameter()] [ValidateSet("flannel")][string]$Cni = "flannel"
    )
    Invoke-Expression -Command "$PSScriptRoot\version.ps1"
    Write-Host "CNI: $Cni"
    Write-Host "App Version: $env:TAG"
 
    if ($Components.Count -eq 0) {
        Write-Host "Using Default Components List"
        $Components = @("kubelet", "kube-apiserver", "kube-scheduler", "kube-controller-manager", "kube-proxy", "etcd", "etcdctl", "etcdutl", "coredns", "cni")
    }
    Write-Host "Components: $Components"

    $null = New-Item -Type Directory -Path $OutDir -ErrorAction Ignore

    # package flannel
    if ($Cni.Equals("flannel")) {
        curl.exe -LO https://github.com/flannel-io/flannel/releases/download/v$env:FLANNEL_VERSION/flanneld.exe
        Copy-Item flanneld.exe $OutDir\
        Write-Host -ForegroundColor Green "staged flanneld binary"
        $Components += "flanneld"
    }

    # TODO handle calico
    if ($Cni.Equals("calico")) {
        Write-Host "calico is not yet supported"
        exit 1
    }

    # package coredns
    curl.exe -LO https://github.com/coredns/coredns/releases/download/v$env:COREDNS_VERSION/coredns_$env:COREDNS_VERSION_windows_amd64.tgz
    tar xz coredns_$env:COREDNS_VERSION_windows_amd64.tgz
    Copy-Item coredns.exe $OutDir\
    Write-Host -ForegroundColor Green "staged coredns binary"

    # TODO add sanitizer for $Cni input and append to $ASSETS
    Write-Host -ForegroundColor Yellow "checking for build artifacts [$Components] in $OutDir"
    foreach ($item in $Components) {
        if (-not ("$OutputDir\$item.exe")) {
            Write-Error "required build artifact is missing: $item.exe"
            throw
        }
    # if ($item.Contains('\')) {
    #     Write-Host "binary is " ($item -replace "^.*?\\")
    # }
    
    Write-Host -ForegroundColor Green "all required build artifacts are present"
    Write-Host -ForegroundColor Green "artifacts have been successfully staged in: $OutDir"
}

}
function Invoke-ImageBuilder() {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)] [array]$Images,
        [parameter(Mandatory = $false, ValueFromPipeline = $true)] [string]$InputDir,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$Version,
        [parameter(Mandatory = $false, ValueFromPipeline = $true)] [string]$Registry,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$Org
        
    )
    Invoke-Expression -Command "$PSScriptRoot\version.ps1"
    Write-Host "Images: $Images"
    Write-Host "Version: $env:TAG"

    foreach ($IMAGE in $Images) {
        try {
            if ($IMAGE == "etcd") {
                $etcd = "etcd."
            }

            $IMAGE = ('{0}/{1}:{2}-windows-{3}' -f $DockerOrg, $IMAGE, $env:TAG, $env:SERVERCORE_VERSION)
            Write-Host -ForegroundColor Yellow "Starting nerdctl build of $IMAGE`n"

            nerdctl build `
            --build-arg SERVERCORE_VERSION=$env:SERVERCORE_VERSION `
            --build-arg VERSION=$Version `
            --build-arg MAINTAINERS=$env:MAINTAINERS `
            --build-arg ORG=$DockerOrg `
            --build-arg IMAGE=$IMAGE `
            --build-arg REGISTRY=$Registry `
            -t $IMAGE `
            -f ('{0}Dockerfile' -f $etcd) .
        
        } catch {    
            Write-Host -NoNewline -ForegroundColor Red "[Error] while building image: $IMAGE\: "
            Write-Host -ForegroundColor Red "$_`n"
            $etcd=""
            exit 1
        }
        Write-Host -ForegroundColor Green "Successfully built $IMAGE`n"
    }
}

function Publish-Images {
    # TODO Implement me
}

if ($args[0] -eq "build" -or $args.Count -eq 0) {
    Write-Host "building all image and binary artifacts"
    Invoke-BinaryBuilder -Org $Org -OutputDir $InputDir -Version $Version -Binaries $Binaries
    Export-Binaries -Components $Components -OutDir $InputDir
    Invoke-ImageBuilder -Images $Images -InputDir $InputDir -Registry $Registry -Org $Org -Version $Version
}

if ($args[0] -eq "binaries") {
    Invoke-BinaryBuilder -Org $Org -OutputDir $InputDir -Version $Version -Binaries $Binaries
}

if ($args[0] -eq "package") {
    # BinaryBuilder -Org $Org -OutputDir $InputDir -Version $Version -Binaries $Binaries
    Export-Binaries -Components $Components -OutDir $InputDir
}

if ($args[0] -eq "publish") {
    Write-Host "publish is not yet implemented"
    exit 1
    # Write-Host "Building all artifacts"
    # Invoke-BinaryBuilder -Org $Org -OutputDir $InputDir -Version $Version -Binaries $Binaries
    # Export-Binaries -Components $Components -OutDir $InputDir
    # Invoke-ImageBuilder -Images $Images -InputDir $InputDir -Registry $Registry -Org $Org -Version $Version
    # Write-Host "Preparing to publish images"
    # Publish-Images -Components $Components
    # exit
}

if ($args[0] -eq "clean") {
    $confirm = Read-Host -Prompt "Are you sure you want to prune Docker images and volumes?: y/n"
    if ($confirm -eq "Y" -or $confirm -eq "y") {
        nerdctl image prune --force 
        nerdctl volume prune --force
        Write-Host -ForegroundColor Blue "Successfully pruned Docker images and volumes"
        exit
    } else {
        Write-Host -ForegroundColor Red "Will not prune Docker images and volumes, exiting now."
        exit 1
    }
}

if ($Components.Contains($($args[0]))) {
    Invoke-BinaryBuilder -Org $Org -OutputDir $InputDir -Version $Version -Binaries $args
    exit
}
