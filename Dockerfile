ARG SERVERCORE_VERSION
ARG BINARY
ARG REGISTRY
ARG VERSION
ARG MAINTAINERS
ARG REPO
ARG VENDOR

# FROM mcr.microsoft.com/windows/nanoserver:${SERVERCORE_VERSION}
FROM mcr.microsoft.com/windows/servercore:${SERVERCORE_VERSION}
SHELL ["powershell", "-NoLogo", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
USER ContainerAdministrator

ENV VERSION ${VERSION}
ENV MAINTAINERS ${MAINTAINERS}
ENV REPO ${REPO}
ENV REGISTRY ${REGISTRY}
ENV VENDOR ${VENDOR}
# PATH isn't actually set in the Docker image, so we have to set it from within the container
#RUN $newPath =  ('C:/usr/local/bin/;{0}' -f $env:PATH); \
#    Write-Host ('Updating PATH: {0}' -f $newPath); \
#    Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine); \
    # New-Item -ItemType SymbolicLink -Target "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Path "C:\Windows\System32\WindowsPowerShell\v1.0\pwsh.exe" 

# RUN New-Item -Type Directory -Path "C:/usr/local/bin" -Force
WORKDIR "C:/usr/local/bin"

ENV PATH="C:\\usr\\local\\bin;C:\\Windows\\system32;C:\\Windows;"

COPY ${BINARY} C:/usr/local/bin/${BINARY}

LABEL org.opencontainers.image.authors=${MAINTAINERS}
LABEL org.opencontainers.image.url=${REPO}
LABEL org.opencontainers.image.documentation=${REPO}
LABEL org.opencontainers.image.source=${REPO}
LABEL org.label-schema.vcs-url=${REPO}
LABEL org.opencontainers.image.vendor=${VENDOR}
LABEL org.opencontainers.image.version=${VERSION}

USER ContainerUser

# ENTRYPOINT ["PowerShell"]

ENTRYPOINT ["${BINARY}"]