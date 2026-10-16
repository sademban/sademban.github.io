---
layout: default
title: About
permalink: /about/
description: "About Nabin Sademba and how the technical articles on this site are researched, tested, and corrected."
---

I am Nabin Sademba, a developer based in Fukuoka, Japan. This site is where I publish practical notes from software, infrastructure, and developer-tooling work.

## What I write about

Most articles start with something I had to check, fix, publish, or understand: Docker and WSL behavior, Jekyll issues, VS Code extension work, cloud infrastructure, security advisories, and similar developer problems.

The goal is not to publish a high volume of general summaries. It is to leave behind a useful explanation, the commands or evidence that mattered, and the limits of what I verified.

## How articles are prepared

- I prefer primary documentation, release notes, source repositories, and vendor advisories.
- I include commands, versions, dates, and failure conditions when they affect the result.
- I distinguish between behavior I verified, information supported by sources, and conclusions that are only an inference.
- I avoid destructive testing on production systems. When I could not safely run a test, the article says so.

I am responsible for the final text and for keeping claims tied to evidence readers can inspect.

## Projects and corrections

You can find my public code and experiments on [GitHub](https://github.com/sademban), including projects discussed on this site.

If an article contains an outdated command, broken link, or technical error, please send the article URL and correction through the [contact page]({{ '/contact/' | relative_url }}). I review material corrections against current documentation before updating a post.
