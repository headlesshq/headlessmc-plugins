# headlessmc-plugins

This repository contains the metadata for officially listed [HeadlessMc](https://github.com/headlesshq/headlessmc) plugins.

| Icon | Id | Name | Description | Latest | Source |
|------|----|------|-------------|--------|--------|
| <img src="https://raw.githubusercontent.com/headlesshq/headlessmc-quilt/refs/heads/main/logo.png" width="64" alt="Quilt"> | `quilt` | Quilt | Adds the Quilt platform to HeadlessMc | 1.0.0 | [headlessmc-quilt](https://github.com/headlesshq/headlessmc-quilt) |

## Submitting a plugin or a new version

1. Release your plugin (a jar attached to a GitHub release, for example).
2. Run the `generatePluginIndexEntry` task of the HeadlessMc dev plugin in your plugin project.
   It writes an `index-entry.json` with the metadata and the `url`, `sha256` and `size` of the jar.
   Attach it to your release.
3. Open a pull request against this repository:
   - **New plugin:** add the entry to the `plugins` array of `index.json`.
   - **New version:** append the release object to the `downloads` array of the existing entry.
