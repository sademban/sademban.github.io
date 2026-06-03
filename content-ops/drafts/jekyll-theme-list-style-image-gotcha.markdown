---
layout: post
title: "When a Jekyll theme keeps showing weird list bullets"
description: "A short debugging note about removing inherited Jekyll theme list markers when overriding pseudo-elements does not work."
date: 2026-06-03 09:00:00 +0900
author: sademban
categories: blog
tags:
  - jekyll
  - css
  - developer-experience
image: /assets/posts/blog/2026/06/jekyll-theme-list-style-image-gotcha/featured-image.png
image_alt: "Illustration of a CSS list marker being replaced with a normal bullet style"
image_caption: "The visible marker came from list-style-image, not a pseudo-element."
---

## 🧹 When a Jekyll theme keeps showing weird list bullets

While redesigning this site, I hit a CSS problem that looked small but wasted more time than it should have.

Normal Markdown lists on pages like `/uses/` and `/links/` still showed the old green `>>` marker from the hacker theme. The rest of the site had moved to a cleaner writing-first layout, but that one marker kept showing up.

My first guess was that the theme was adding it with a pseudo-element, so I tried this:

```css
#main_content li::before,
#main_content li:before {
  content: none !important;
  display: none !important;
}
```

Nothing changed.

That was the clue. If removing `::before` does nothing, the marker is probably coming from somewhere else.

## Check the generated theme CSS

I stopped guessing and checked the CSS that Jekyll was actually serving:

```powershell
curl.exe -s http://127.0.0.1:4000/assets/css/style.css |
  Select-String -Pattern "ul|ol|li|list-style|marker|background" -Context 1
```

That showed the real rule:

```css
ul li {
  list-style-image: url("../images/bullet.png");
}
```

That image was the `>>` marker.

So my first fix was aiming at the wrong thing. The browser was not rendering a `::before` marker. It was using an image as the list marker.

## What finally worked

What finally worked was overriding `list-style-image` directly in my custom stylesheet:

```css
.page-content ul:not(.writing-list):not(.archive-list):not(.tag-collection__list) {
  list-style: disc !important;
  list-style-image: none !important;
}

.page-content ol {
  list-style: decimal !important;
  list-style-image: none !important;
}

#main_content ul li,
#main_content ol li {
  list-style-image: none !important;
}
```

The first two rules restore normal list behavior. The last rule targets the theme's old `ul li` rule directly.

I also added a cache-busting query string to the custom stylesheet:

```liquid
<link rel="stylesheet" href="{{ '/assets/css/site.css' | relative_url }}?v={{ site.time | date: '%s' }}">
```

That part matters during local work. A Jekyll rebuild can be correct, but the browser may still be showing the old CSS.

## What I should have done first

The shorter version of the debugging process is:

1. Inspect the generated CSS that the browser receives.
2. Search for the visible behavior, not only the selector you expect.
3. Check whether the marker is `::before`, `::marker`, `list-style`, or `list-style-image`.
4. Put your override stylesheet after the theme stylesheet.
5. Hard refresh or add a cache-busting query string.

For this bug, step 3 was the answer: `list-style-image`.

## Why this happens with Jekyll themes

Gem-based Jekyll themes can ship their own layouts, includes, stylesheets, and image assets. That is useful, but it also means some styling is hidden until you inspect the generated output or the theme files.

In this site, the theme CSS was still being loaded:

```html
<link rel="stylesheet" href="/assets/css/style.css">
<link rel="stylesheet" href="/assets/css/site.css">
```

That setup is fine. The important part is order: `site.css` has to load after `style.css`, otherwise the theme wins.

## Evidence

This note is based on:

- The local generated `jekyll-theme-hacker` CSS rule: `ul li { list-style-image: url("../images/bullet.png"); }`.
- MDN documentation for [`list-style-image`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/list-style-image).
- Jekyll documentation for [themes](https://jekyllrb.com/docs/themes/) and [assets](https://jekyllrb.com/docs/assets/).
- Local verification on 2026-06-03 using `bundle exec jekyll build` and the local Jekyll server.
