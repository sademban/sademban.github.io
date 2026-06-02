---
layout: post
title: "Docker Desktop vs Docker Engine on Linux: why your volumes and containers appear in different places"
description: "A simple explanation of Docker contexts on Linux, why Docker Desktop and Docker Engine can show different containers, images, and volumes, and the commands to verify which daemon you are using."
date: 2026-06-02 09:00:00 +0900
author: sademban
categories: blog
tags:
  - docker
  - linux
  - developer-experience
image: /assets/posts/blog/2026/06/docker-desktop-vs-engine-linux-contexts/featured-image.png
image_alt: "Illustration of two Docker contexts pointing to separate container storage locations"
image_caption: "Docker Desktop and Docker Engine can point the same CLI at different daemons."
---

## 🧭 Docker Desktop vs Docker Engine on Linux

If you put Docker Desktop on a Linux computer that already has Docker Engine, you might get confused. The same `docker` command works, but your containers, images, or volumes seem to disappear.

Before you look for missing things, check which Docker daemon your command line is using.

Here's how to start:

```bash
docker context ls
```

The row with `*` is the active context. If it says `desktop-linux`, your command line is talking to Docker Desktop. If it says `default`, it is usually talking to the local Docker Engine.

## The main idea

Docker Desktop for Linux does not just reuse the Docker Engine storage you already have under the normal Linux Engine setup. Docker's own docs say Docker Desktop for Linux runs a virtual machine and uses a custom context named `desktop-linux`.

Docker Engine on Linux is the daemon you get when Docker is installed directly on a Linux server or workstation. In a local Engine setup, the `default` context points the Docker command line at the local daemon socket.

So when you switch contexts, you switch targets:

```bash
docker context use default
docker ps
docker volume ls
```

Then compare it with Docker Desktop:

```bash
docker context use desktop-linux
docker ps
docker volume ls
```

These two command sets can show different results because they are asking different daemon environments.

## Why this happens

The Docker command line is a client. It sends commands to a Docker daemon.

A Docker context stores the connection details for one daemon target. That target might be Docker Engine, Docker Desktop, or a remote host. The active context decides where normal `docker` commands go.

That means this command:

```bash
docker ps
```

does not mean "show every container on my computer." It means "show containers from the daemon my current context points to."

That distinction matters when Docker Desktop and Docker Engine are installed side by side.

## A quick diagnostic flow

Start with the context list:

```bash
docker context ls
```

Example shape:

```text
NAME              DESCRIPTION                               DOCKER ENDPOINT
default           Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
desktop-linux *   Docker Desktop                            unix:///home/<user>/.docker/desktop/docker.sock
```

The exact endpoint can vary by platform, but the important part is the context marker.

Then inspect each context:

```bash
docker context inspect default
docker context inspect desktop-linux
```

You are looking for the Docker endpoint. If the endpoints differ, your command line can talk to two daemon targets.

Next, compare resources:

```bash
docker --context default ps -a
docker --context default image ls
docker --context default volume ls
```

```bash
docker --context desktop-linux ps -a
docker --context desktop-linux image ls
docker --context desktop-linux volume ls
```

If one context shows your database volume and the other does not, the volume is not globally missing. It belongs to the daemon that created it.

## What I observed locally

I could not reproduce the Linux storage layout from this Windows environment, but I could verify the context behavior with Docker CLI 29.5.2.

The local context list showed two targets:

```text
NAME              DESCRIPTION                               DOCKER ENDPOINT
default           Current DOCKER_HOST based configuration   npipe:////./pipe/docker_engine
desktop-linux *   Docker Desktop                            npipe:////./pipe/dockerDesktopLinuxEngine
```

The active context was `desktop-linux`, so ordinary Docker commands were trying to reach Docker Desktop's daemon endpoint. Inspecting the contexts showed that `default` and `desktop-linux` had different endpoints.

That is the check: before debugging missing containers or volumes, check which daemon the command line is targeting.

## Bind mounts vs named volumes

A bind mount points a container path at a path from the host filesystem:

```bash
docker run --rm -v "$PWD:/work" alpine ls /work
```

A named volume is managed by the Docker daemon:

```bash
docker volume create demo-data
docker run --rm -v demo-data:/data alpine sh -c 'echo hello > /data/message.txt'
```

With side-by-side Docker Desktop and Docker Engine, the difference matters:

- Bind mounts are about sharing a host path into a container.
- Named volumes belong to the daemon target that created them.

So a named volume created while using `desktop-linux` should not be expected to appear when you switch to `default`, and the reverse is also true.

## Choosing the right target

Use Docker Desktop when the Desktop app is part of your workflow: GUI controls, extensions, Desktop-managed integrations, or a development setup shared with Mac and Windows users.

Use Docker Engine for Linux servers, headless environments, and setups where you want the native daemon without Docker Desktop's virtual machine boundary.

The important part is consistency. Know which daemon owns your containers, images, and volumes before you troubleshoot or delete anything.

## Commands to keep

Check the active context:

```bash
docker context ls
```

Switch to Docker Engine:

```bash
docker context use default
```

Switch to Docker Desktop:

```bash
docker context use desktop-linux
```

Run one command against a context without switching:

```bash
docker --context default ps -a
docker --context desktop-linux ps -a
```

Inspect endpoints:

```bash
docker context inspect default
docker context inspect desktop-linux
```

Check volumes per context:

```bash
docker --context default volume ls
docker --context desktop-linux volume ls
```

## Troubleshooting checklist

If containers or volumes appear to be missing:

1. Run `docker context ls`.
2. Check which context has the `*`.
3. Run `docker --context default ps -a`.
4. Run `docker --context desktop-linux ps -a`.
5. Compare `docker --context default volume ls` and `docker --context desktop-linux volume ls`.
6. If a Compose project is involved, run the same `docker compose ls` check against both contexts.
7. Avoid deleting volumes until you know which daemon owns the data.

## Evidence

This draft is based on:

- Docker Desktop for Linux install documentation: https://docs.docker.com/desktop/setup/install/linux/
- Docker context documentation: https://docs.docker.com/engine/context/working-with-contexts/
- Docker Desktop for Linux FAQ: https://docs.docker.com/desktop/faqs/linuxfaqs/
- Docker Desktop networking documentation: https://docs.docker.com/desktop/features/networking/
- Local Docker CLI checks run on 2026-06-02, with Docker CLI 29.5.2.

The local test environment was Windows, so the Linux-specific virtual machine behavior is sourced from Docker's documentation. The local commands were used to verify the general context-selection behavior.
