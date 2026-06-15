# Publishing TOON FMTR VS Code extension research

Checked on: 2026-06-15

## Topic

Blog post about publishing TOON FMTR, a VS Code extension for TOON files, and what I learned by building the extension manually instead of starting from a generator.

## Project details

- Extension package name: `toon-tools`
- Marketplace display name: `TOON FMTR`
- Publisher: `sademban`
- Repository: https://github.com/sademban/toon-tools
- Current package version checked locally: `0.0.2`
- Current package: `toon-tools-0.0.2.vsix`

## What the extension does

- Recognizes `.toon` files as a custom language.
- Adds basic TOON syntax highlighting.
- Converts JSON to TOON.
- Converts TOON to JSON.
- Formats `.toon` documents.
- Optionally auto-converts files on save.
- Adds VS Code Settings UI controls for auto-convert behavior.

## Local files checked

### `package.json`

Key local values:

```json
{
  "name": "toon-tools",
  "displayName": "TOON FMTR",
  "version": "0.0.2",
  "publisher": "sademban",
  "main": "./dist/extension.js"
}
```

Important contributions:

- language id: `toon`
- extension: `.toon`
- grammar: `./syntaxes/toon.tmLanguage.json`
- commands:
  - `toon-tools.convertJsonToToon`
  - `toon-tools.convertToonToJson`
- settings:
  - `toonTools.autoConvertOnSave`
  - `toonTools.autoConvertDirection`
  - `toonTools.autoConvertOverwriteExisting`
  - `toonTools.autoConvertMaxFileSizeKb`

### `src/extension.ts`

Main extension runtime source:

- registers commands
- registers formatter
- handles auto-convert-on-save behavior

Important lesson: command IDs registered in TypeScript must exactly match the command IDs declared in `package.json`.

### Other files

- `syntaxes/toon.tmLanguage.json`: TextMate grammar.
- `language-configuration.json`: editor behavior for brackets, quotes, surrounding pairs.
- `esbuild.js`: bundles TypeScript into `dist/extension.js`.
- `.vscode/launch.json`: F5 Extension Development Host testing.
- `.vscodeignore`: packaging exclusions.
- `README.md`, `CHANGELOG.md`, `LICENSE`: Marketplace/repo polish.

## Security and data-loss review

Improvements before publishing:

- Auto-convert only runs for real `.json` and `.toon` files.
- Extensionless files are skipped.
- Existing sibling files are not silently overwritten.
- User is prompted before overwrite.
- Added an "always overwrite" setting.
- Added max file size setting for auto-convert.
- Manual conversion still works for larger files.

## Verification run on 2026-06-15

Commands run in the local extension repo:

```text
npm run compile
npm audit --omit=dev
npm run vsix
```

Observed results:

- `npm run compile` passed.
- TypeScript check passed via `tsc --noEmit`.
- esbuild generated:
  - `dist\extension.js` around 57.5 KB
  - `dist\extension.js.map` around 120.3 KB
- `npm audit --omit=dev` returned `found 0 vulnerabilities`.
- `npm run vsix` packaged `toon-tools-0.0.2.vsix`.
- VSIX output package:
  - `toon-tools-0.0.2.vsix`
- VSIX package size reported by `vsce`: 56.38 KB.

## Publishing notes

- Initial Marketplace upload was done manually from the Visual Studio Marketplace publisher portal.
- Important publishing lesson: Marketplace versions are immutable. After publishing `0.0.1`, fixes required bumping `package.json` to `0.0.2`, rebuilding, and uploading a new `.vsix`.
- A GitHub Actions workflow was added locally at `.github/workflows/publish.yml`.
- The workflow validates:
  - `npm ci`
  - `npm audit --omit=dev`
  - `npm run compile`
  - `npx vsce package`
- Automated publishing is paused for now.
- The reason: automated Marketplace publishing requires Azure DevOps/Marketplace authentication and a personal access token. In this setup, the Azure DevOps signup/token path asked for card information, so local `.vsix` upload was used instead.

## Official docs notes

VS Code docs confirm:

- Extensions can be published to the VS Code Marketplace or packaged into installable VSIX files.
- `vsce` is the CLI for packaging, publishing, and managing VS Code extensions.
- `vsce package` creates a `.vsix` file.
- Manual publishing can be done by packaging with `vsce package` and uploading through the Marketplace publisher management page.
- VS Code uses Azure DevOps for Marketplace services, authentication, hosting, and extension management.
- The extension manifest is the `package.json` file.
- Contribution points define commands, languages, grammars, configuration, and other extension capabilities.
- TextMate grammars are used for syntax highlighting.

## Image decision

Generated featured image added:

```text
assets/posts/blog/2026/06/publishing-toon-fmtr-vscode-extension/featured-image.png
```

The image is illustrative, not evidence. It uses a sketch style, includes the text `TOON FMTR`, includes the extension logo as a badge, shows JSON-to-TOON conversion cues, and avoids copying VS Code or Microsoft logos.

## Source URLs

- https://code.visualstudio.com/api/working-with-extensions/publishing-extension
- https://code.visualstudio.com/api/references/extension-manifest
- https://code.visualstudio.com/api/references/contribution-points
- https://code.visualstudio.com/api/language-extensions/syntax-highlight-guide
- https://github.com/sademban/toon-tools
