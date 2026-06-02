# Research Packets

Create one research packet per planned post:

```text
content-ops/research/<slug>.md
```

The draft generator only writes from tracker metadata and these research packets. It should not draft from a title alone.

## Required Shape

```markdown
# Topic

Short summary of the post idea.

## Sources

- Official docs or primary source URL:
- Release notes:
- Related GitHub issue/source code:

## Local Evidence

Demo environment:

- OS:
- Tool versions:
- Repo/project used:
- Date tested:

Commands run:

```bash
example command here
```

Observed output:

```text
redacted output here
```

What worked:

- 

What failed or needed adjustment:

- 

Verification step:

- Command/check:
- Expected result:
- Observed result:

## Practical Takeaway

What the reader should be able to do after reading the post.

## Image Plan

Image type:

- [ ] Generated featured image
- [ ] Real screenshot/demo image
- [ ] No image needed

Prompt or screenshot plan:

- 

Asset path:

- `assets/posts/blog/YYYY/MM/<slug>/featured-image.png`

Alt text:

- 

Caption:

- 

## Security Review

- [ ] No API keys, tokens, passwords, private keys, cookies, or auth headers.
- [ ] No private customer data or internal-only infrastructure details.
- [ ] Logs, screenshots, and copied outputs are redacted.
```

## Research Rules

- Prefer official docs, release notes, source code, and your own experiments.
- Use copied output only after redacting sensitive values.
- Keep speculation out of the packet. If something is uncertain, write that it is uncertain.
- Use `example.com`, `127.0.0.1`, and placeholder values for examples.
