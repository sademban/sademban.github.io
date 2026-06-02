# Draft Queue

Place draft markdown files here until they are approved for publishing.

Use the slug from `content-ops/tracker.yml` as the filename:

```text
content-ops/drafts/<slug>.markdown
```

The publisher accepts optional front matter, but tracker metadata is the source of truth for `title`, `description`, `tags`, `category`, and publish date.

Each draft must include one support section before it can be published:

```markdown
## Evidence

- Command output, screenshots, logs, official docs, or other verification notes.
```

