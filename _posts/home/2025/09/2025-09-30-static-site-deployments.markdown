---
layout: post
title: "Researching static site deployments"
description: "Benchmarked GitHub Pages, Cloudflare Pages, and Netlify to figure out the next hosting step."
date: 2025-09-30 18:15:00 +0900
author: sademban
categories: home
tags:
  - infra
  - hosting
  - benchmarking
---

Captured notes on deployment times, build minute quotas, and caching controls across GitHub Pages, Cloudflare Pages, and Netlify. The matrix now lives in the Ops notebook so switching platforms takes minutes instead of days.

Spoiler: Cloudflare Pages wins on build speed, but Netlify still has the friendliest preview workflows. Decision postponed until I finish measuring image optimization costs.
