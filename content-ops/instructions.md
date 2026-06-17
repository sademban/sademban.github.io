# Blog Automation Instructions

This site publishes practical tech writing for readers who want usable guidance, not generic trend content. Automation can help with scheduling, file placement, metadata, and checks, but it must not publish unsupported claims.

## AdSense Monetization Requirement

This blog is being prepared for Google AdSense verification and future ad revenue. Every new post must be written with AdSense content quality in mind.

Before drafting or publishing, assume the post may be reviewed for low-value content. Do not publish loose-end posts, filler notes, thin commentary, generic AI-written summaries, or news recaps that do not add original value.

For every researched post:

- Start from a useful reader problem, not from a need to publish something today.
- Prefer first-hand experience, local testing, screenshots, command output, repo work, or clearly cited primary sources.
- Keep sources, references, or evidence in the post unless there is a specific reason not to.
- Make uncertainty explicit. If something was not tested, say so.
- Avoid claims that sound confident but are only inferred from secondary reporting.
- Do not publish if the article feels unfinished, too short, too generic, or hard to verify.

If a post is not strong enough for AdSense review, keep it in `content-ops/drafts/` or mark the post with:

```yaml
published: false
noindex: true
sitemap: false
adsense: false
hidden: true
```

The default decision for weak content is to hold it back, not publish it.

## Editorial Focus

Write mostly about:

- Developer utility: commands, workflows, debugging steps, local setup, automation, and productivity.
- Infrastructure and ops: Docker, Linux, CI/CD, monitoring, deployments, reliability, and cloud basics.
- Security-minded engineering: safer configuration, auth mistakes, dependency hygiene, and incident prevention.
- Hands-on experiments: notes from tools you actually tried, with commands, screenshots, logs, or measured results.

Prefer posts that give the reader something they can reuse today:

- A checklist.
- A command reference.
- A minimal working config.
- A before/after measurement.
- A troubleshooting decision tree.
- A comparison based on explicit criteria.

## Quality Bar

Every post must have a basis. At least one of these must be true before a draft can be approved:

- It cites official documentation, release notes, standards, or vendor status pages.
- It includes your own command output, screenshots, logs, benchmark data, or repo experiment.
- It is a clearly labeled personal lab note based on a real setup you used.
- It compares tools using explicit, testable criteria.

Do not publish:

- Fake benchmarks or invented results.
- Unsourced claims about popularity, performance, security, or market direction.
- Generic listicles where the items were not checked.
- Posts that only restate AI-generated advice without verification.
- Breaking-news commentary unless the source links are current and official.

## Security And Sensitive Information

Follow secure publishing practices before approving any draft:

- Never commit or publish secrets, API keys, access tokens, passwords, private keys, session cookies, database URLs, internal auth headers, or personal recovery codes.
- Never publish real customer data, private user data, private email threads, internal-only URLs, non-public IP addresses, hostnames, repository names, security group IDs, account IDs, or infrastructure identifiers unless they are already public and intentionally disclosed.
- Redact sensitive values in logs and screenshots before adding them to the repo. Use placeholders such as `<redacted>`, `<example-token>`, `<internal-host>`, or `example.com`.
- Use fake but realistic sample values for commands and config snippets. Prefer documentation-safe domains like `example.com`, `example.org`, and local addresses such as `127.0.0.1`.
- Do not include exploit details, bypass steps, or vulnerability proof-of-concept code unless the post is clearly defensive, responsible, and safe for public release.
- Check every draft, asset, screenshot, zip file, command output, and copied log for sensitive information before moving a tracker item to `approved`.
- If a post is based on a private work incident, rewrite it as a generalized lesson and remove identifying details.
- If you are unsure whether something is sensitive, treat it as sensitive and keep it out of the repo.

## Post Types

Use one of these formats for automated planning:

- `tutorial`: step-by-step practical guide.
- `checklist`: repeatable operational checklist.
- `reference`: compact command or link reference.
- `comparison`: explicit tradeoff analysis.
- `lab-note`: personal experiment with observed results.
- `debugging-guide`: symptoms, checks, fixes, and verification.

## Required Draft Shape

Each approved draft should include:

- A direct title.
- A short description in front matter or tracker metadata.
- Tags that already exist or should be created.
- A practical opening that states the problem.
- Commands, configs, or concrete steps when relevant.
- A section named `Basis`, `Sources`, `References`, `Further reading`, or `Evidence`.
- Links, logs, outputs, screenshots, or notes that support the post.
- A featured image when useful, with `image`, `image_alt`, and `image_caption` front matter.

## Approval Workflow

1. Add an item to `content-ops/tracker.yml` with `status: idea`.
2. Move it to `research` only after adding source or evidence notes.
3. Move it to `drafted` after creating `content-ops/drafts/<slug>.markdown`.
4. Move it to `approved` only after the draft has been reviewed against this instruction set.
5. The daily workflow publishes at most one approved item whose `publish_after` date has arrived.

## Topic-To-Blog Workflow

When the author says they want to write about a specific topic, use this workflow:

1. Turn the topic into a tracker item with a clear slug, practical title, post format, tags, and expected reader utility.
2. Do in-depth research before drafting. Prefer official docs, release notes, source code, standards, reputable engineering posts, and primary sources.
3. Build a small demo, reproduction, benchmark, or local experiment when the topic allows it.
4. Record the demo environment, commands run, observed output, screenshots, errors, and lessons learned in `content-ops/research/<slug>.md`.
5. Write the blog from the research packet and demo experience, not from general model memory.
6. Include what worked, what failed, what surprised you, and how the reader can verify the result.
7. Keep unresolved uncertainty visible. If a claim was not tested, say that it was not tested.

For tutorial posts, the preferred evidence is:

- Official documentation for the tool or platform.
- A local demo or reproducible setup.
- Commands that were actually run.
- Observed output or screenshots with sensitive values redacted.
- A final verification step proving the tutorial worked.

## Blog Images

Every blog topic should include an image decision before approval:

- Use a generated image when the post benefits from a visual metaphor, cover image, diagram-like illustration, or simple educational scene.
- Use a real screenshot when the post is about a concrete UI, command output, dashboard, or demo result.
- Use no image only when a visual would add noise or require unsupported/fake details.

For generated featured images:

- Generate an original raster image and save it in the repo under `assets/posts/<category>/<year>/<month>/<slug>/`.
- Do not reference generated assets from temporary paths outside the repo.
- Avoid logos, trademarks, fake UI screenshots, fake terminal output, watermarks, and unreadable text inside the image.
- Prefer simple, technical, utility-focused visuals: clean desk setup, terminal/workflow concept, containers/layers, checklist board, debugging flow, monitoring dashboard abstraction, or security review scene.
- Keep generated images illustrative. Do not use them as evidence unless the image is a screenshot from a real demo.
- Add accurate `image_alt` text and a short `image_caption`.

For screenshots and demo images:

- Redact secrets, tokens, usernames, internal hostnames, account IDs, private paths, and customer data.
- Crop to the relevant area.
- Store the image under `assets/posts/<category>/<year>/<month>/<slug>/`.
- Mention in the research packet what the screenshot proves.

Use this front matter shape:

```yaml
image: /assets/posts/blog/2026/06/example-slug/featured-image.png
image_alt: "Short accessible description of the image"
image_caption: "Short caption explaining why this image is relevant"
```

## Publishing Rules

The publish script:

- Reads `content-ops/tracker.yml`.
- Selects the oldest approved item ready for publishing.
- Requires source or evidence metadata in the tracker.
- Requires a support section in the draft.
- Writes the post into `_posts/<category>/YYYY/MM/YYYY-MM-DD-<slug>.markdown`.
- Creates missing tag pages under `tags/`.
- Marks the tracker item as `published`.
