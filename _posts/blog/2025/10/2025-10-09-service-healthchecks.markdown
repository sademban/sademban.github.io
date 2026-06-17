---
layout: post
title: "Service health checks: official status pages and curl checks"
description: "A compact reference of status pages and quick healthcheck commands for popular services (GitHub, AWS, Azure, Bitbucket, Cloudflare, Netlify, and more)."
date: 2025-10-09 10:00:00 +0900
author: sademban
categories: blog
tags:
  - ops
  - monitoring
  - status
  - reliability
image: /assets/posts/blog/2025/10/service-health-check/featured-image.png
image_alt: "doodle image showing service health check"
image_caption: "Before You Get Frustrated: Quick Healthchecks for Common Services"
---

## Service health checks: official status pages and curl checks

When something breaks in a stack, the first question is usually "what changed?" Sometimes the answer is local: a deploy, a DNS change, a bad secret, or a failed migration. Sometimes the answer is upstream: a partial outage in GitHub, AWS, Cloudflare, npm, or another service the app depends on.

This is a short reference for that second case: official status pages, programmatic status endpoints where they exist, and small `curl` checks that are useful during triage.

Tip: many services host their status pages on Statuspage.io and expose a small JSON API at `/api/v2/status.json` or `/api/v2/summary.json`. If the status page looks healthy but your app is affected, check the provider's API and region-specific dashboards.

## How to use this guide

- Use the status page for human-facing updates and historical incidents.
- Use the API or `/api` endpoints for automation (monitoring, alerts, incident correlation).
- If a provider uses a managed CMP or feature flag, check their control plane (e.g., AWS Service Health Dashboard, Azure Service Health) for region-specific notices.
- Example curl patterns below assume `jq` is available for pretty JSON parsing. If you don't have `jq`, add it or just inspect plain output.

---

## Repositories & Source Control

- GitHub
  - Status page: [https://www.githubstatus.com/](https://www.githubstatus.com/)
  - API (Statuspage): [https://www.githubstatus.com/api/v2/status.json](https://www.githubstatus.com/api/v2/status.json)
  - Quick check:

    ```zsh
    curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.description'
    ```

- GitLab
  - Status page: [https://status.gitlab.com/](https://status.gitlab.com/)
  - API: [https://status.gitlab.com/api/v2/status.json](https://status.gitlab.com/api/v2/status.json)
  - Quick check:

    ```zsh
    curl -s https://status.gitlab.com/api/v2/status.json | jq -r '.status.description'
    ```

- Bitbucket / Atlassian
  - Status page: [https://bitbucket.status.atlassian.com/](https://bitbucket.status.atlassian.com/)
  - Atlassian status hub: [https://status.atlassian.com/](https://status.atlassian.com/)
  - Many Atlassian pages provide a Statuspage API under `/api/v2/`

## CI / CD / Build

- CircleCI
  - [https://status.circleci.com/](https://status.circleci.com/)
  - API: [https://status.circleci.com/api/v2/summary.json](https://status.circleci.com/api/v2/summary.json)

- Travis CI (legacy)
  - [https://www.traviscistatus.com/](https://www.traviscistatus.com/)

- GitHub Actions uses GitHub status (see above)

## Cloud providers & Platform

- AWS (global)
  - Service Health Dashboard (public): [https://status.aws.amazon.com/](https://status.aws.amazon.com/)
  - Personal/Account Health: [https://health.aws.amazon.com/](https://health.aws.amazon.com/) (requires login)
  - Tip: AWS doesn't provide a single simple JSON endpoint for all services publicly; prefer the dashboard or region-specific RSS/API.

- Google Cloud
  - Status page: [https://status.cloud.google.com/](https://status.cloud.google.com/)
  - JSON endpoints for specific components are reachable from that UI; many GCP services have region filters.

- Microsoft Azure
  - Status: [https://status.azure.com/en-us/status](https://status.azure.com/en-us/status)
  - Azure Service Health in portal gives subscription-scoped info.

## Hosting, CDN & Edge

- Cloudflare
  - [https://www.cloudflarestatus.com/](https://www.cloudflarestatus.com/)
  - API: [https://www.cloudflarestatus.com/api/v2/summary.json](https://www.cloudflarestatus.com/api/v2/summary.json)

- Fastly
  - [https://status.fastly.com/](https://status.fastly.com/)

- Akamai
  - [https://status.akamai.com/](https://status.akamai.com/)

- Netlify
  - [https://www.netlifystatus.com/](https://www.netlifystatus.com/)

- Vercel
  - [https://www.vercel-status.com/](https://www.vercel-status.com/)

## Registries & Package Managers

- Docker Hub
  - [https://status.docker.com/](https://status.docker.com/)

- npm
  - [https://status.npmjs.org/](https://status.npmjs.org/)

- PyPI
  - [https://status.python.org/](https://status.python.org/)

## Databases & Managed DBs

- MongoDB Atlas
  - [https://status.cloud.mongodb.com/](https://status.cloud.mongodb.com/)

- Redis (Redis Labs)
  - [https://status.redislabs.com/](https://status.redislabs.com/)

- PostgreSQL / Managed (examples)
  - Heroku Postgres: [https://status.heroku.com/](https://status.heroku.com/)

## Observability & Alerts

- Sentry
  - [https://status.sentry.io/](https://status.sentry.io/)

- Datadog
  - [https://status.datadoghq.com/](https://status.datadoghq.com/)

- PagerDuty
  - [https://status.pagerduty.com/](https://status.pagerduty.com/)

## Payments and APIs

- Stripe
  - [https://status.stripe.com/](https://status.stripe.com/)

- Twilio
  - [https://status.twilio.com/](https://status.twilio.com/)

## CDNs, Edge and DDoS protection

- CloudFront (AWS)
  - See AWS Service Health Dashboard

- Cloudflare (see above)

---

## Programmatic healthchecks — patterns and examples

Most Statuspage.io-based services expose `/api/v2/status.json` or `/api/v2/summary.json`. A small shell snippet:

```bash
# generic statuspage check (works for many providers using Statuspage.io)
URL="https://www.githubstatus.com/api/v2/status.json"
curl -s "$URL" | jq .

# check that the status is 'operational' (Statuspage uses readable descriptions)
curl -s "$URL" | jq -r '.status.description'
```

For endpoints that return `summary` objects (with component status lists):

```bash
URL="https://www.cloudflarestatus.com/api/v2/summary.json"
curl -s "$URL" | jq -r '.status.description'
curl -s "$URL" | jq -r '.components[] | "\(.name): \(.status)"'
```

For an HTTP code-only quick check, use the status page URL directly. This is not enough for incident detail, but it is useful for simple monitoring:

```bash
curl -I -s -o /dev/null -w "%{http_code} %{url_effective}\n" https://www.githubstatus.com/
```

## Automating checks in CI or uptime monitors

- Use a monitoring job that polls the Statuspage API every 1–5 minutes (respect provider rate limits).
- Correlate upstream incidents with your app telemetry (errors, latency, rollout times) to avoid chasing false positives.
- Configure alerts with a short cool-down window and add escalation rules — outages in global CDNs often trigger bursts of alerts.

## When the status says "operational" but you’re still affected

1. Check region-specific dashboards (cloud providers often have region incidents).
2. Inspect recent deploys, feature flags, or DNS changes in your system.
3. Use `traceroute`/`mtr` to check network path to the provider.
4. Test from multiple locations (local dev, CI runner, an external host) to isolate whether it’s a client-specific issue.

## Final note

Treat provider status pages as one signal, not the whole incident review. If the provider says everything is healthy but your users are still affected, compare the provider status with your own deploy timeline, metrics, logs, DNS state, and checks from more than one network.
