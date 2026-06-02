# Docker Desktop vs Docker Engine on Linux contexts

## Sources

- Docker Desktop for Linux install docs: https://docs.docker.com/desktop/setup/install/linux/
- Docker contexts docs: https://docs.docker.com/engine/context/working-with-contexts/
- Docker Desktop for Linux FAQ: https://docs.docker.com/desktop/faqs/linuxfaqs/
- Docker Desktop networking docs: https://docs.docker.com/desktop/features/networking/

Research notes:

- Docker's Linux Desktop install page states that Docker Desktop for Linux runs a VM and creates/uses a custom `desktop-linux` Docker context on startup.
- The same page explains that images and containers from the regular Linux Docker Engine are not automatically visible inside Docker Desktop for Linux.
- Docker's context docs explain that the active context controls which daemon a Docker CLI command targets, unless overridden by `DOCKER_HOST`, `DOCKER_CONTEXT`, `--context`, or `--host`.
- Docker Desktop docs say Desktop runs Docker Engine inside a lightweight Linux VM.
- Docker's Linux FAQ says Docker Desktop for Linux uses VirtioFS for sharing host directories into the VM.

## Local Evidence

Demo environment:

- OS: Windows host, PowerShell shell. This is not a Linux-host demo, but it demonstrates the same context-selection behavior in Docker Desktop.
- Docker CLI version: 29.5.2
- Docker Compose plugin version: v5.1.4
- Date tested: 2026-06-02

Commands run:

```powershell
docker context ls
docker version
docker info
docker context inspect desktop-linux
docker context inspect default
docker --context default version
```

Observed output:

```text
docker context ls

NAME              DESCRIPTION                               DOCKER ENDPOINT                             ERROR
default           Current DOCKER_HOST based configuration   npipe:////./pipe/docker_engine
desktop-linux *   Docker Desktop                            npipe:////./pipe/dockerDesktopLinuxEngine
```

```text
docker version

Client:
 Version:           29.5.2
 API version:       1.54
 OS/Arch:           windows/amd64
 Context:           desktop-linux

permission denied while trying to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine
```

```text
docker context inspect desktop-linux

"Name": "desktop-linux"
"Description": "Docker Desktop"
"Host": "npipe:////./pipe/dockerDesktopLinuxEngine"
```

```text
docker context inspect default

"Name": "default"
"Host": "npipe:////./pipe/docker_engine"
```

What worked:

- `docker context ls` and `docker context inspect` worked without daemon access.
- The local CLI clearly showed that `desktop-linux` and `default` are separate targets.

What failed or needed adjustment:

- Daemon commands such as `docker version` and `docker info` could not connect because this session did not have permission to access the Docker Desktop pipe.
- Because the local machine is Windows, Linux-specific VM/storage behavior is based on Docker's official docs, not a local Linux reproduction.

Verification step:

- Command/check: `docker context ls`
- Expected result: active context is marked with `*`.
- Observed result: `desktop-linux *` was active, so normal `docker` commands would target Docker Desktop's daemon endpoint.

## Practical Takeaway

If a container, image, or volume is visible in one Docker setup but missing in another, first check the active context. On Linux, Docker Desktop and Docker Engine can both exist, but they are separate daemon targets. Switching contexts changes which daemon the CLI talks to, so the visible containers, images, and volumes can change.

## Image Plan

Image type:

- [x] Generated featured image
- [ ] Real screenshot/demo image
- [ ] No image needed

Prompt or screenshot plan:

- Original technical illustration showing one Docker CLI splitting into two labeled paths: `default` / Docker Engine and `desktop-linux` / Docker Desktop VM. No logos, no fake terminal output, no tiny text beyond the two context labels if possible.

Asset path:

- `assets/posts/blog/2026/06/docker-desktop-vs-engine-linux-contexts/featured-image.png`

Alt text:

- Illustration of two Docker contexts pointing to separate container storage locations.

Caption:

- Docker Desktop and Docker Engine can point the same CLI at different daemons.

## Security Review

- [x] No API keys, tokens, passwords, private keys, cookies, or auth headers.
- [x] No private customer data or internal-only infrastructure details.
- [x] Logs, screenshots, and copied outputs are redacted.

