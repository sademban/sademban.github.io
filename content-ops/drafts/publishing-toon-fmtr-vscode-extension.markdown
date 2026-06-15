---
layout: post
title: "publishing TOON FMTR, my first VS Code extension"
description: "Notes from publishing TOON FMTR, a VS Code extension for TOON syntax highlighting, formatting, JSON conversion, settings, and safer auto-convert behavior."
date: 2026-06-15 09:00:00 +0900
author: sademban
categories: blog
tags:
  - vscode
  - developer-experience
  - javascript
  - tooling
image: /assets/posts/blog/2026/06/publishing-toon-fmtr-vscode-extension/featured-image.png
image_alt: "Sketch-style illustration with TOON FMTR text, the extension logo, and JSON to TOON conversion cards"
image_caption: "TOON FMTR adds syntax highlighting, formatting, and JSON conversion for TOON files."
show_hero_image: true
---

## Publishing TOON FMTR, my first VS Code extension

Today I published [TOON FMTR](https://github.com/sademban/toon-tools), a Visual Studio Code extension for working with TOON files.

The extension currently:

- recognizes `.toon` files
- adds TOON syntax highlighting
- converts JSON to TOON
- converts TOON to JSON
- formats `.toon` documents
- can auto-convert files on save
- adds VS Code settings for auto-convert behavior

I built it manually so I could see how the extension pieces connect.

## The extension shape

The main files are:

- `package.json`
- `src/extension.ts`
- `syntaxes/toon.tmLanguage.json`
- `language-configuration.json`
- `esbuild.js`
- `.vscode/launch.json`
- `.vscodeignore`

`package.json` is the extension manifest. It declares the commands, settings, language, grammar, activation events, and entry point.

The entry point is:

```json
"main": "./dist/extension.js"
```

`src/extension.ts` is where the behavior is registered. For example:

```ts
vscode.commands.registerCommand("toon-tools.convertJsonToToon", async () => {
  // command behavior
});
```

The command ID in TypeScript must match the command ID in `package.json`.

## Commands and settings

The extension contributes two commands:

```text
TOON: Convert JSON to TOON
TOON: Convert TOON to JSON
```

It also contributes these settings:

```text
toonTools.autoConvertOnSave
toonTools.autoConvertDirection
toonTools.autoConvertOverwriteExisting
toonTools.autoConvertMaxFileSizeKb
```

Those settings show up in the normal VS Code Settings UI.

## Syntax highlighting and formatting

`.toon` files are registered as a custom language:

```json
{
  "id": "toon",
  "extensions": [".toon"],
  "configuration": "./language-configuration.json"
}
```

Syntax highlighting comes from the TextMate grammar:

```json
{
  "language": "toon",
  "scopeName": "source.toon",
  "path": "./syntaxes/toon.tmLanguage.json"
}
```

The formatter is registered in the extension code, so Format Document works on `.toon` files.

## Auto-convert safety

Auto-convert on save was the part that needed the most care.

Before publishing, I changed it so:

- auto-convert only runs for `.json` and `.toon` files
- extensionless files are skipped
- existing sibling files are not silently overwritten
- overwrite requires a prompt unless the setting allows it
- auto-convert has a max file size limit
- manual conversion still works for larger files

That keeps the automatic behavior safer without removing the manual commands.

## Local testing

The local test flow:

```bash
npm install
npm run compile
```

Then press `F5` in VS Code to open the Extension Development Host.

Manual checks:

- open `samples/users.json`
- run `TOON: Convert JSON to TOON`
- run `TOON: Convert TOON to JSON`
- format a `.toon` document
- enable auto-convert in Settings
- save JSON and confirm a `.toon` sibling is created
- confirm overwrite prompts appear
- confirm extensionless files are skipped

Before packaging, I also checked:

```bash
npm audit --omit=dev
```

Result:

```text
found 0 vulnerabilities
```

## Packaging

The package command is:

```bash
npm run vsix
```

That runs `vsce package` and creates:

```text
toon-tools-0.0.2.vsix
```

Before writing this, I verified:

```bash
npm run compile
npm audit --omit=dev
npm run vsix
```

All three passed.

## Publishing

I uploaded the first Marketplace version manually from the Visual Studio Marketplace publisher portal.

One practical detail: Marketplace versions are immutable. After `0.0.1` was uploaded, fixes required a version bump:

```json
"version": "0.0.2"
```

Then I rebuilt the VSIX and uploaded the new package.

## About GitHub Actions publishing

I added a GitHub Actions workflow for validation:

```text
.github/workflows/publish.yml
```

The validation flow can run:

```text
npm ci
npm audit --omit=dev
npm run compile
npx vsce package
```

Automated Marketplace publishing is possible, but it needs Azure DevOps/Marketplace authentication and a personal access token.

During setup, that Azure/PAT flow asked for card information. I did not want to do that for this release, so I built the `.vsix` locally and uploaded it from my local development environment instead.

For now, GitHub Actions can stay as validation. Publishing can be automated later.

## Next

Things I want to improve:

- better TOON validation
- editor diagnostics
- clearer conversion errors
- more sample files
- automated tests for conversion and auto-convert behavior
- a publishing workflow after the Marketplace auth setup is sorted

The main thing I learned is simple:

```text
package.json tells VS Code what exists.
extension.ts makes it work.
vsce turns it into a package.
```

## Sources

- [TOON FMTR repository](https://github.com/sademban/toon-tools)
- [VS Code: Publishing Extensions](https://code.visualstudio.com/api/working-with-extensions/publishing-extension)
- [VS Code: Extension Manifest](https://code.visualstudio.com/api/references/extension-manifest)
- [VS Code: Contribution Points](https://code.visualstudio.com/api/references/contribution-points)
- [VS Code: Syntax Highlight Guide](https://code.visualstudio.com/api/language-extensions/syntax-highlight-guide)
