# Research packet: GitHub Copilot code review billing checklist

Status: drafted
Date: 2026-06-04
Topic: GitHub Copilot code review on private repositories

## Working angle

GitHub Copilot code review is useful, but the billing model changed on June 1, 2026. Private repositories now need a small operations checklist before teams enable automatic reviews everywhere.

This is not a panic post. It is a practical note for solo developers and small teams who might otherwise miss the second cost path: GitHub AI Credits plus GitHub Actions minutes.

## Source trail

- GitHub Changelog: Copilot code review will start consuming GitHub Actions minutes on June 1, 2026.
  - URL: https://github.blog/changelog/2026-04-27-github-copilot-code-review-will-start-consuming-github-actions-minutes-on-june-1-2026/
  - Key fact: for private repositories, each Copilot code review consumes Actions minutes from the existing entitlement, with overages billed at normal Actions rates. Public repositories are unchanged because Actions minutes remain free there.
- GitHub Changelog: Updates to GitHub Copilot billing and plans.
  - URL: https://github.blog/changelog/2026-06-01-updates-to-github-copilot-billing-and-plans/
  - Key fact: usage-based billing is live for all Copilot plans; code review consumes Actions minutes in addition to GitHub AI Credits; user-level budgets are generally available for organizations and enterprises.
- GitHub Docs: About GitHub Copilot code review.
  - URL: https://docs.github.com/en/copilot/concepts/agents/code-review
  - Key fact: Copilot code review uses GitHub Actions for agentic capabilities, can use GitHub-hosted, larger, or self-hosted runners, and code reviews have two cost components.
- GitHub Enterprise Cloud Docs: Enabling Copilot code review in your enterprise.
  - URL: https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/administer-copilot/manage-for-enterprise/manage-agents/enable-copilot-code-review
  - Key fact: GitHub recommends starting with a small selection of repositories and running a trial before enabling automatic reviews broadly.
- GitHub Blog: Copilot is moving to usage-based billing.
  - URL: https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
  - Key fact: PRUs are replaced by GitHub AI Credits, calculated from token usage. Code review also consumes Actions minutes.

## Community/topic scan

- daily.dev surfaced the Copilot code review Actions-minutes change as a practical developer-operations topic.
- DEV Community had recent Copilot workflow discussion, including getting better results from Copilot in engineering workflows.
- Medium had governance/billing commentary around token-based AI pricing.

These were used as topic signals only. The post relies on GitHub's own changelog and documentation for factual claims.

## Demo/test boundary

I did not test against a paid GitHub organization billing account. The post should not claim first-hand billing measurements.

The local value of the post is the checklist:

- identify private repositories where Copilot review may run;
- decide whether review is manual or automatic;
- check budgets before enabling it broadly;
- confirm which runner class is used;
- monitor both Copilot usage and Actions usage;
- keep human review in the loop.

## Security/privacy notes

- Do not include organization names, billing account screenshots, private repository names, invoice numbers, user emails, tokens, or usage reports.
- Avoid exact internal spend claims unless the data is deliberately sanitized.
- Do not imply Copilot output is a security guarantee. GitHub's docs explicitly tell users to validate feedback carefully and supplement it with human review.
