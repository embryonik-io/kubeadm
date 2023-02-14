$env:GOLANG_VERSION="1.19.5"
$env:KUBE_VERSION="1.24.10"
$GOPATH="C:\go-$env:GOLANG_VERSION"
$KUBE_GO_PACKAGE="k8s.io/kubernetes"
$GO_PACKAGE_DIR="$GOPATH\src\$KUBE_GO_PACKAGE"
$null = New-Item -Type Directory -Path $GOPATH -ErrorAction Ignore
$env:PATH += ";$BIN;$Env:ProgramFiles\containerd;$Env:ProgramFiles\containerd\cni\bin;C:\ProgramData\chocolatey\bin;$Env:ProgramFiles\Git\bin;$Env:ProgramFiles\Go\bin;${GOPATH}/bin"
go env -w GOPATH $GOPATH
$null = New-Item -Type Directory -Path $GOPATH\src\kubernetes -ErrorAction Ignore
git clone -b "v$env:KUBE_VERSION" --depth=1 https://github.com/kubernetes/kubernetes.git $GOPATH\src\kubernetes
Set-Location -Path $GOPATH\src\kubernetes

$GIT_COMMIT=$(git rev-parse HEAD)
$BUILD_DATE=$(Get-Date  -UFormat "+%Y-%m-%dT%H:%M:%SZ") 
$GO_LDFLAGS="-gcflags=-trimpath=/go-$env:GOLANG_VERSION/src/kubernetes -mod=vendor -tags=osusergo,netcgo,static_build"
$LDFLAGS='-linkmode=external -extldflags \"-static -Wl,--fatal-warnings\"'
$MAJOR='1'
$MINOR='26'
$KUBERNETES_VERSION='v1.26.1'
$linkFlags=('-linkmode=external' +
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

# $GO111MODULE='off'
# $GO15VENDOREXPERIMENT=1
$GOROOT=$(go env GOROOT)
# cgo requirements
$env:CXX = 'x86_64-w64-mingw32-g++'
$env:CC = 'x86_64-w64-mingw32-gcc'
$env:GOARCH = $env:ARCH
$env:GOOS = 'windows'
$env:CGO_ENABLED = 1
$env:GO111MODULE='on'
# wsl - generate
# KUBE_BUILD_PLATFORMS=windows/amd64 make WHAT=cmd/kube-apiserver
# ('{0} {1} {2}' -f
go build -v -x -ldflags $LDFLAGS$linkFlags"$GO_LDFLAGS" -o $GOPATH/bin/kubeadm.exe ./cmd/kubeadm


# CGO requirements

$env:CXX = 'x86_64-w64-mingw32-g++'
$env:CC = 'x86_64-w64-mingw32-gcc'
$env:GOARCH = $env:ARCH
$env:GOOS = 'windows'
$env:CGO_ENABLED = 1


Get-Command -ErrorAction Ignore -Name @("x86_64-w64-mingw32-gcc.exe", "x86_64-w64-mingw32-g++.exe") | Out-Null
if (-not $?) {
    Write-LogInfo "Installing gcc"
    New-Item -Type Directory -Path C:\llvm-mingw64 -Force -ErrorAction Ignore | Out-Null

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -uri "https://github.com/mstorsjo/llvm-mingw/releases/download/20220906/llvm-mingw-20220906-msvcrt-x86_64.zip" -OutFile mingw.zip
    Expand-Archive -Force -Path mingw.zip -DestinationPath C:\llvm-mingw64

    Write-LogInfo 'Updating PATH ...'
    [Environment]::SetEnvironmentVariable('PATH', ('C:\llvm-mingw64\llvm-mingw-20220906-msvcrt-x86_64\bin\;C:\llvm-mingw64\llvm-mingw-20220906-msvcrt-x86_64\x86_64-w64-mingw32\bin\;{0}' -f $env:PATH), [EnvironmentVariableTarget]::Machine)
    $env:PATH = ('C:\llvm-mingw64\llvm-mingw-20220906-msvcrt-x86_64\bin\;C:\llvm-mingw64\llvm-mingw-20220906-msvcrt-x86_64\x86_64-w64-mingw32\bin\;{0}' -f $env:PATH)

    Write-LogInfo 'Finished installing gcc.'
}
