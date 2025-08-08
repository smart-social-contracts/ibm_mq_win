Windows Server 2016–compatible Dockerized IBM MQ 9.2 Client

Overview
- Windows container image including IBM MQ 9.2 Redistributable Client (Win64)
- Base image: mcr.microsoft.com/windows/servercore:ltsc2016
- Installs to C:\ibmmq and exposes amqsputc.exe / amqsgetc.exe on PATH
- Docker Compose service mqclient with optional Hyper-V isolation
- CI via self-hosted GitHub Actions Windows runner (intermittently online)

Repo layout
- /Dockerfile
- /docker-compose.yml
- /.github/workflows/build.yml
- /scripts/ensure-windows-containers.ps1
- /scripts/stage-mqredist.ps1
- /scripts/smoke-test.ps1
- /README.md
- /.gitignore
- /.env.example

Hard requirements satisfied
- Base image: mcr.microsoft.com/windows/servercore:ltsc2016
- MQ version: 9.2 redist ZIP (Win64). No MSI installers.
- Installs to C:\ibmmq; PATH includes C:\ibmmq\bin64;C:\ibmmq\bin
- Tools exposed: amqsputc.exe, amqsgetc.exe
- No Linux containers anywhere
- The proprietary ZIP is not committed or downloaded; it’s staged locally on the runner.

Prerequisites
- Windows Server 2016 or Windows 10+ with Docker Desktop (Windows containers)
- Docker configured for Windows containers
- Self-hosted GitHub Actions runner installed as a service with labels:
  - self-hosted, windows, windows-containers, ltsc2016

Staging the IBM MQ redist ZIP
- Place the IBM MQ 9.2 redist ZIP at:
  C:\_thirdparty\ibm\mq\9.2\mqredist.zip
- Or provide a custom path when invoking the staging script:
  .\scripts\stage-mqredist.ps1 -SourceZip "D:\path\to\mqredist.zip"

Local development (no CI)
1) Switch Docker to Windows-containers mode:
   .\scripts\ensure-windows-containers.ps1

2) Stage the MQ redist ZIP into the repo root:
   .\scripts\stage-mqredist.ps1
   # or: .\scripts\stage-mqredist.ps1 -SourceZip "D:\path\mqredist.zip"

3) Build and run with docker compose:
   docker compose up -d --build

4) Get an interactive shell:
   docker exec -it mqclient cmd

Environment configuration
- Defaults (override via .env or environment):
  - MQSERVER=DEV.APP.SVRCONN/TCP/host.docker.internal(1414)
  - MQSAMP_USER_ID=app
  - MQSAMP_USER_PWD=appPassw0rd!
- Copy .env.example to .env and adjust for your environment:
  copy .env.example .env

Smoke testing inside the container
- Put a message:
  amqsputc DEV.QUEUE.1 QM1
  hello from local
  Press Ctrl+Z then Enter

- Get a message:
  amqsgetc DEV.QUEUE.1 QM1

CI with a self-hosted Windows runner
- Jobs target labels: self-hosted, windows, windows-containers, ltsc2016
- Runner should be installed as a service to auto-start
- Jobs will queue when the runner is offline
- Concurrency prevents stacked builds per branch
- Manual trigger available via workflow_dispatch, with overridable MQ env vars

Workflow outline (.github/workflows/build.yml)
- Ensure Docker Windows-containers mode
- Stage mqredist.zip into workspace (no internet fetch, not in repo)
- Build image from servercore:ltsc2016 and MQ redist ZIP
- docker compose up -d
- Smoke test with amqsputc/amqsgetc inside the container
- On failure, gather logs as artifacts
- docker compose down

Compose notes
- Service name: mqclient (container_name is mqclient)
- isolation: hyperv recommended, especially when host Windows build differs slightly
- stdin_open and tty enabled for interactive use
- Only Windows containers are used (no Linux)

Optional safeguards
- .env.example provided
- Preflight network check script:
  - powershell -File .\scripts\preflight-check.ps1 -MqServerEnv "$Env:MQSERVER"
  - Non-blocking: warns clearly if the MQ host:port is unreachable from the runner.
- Debug compose profile:
  - docker compose --profile debug up -d mqclient-debug
  - This starts a container with command: cmd /k for interactive troubleshooting.

Troubleshooting
- If amqs* tools are not found, verify C:\ibmmq\bin64 and C:\ibmmq\bin are on PATH
- If connection fails, verify MQSERVER host/port and any required credentials
- If your app requires MSVC++ runtime, uncomment the VC_redist steps in Dockerfile and provide the redistributable in the build context
