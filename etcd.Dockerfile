ARG SERVERCORE_VERSION

FROM mcr.microsoft.com/windows/servercore:${SERVERCORE_VERSION}
SHELL ["powershell", "-NoLogo", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PATH isn't actually set in the Docker image, so we have to set it from within the container
#RUN $newPath =  ('C:/usr/local/bin/;{0}' -f $env:PATH); \
#    Write-Host ('Updating PATH: {0}' -f $newPath); \
#    Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);

RUN New-Item -Type Directory -Path "C:/usr/local/bin" -Force ; \
    New-Item -Type Directory -Path "C:/var/etcd" -Force ; \
    New-Item -Type Directory -Path "C:/var/lib/etcd" -Force ; \
    New-Item -Type Directory -Path "C:/etc" -Force ; \
    Set-Content -Path "C:/etc/nsswitch.conf" -Value "hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4"

ADD etcd C:/usr/local/bin/
ADD etcdctl C:/usr/local/bin/
ADD etcdutl C:/usr/local/bin/

#EXPOSE 2379 2380
EXPOSE 2379 2380 4001 7001

ENV PATH="C:\\usr\\local\\bin;C:\\Windows\\system32;C:\\Windows;"

WORKDIR "C:/usr/local/bin"
ENTRYPOINT ["etcd"]