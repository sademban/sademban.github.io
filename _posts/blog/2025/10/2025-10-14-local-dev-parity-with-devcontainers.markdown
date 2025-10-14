---
layout: post
title: "Local dev parity with devcontainers — fast feedback without the friction"
date: 2025-10-14 00:00:00 +0000
categories: blog
tags: [devcontainers, docker, developer-experience, productivity]
description: "Practical guide to using VS Code Dev Containers and docker-compose for reliable, fast local dev parity. Includes devcontainer.json, Dockerfile and docker-compose examples."

image: /assets/posts/blog/2025/10/dev-container-pairty/local-dev-parity.png
image_alt: "doodle image showing local dev-container parity"
image_caption: "local and dev-container parity with fast feedback without friction"
---
## 🟦 Local dev parity with devcontainers — fast feedback without the friction

TL;DR: Use a lightweight devcontainer that mirrors your production runtime for services, but keeps the feedback loop fast with layered Dockerfiles, cached volumes, and local compose helpers. This post shows a minimal `devcontainer.json`, a recommended `Dockerfile`, and a `docker-compose` snippet that keeps editing fast while matching production behavior.

## Why this matters ?

Local development that behaves like production reduces surprising bugs, speeds onboarding, and makes CI results more predictable. Historically, achieving parity required heavy VM setups or brittle developer scripts. `devcontainer` (VS Code Remote - Containers) + `docker-compose` strikes a good balance: sandboxed, reproducible, and fast when configured correctly.

## What we'll cover ?

- Minimal `devcontainer.json` suitable for most web apps.
- A layered `Dockerfile` pattern for fast rebuilds.
- `docker-compose` helpers to run databases and background services during development.
- Tips for fast feedback: cached mounts, incremental builds, and IDE tasks.

## Minimal examples

1. devcontainer.json

This is the entrypoint for VS Code. It installs the dev image, maps your sources, and runs optional container commands.

```json
{
  "name": "MyApp Dev",
  "build": {
    "dockerfile": "Dockerfile",
    "context": ".."
  },
  "runArgs": [
    "--init",
    "--cap-add=SYS_PTRACE"
  ],
  "workspaceFolder": "/workspace",
  "settings": {
    "terminal.integrated.shell.linux": "/bin/bash"
  },
  "extensions": [
    "ms-vscode-remote.remote-containers",
    "ms-azuretools.vscode-docker"
  ],
  "forwardPorts": [3000, 9229],
  "mounts": [
    "source=${localWorkspaceFolder}/.cache,target=/workspace/.cache,type=bind,consistency=cached"
  ],
  "postCreateCommand": "./scripts/setup-dev.sh || true",
  "remoteUser": "vscode"
}
```

1. Dockerfile (layered for fast rebuilds)

Use a two-stage/layered approach: dependencies first, app code later. This keeps the often-changing source files off the dependency-install layers.

```Dockerfile
FROM node:20-alpine AS base
WORKDIR /workspace

# Install build deps (cached unless package.json changes)
FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci --silent

FROM deps AS dev
COPY . .
RUN addgroup -S vscode && adduser -S vscode -G vscode
USER vscode
ENV NODE_ENV=development
CMD ["npm", "run", "dev"]
```

1. docker-compose.dev.yml

Run external services (db, redis) alongside the devcontainer. Use named volumes for persistent caches and bind-mount the source for live reload.

```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - .:/workspace:cached
      - /workspace/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: myapp_dev
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

## Practical tips for speed and parity

- Use cached bind mounts where possible (Docker Desktop and newer engines support `:cached`/`:delegated`). This keeps reads fast while still letting you edit files locally.
- Install dependencies in a separate layer. Rebuilds after code edits will reuse the dependency image and be much quicker.
- Use small base images (e.g., alpine) for faster pulls. For native builds, add only needed build tools in a separate stage.
- Avoid running heavy startup tasks in `postCreateCommand`. Use an idempotent `scripts/setup-dev.sh` that can be run manually.
- For compiled languages, keep a local build cache on a named volume so rebuilds reuse artifacts.

## VS Code tasks and launch

Add tasks that call `docker-compose -f docker-compose.dev.yml up --build app` for a single-command start, and a `docker-compose exec app` task for running tests.

Example tasks.json snippet:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Dev: Up",
      "type": "shell",
      "command": "docker-compose -f docker-compose.dev.yml up --build",
      "isBackground": true,
      "problemMatcher": []
    }
  ]
}
```

## Common pitfalls

- Double-binding node_modules: prefer anonymous volumes or container-owned node_modules to avoid platform incompatibilities.
- Forgetting to add `--init` or `--cap-add=SYS_PTRACE` when you need debuggers.
- Trying to replicate production exactly (same cloud services) — prefer lightweight duplicates (e.g., local Postgres image) for dev and rely on integration tests in CI for full production parity.

## When to use Dev Containers vs local install

Use devcontainers when:

- You want reproducible onboarding for new developers.
- The runtime requires many native dependencies or specific tooling versions.

Use local installs when:

- You need extreme iteration speed (small scripts and fast local tooling).
- The project is small and contributors are comfortable managing local dependencies.

## Wrap-up and checklist

- [ ] Add `devcontainer.json` and a script to seed the DB for first-run.
- [ ] Add IDE tasks for `docker-compose` start/stop and test runs.
- [ ] Document how to run tests and where volumes live in `CONTRIBUTING.md`.

## Further reading

- [VS Code Remote - Containers](https://code.visualstudio.com/docs/remote/containers)
- [Docker Compose docs](https://docs.docker.com/compose/)
