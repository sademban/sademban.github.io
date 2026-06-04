---
layout: post
title: "Copilot code review on private repos: check the bill before you automate it"
description: "GitHub Copilot code review can now touch both AI Credits and Actions minutes on private repositories. Here is the simple rollout check I would do first."
date: 2026-06-04 09:00:00 +0900
author: sademban
categories: blog
tags:
  - github
  - copilot
  - github-actions
  - developer-experience
image: /assets/posts/blog/2026/06/github-copilot-code-review-billing-checklist/featured-image.svg
image_alt: "Abstract code review checklist beside a usage budget gauge"
image_caption: "Copilot code review is useful, but private repositories need usage guardrails."
---

## Copilot code review on private repos: check the bill before you automate it

I like the idea of Copilot reviewing a pull request before a human spends time on it. A second pass can catch boring mistakes, missing tests, unclear code, or places where the change needs more explanation.

But I would be careful before enabling it automatically across private repositories.

GitHub changed the cost model on June 1, 2026. For private repositories, Copilot code review can now involve two separate buckets:

- GitHub AI Credits for the review itself.
- GitHub Actions minutes for the runner work behind the review.

Public repositories are different because GitHub says Actions minutes are still free there. The place I would pay attention is private repos, especially if review runs automatically on every pull request.

## The part that is easy to miss

This does not look like a CI setting when you first think about it.

It feels like a review feature: open a PR, ask Copilot to review, read the comments.

But GitHub's docs say Copilot code review uses GitHub Actions for its agentic work. That is the important detail. The review is not only an AI request. There can also be runner time behind it.

The rough mental model is:

```text
review comments = AI Credits
private repo runner work = Actions minutes
```

That does not make the feature bad. It just means I would treat it more like enabling a workflow than enabling a nice editor setting.

## What I would check before turning it on everywhere

I would start with a small audit.

First, list the private repositories where Copilot review might run. Not all repositories are equal. A quiet personal repo and a busy application repo will have very different usage patterns.

Then check whether review is manual or automatic. Manual review is easier to reason about at the beginning. Automatic review is where usage can grow without anyone noticing.

After that, check both sides of the bill:

- Copilot usage and AI Credits.
- GitHub Actions minutes.

That second line is the one I think people can miss. If a team already watches Actions minutes because CI is expensive, Copilot code review belongs in the same conversation.

I would also check the runner setup. GitHub says standard GitHub-hosted runners are the default for Copilot code review, but larger runners and self-hosted runners change the operational picture. Self-hosted runners may avoid GitHub-hosted Actions minutes, but they are not free in practice. Someone still owns the machine, updates, capacity, and failure modes.

## My rollout would be boring on purpose

If I were enabling this for a small team, I would not start with every private repo.

I would pick one or two active repositories and use Copilot review manually for a week. Not on every typo fix. I would use it on PRs where another pass could actually help: risky changes, unfamiliar code, security-sensitive edits, or changes where the author wants a second opinion before asking a teammate.

At the end of the week I would ask two plain questions:

- Did the comments save review time or mostly add noise?
- Did Copilot usage or Actions usage move in a way we are comfortable with?

If the answer is good, then maybe expand it. If not, keep it manual or limit it to the repos where it is clearly useful.

GitHub's own enterprise docs recommend starting with a small selection of repositories and running a trial before broad automatic use. That is sensible advice.

## The rule I would write down

I would put a short rule somewhere the team can see it:

```text
Use Copilot review when a second pass is worth the extra usage.
Do not request it automatically on every small change until the budget impact is understood.
Human review still owns the final decision.
```

That is probably enough for the first version.

The goal is not to make Copilot hard to use. The goal is to avoid a quiet setting becoming another thing nobody understands when the bill arrives.

## What I would not do

I would not treat Copilot review as a replacement for human review.

I would not enable automatic review across every private repository on day one.

I would not look only at the Copilot side of the billing page and forget Actions minutes.

And I would not paste private billing screenshots, repository names, or usage reports into a public blog post just to prove a point.

## Takeaway

Copilot code review can be useful. The change is that private repositories now need a little more care before you automate it. Check where it runs, who can trigger it, which runner it uses, and whether both Copilot and Actions usage are covered by a budget you understand.

## Evidence

This post is based on:

- GitHub Changelog: [Copilot code review will start consuming GitHub Actions minutes on June 1, 2026](https://github.blog/changelog/2026-04-27-github-copilot-code-review-will-start-consuming-github-actions-minutes-on-june-1-2026/)
- GitHub Changelog: [Updates to GitHub Copilot billing and plans](https://github.blog/changelog/2026-06-01-updates-to-github-copilot-billing-and-plans/)
- GitHub Docs: [About GitHub Copilot code review](https://docs.github.com/en/copilot/concepts/agents/code-review)
- GitHub Enterprise Cloud Docs: [Enabling GitHub Copilot code review in your enterprise](https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/administer-copilot/manage-for-enterprise/manage-agents/enable-copilot-code-review)
- GitHub Blog: [GitHub Copilot is moving to usage-based billing](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/)

I did not test this against a paid GitHub organization billing account, so I am not claiming real billing measurements here.
