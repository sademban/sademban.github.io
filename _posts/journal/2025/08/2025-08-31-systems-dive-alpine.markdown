---
layout: post
title: "Systems dive: Alpine vs. Debian"
description: "Benchmarking Alpine and Debian slim images to understand performance, tooling, and debugging trade-offs."
date: 2025-08-31 19:45:00 +0900
author: sademban
categories: journal
tags:
  - linux
  - docker
  - benchmarking
---

Ran a bake-off between Alpine and Debian slim images for a service that leans on OpenSSL. Measured startup time, memory footprint, and the cost of pulling extra musl-compatible packages. Debian won by a small margin once we factored in debugging tooling.

The experiment reminded me to treat base-image swaps as research projects, not quick wins. Documented the findings for the team and left TODOs for follow-up benchmarking on ARM.
