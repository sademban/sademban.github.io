# Reclaim Docker Desktop WSL 2 VHDX space on Windows

## Sources

- Microsoft WSL disk-space documentation: https://learn.microsoft.com/en-us/windows/wsl/disk-space
- Microsoft WSL advanced configuration documentation: https://learn.microsoft.com/en-us/windows/wsl/wsl-config
- Microsoft WSL 2.5.6 release notes: https://github.com/microsoft/WSL/releases/tag/2.5.6
- Microsoft DiskPart `compact vdisk` documentation: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/compact-vdisk
- Microsoft `Optimize-VHD` documentation: https://learn.microsoft.com/en-us/powershell/module/hyper-v/optimize-vhd
- Current WSL source for sparse-VHD creation: https://github.com/microsoft/WSL/blob/master/src/windows/common/WslCoreFilesystem.cpp
- Current WSL client source for `wsl --manage <Distro> --compact`: https://github.com/microsoft/WSL/blob/master/src/windows/common/WslClient.cpp
- Docker Desktop WSL 2 backend documentation: https://docs.docker.com/desktop/features/wsl/
- Docker Desktop backup and restore documentation: https://docs.docker.com/desktop/settings-and-maintenance/backup-and-restore/
- Docker Desktop settings documentation: https://docs.docker.com/desktop/settings-and-maintenance/settings/
- Docker `system prune` reference: https://docs.docker.com/reference/cli/docker/system/prune/
- Docker `buildx prune` reference: https://docs.docker.com/reference/cli/docker/buildx/prune/

Research notes:

- WSL 2 and Docker Desktop use dynamically expanding VHDX files. Deleting guest data can make blocks free inside Linux without immediately reducing a non-sparse VHDX file on the Windows host.
- The WSL `.wslconfig` documentation describes `sparseVhd=true` as applying automatically to newly created VHDs. It is not a retroactive compaction command.
- WSL 2.5.6, released as a pre-release on 2025-04-08, put sparse-VHD support behind the `--allow-unsafe` flag. This is the release boundary for the supported sparse auto-reclaim behavior; ordinary non-sparse dynamic VHDX files still require compaction.
- Current Microsoft WSL source disables sparse-VHD creation while potential data corruption is being investigated. The unsafe override is therefore not recommended as a recovery step.
- Current WSL client source and the locally installed `wsl --help` expose `wsl --manage <Distro> --compact` for registered WSL 2 distributions.
- Docker Desktop's WSL 2 engine data is stored under `C:\Users\[USERNAME]\AppData\Local\Docker\wsl` by default. Current Docker backup documentation names the WSL 2 data disk as `%LOCALAPPDATA%\Docker\wsl\disk\docker_data.vhdx`.
- Docker Desktop can use a custom disk image location, so readers must verify Settings > Resources > Advanced before selecting a VHDX.
- Docker Desktop Resource Saver reduces CPU and memory use by stopping the idle VM. It is not documented as VHDX disk compaction.
- Docker documents `docker system df -v` for inspection and `docker system prune` for unused data. Volumes are deliberately excluded by default because they can contain important data.
- Microsoft documents `compact vdisk` as reducing the physical size of a dynamically expanding VHD. The VHD must be detached or attached read-only.
- `Optimize-VHD` is an optional Hyper-V PowerShell cmdlet and was not available in this local shell. DiskPart is the more broadly available fallback here.

## Local Evidence

Demo environment:

- OS: Windows build `10.0.26300.9711`
- WSL: `3.0.3.0`
- WSL kernel: `6.18.54.1-1`
- Docker CLI: `29.8.2`
- Date tested: 2026-10-16

Commands run:

```powershell
wsl.exe --version
wsl.exe --status
wsl.exe --list --verbose
wsl.exe --help
docker version
docker system df
Get-Command Optimize-VHD -ErrorAction SilentlyContinue
Get-Command diskpart.exe
```

Observed output:

```text
WSL version: 3.0.3.0
Kernel version: 6.18.54.1-1
Windows version: 10.0.26300.9711
```

The local WSL help included:

```text
--manage <Distro> <Options...>
    --set-sparse, -s <true|false>
    --resize <MemoryString>
    --compact
        Compact the VHDX file of a WSL 2 distribution.
```

Docker CLI output included:

```text
Client:
 Version:           29.8.2
 OS/Arch:           windows/amd64
 Context:           default
```

What worked:

- WSL and Docker CLI versions were collected.
- The installed WSL help verified that the current client supports the `--compact` command.
- `diskpart.exe` is installed.

What failed or needed adjustment:

- `wsl --status` and `wsl --list --verbose` returned `Wsl/EnumerateDistros/Service/E_ACCESSDENIED` in this managed session.
- Docker daemon commands could not access the named pipe, so `docker system df` did not return engine usage.
- `Optimize-VHD` was not available in this shell.
- No Docker data was deleted and no VHDX was compacted. There is no invented before/after space measurement.

Verification step for a reader:

- Check Windows free space and the VHDX file's Properties before cleanup.
- Run `docker system df -v` before and after deleting only confirmed-unused data.
- Quit Docker Desktop, shut down WSL, compact the correct VHDX, then compare Windows free space and the file's Size on disk.
- Restart Docker Desktop and verify required containers and named volumes still work.

## Practical Takeaway

Readers should first identify whether the space belongs to a normal registered WSL distribution or Docker Desktop's separate engine data disk. They should clean unused Docker data, back up anything important, fully stop Docker Desktop and WSL, then use the built-in WSL `--compact` command for a registered distro or DiskPart for Docker Desktop's detached `docker_data.vhdx`.

The recovery sequence matters: cleanup makes guest blocks free; compaction returns those free blocks to Windows. Compaction cannot reclaim blocks that still contain Docker images, build cache, containers, or volumes.

## Image Plan

Image type:

- [x] Generated featured image
- [ ] Real screenshot/demo image
- [ ] No image needed

Decision:

- Generated a hand-drawn explainer showing Docker inside WSL 2 on Windows, the WSL 2.5.6 sparse-VHD safety gate, a growing `docker_data.vhdx`, and the safe cleanup/shutdown/compaction sequence.
- Asset: `/assets/posts/blog/2026/10/reclaim-docker-desktop-wsl2-vhdx-space/featured-image.png`
- Alt: "Hand-drawn diagram of Docker running inside WSL 2 on Windows, a growing docker_data.vhdx, sparse auto-shrink disabled in WSL 2.5.6, and the clean, shut down, compact recovery sequence"
- Caption: "Since WSL 2.5.6 gated sparse VHD support, reclaiming Docker Desktop space is a two-stage job: clean unused Docker data, then compact the stopped VHDX."
- This is an explanatory illustration, not a measured before/after result.

## Security Review

- [x] No API keys, tokens, passwords, private keys, cookies, or auth headers.
- [x] No private customer data or internal-only infrastructure details.
- [x] Local usernames and full user-profile paths are not included.
- [x] No destructive command is presented without a warning and backup step.
