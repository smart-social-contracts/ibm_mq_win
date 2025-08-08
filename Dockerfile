# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2016

SHELL ["powershell", "-Command"]

WORKDIR C:\\

COPY mqredist.zip C:\\mqredist.zip

RUN Expand-Archive -Path C:\\mqredist.zip -DestinationPath C:\\ibmmq -Force ; `
    Remove-Item C:\\mqredist.zip -Force

ENV PATH="C:\\ibmmq\\bin64;C:\\ibmmq\\bin;%PATH%"

# COPY scripts into container for smoke testing
COPY scripts C:\\scripts

# Optional: Install VC++ runtime if needed
# ADD VC_redist.x64.exe C:\\VC_redist.x64.exe
# RUN Start-Process -FilePath C:\\VC_redist.x64.exe -ArgumentList '/quiet', '/norestart' -Wait ; `
#     Remove-Item C:\\VC_redist.x64.exe -Force

CMD ["cmd.exe"]
