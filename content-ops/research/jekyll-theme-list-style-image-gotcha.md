# Jekyll theme list-style-image gotcha

## Sources

- MDN `list-style-image`: https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/list-style-image
- Jekyll themes docs: https://jekyllrb.com/docs/themes/
- Jekyll assets docs: https://jekyllrb.com/docs/assets/

Research notes:

- MDN describes `list-style-image` as the CSS property for using an image as a list item marker.
- Jekyll's theme docs explain that theme files, layouts, includes, and assets can be supplied by a gem-based theme and overridden by files in the site.
- The local site was using `jekyll-theme-hacker`. Its generated CSS included this rule:

```css
ul li {
  list-style-image: url("../images/bullet.png");
}
```

- That explains why overriding `li::before` did not remove the marker. The marker was not a pseudo-element.

## Local Evidence

Demo environment:

- OS: Windows host, PowerShell shell.
- Site generator: Jekyll 3.10.0 through GitHub Pages bundle.
- Theme: `jekyll-theme-hacker`.
- Date tested: 2026-06-03.

Commands run:

```powershell
curl.exe -s http://127.0.0.1:4000/assets/css/style.css | Select-String -Pattern "ul|ol|li|list-style|marker|background" -Context 1
curl.exe -s http://127.0.0.1:4000/assets/css/site.css | Select-String -Pattern "list-style-image: none|#main_content ul li" -Context 1
bundle exec jekyll build
```

Observed output:

```text
ul li { list-style-image: url("../images/bullet.png"); }
```

After adding the override:

```css
#main_content ul li,
#main_content ol li {
  list-style-image: none !important;
}
```

The visible `>>` markers disappeared from `/uses/` and `/links/`.

What worked:

- Inspecting the generated theme CSS instead of guessing at pseudo-elements.
- Overriding `list-style-image`, which was the actual property in use.
- Adding a cache-busted `site.css` URL so the browser did not keep stale CSS.

What failed or needed adjustment:

- Overriding `li::before` and `li:before` did not help because the marker was not created by a pseudo-element.
- Rebuilding alone was not enough when the browser had an old CSS file cached.

Verification step:

- Command/check: hard refresh `/uses/` and `/links/`.
- Expected result: old green `>>` list markers are gone.
- Observed result: normal list styling rendered after `list-style-image: none`.

## Practical Takeaway

When a Jekyll theme marker will not go away, inspect the compiled theme CSS first. If the theme uses `list-style-image`, pseudo-element overrides will not fix it. Override `list-style-image` directly and make sure your custom stylesheet loads after the theme stylesheet.

## Image Plan

Image type:

- [x] Generated featured image
- [ ] Real screenshot/demo image
- [ ] No image needed

Prompt or screenshot plan:

- Original social preview illustration showing an old image marker being replaced by a normal clean bullet. No readable text, no logos, no fake terminal output.

Asset path:

- `assets/posts/blog/2026/06/jekyll-theme-list-style-image-gotcha/featured-image.png`

Alt text:

- Illustration of a CSS list marker being replaced with a normal bullet style.

Caption:

- The visible marker came from list-style-image, not a pseudo-element.

## Security Review

- [x] No API keys, tokens, passwords, private keys, cookies, or auth headers.
- [x] No private customer data or internal-only infrastructure details.
- [x] Logs, screenshots, and copied outputs are redacted.
