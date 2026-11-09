# headlessmc-plugins

The index of officially listed [HeadlessMc](https://github.com/headlesshq/headlessmc) plugins.

HeadlessMc reads [`index.json`](index.json) from
`https://raw.githubusercontent.com/headlesshq/headlessmc-plugins/main/index.json`
to power `plugin search` and `plugin download`. The index only contains metadata and download links.
The plugin jars themselves stay in the release of each plugin's own repository.

## Installing plugins

Inside HeadlessMc:

```
plugin search quilt
plugin download quilt
```

`plugin download <id>` picks the newest version that is compatible with your HeadlessMc and Java version
and verifies the SHA-256 hash and size from the index before installing it.
See the [plugin documentation](https://headlesshq.github.io/headlessmc/plugins/) for more.

## Submitting a plugin or a new version

1. Release your plugin (a jar attached to a GitHub release, for example).
2. Run the `generatePluginIndexEntry` task of the HeadlessMc dev plugin in your plugin project.
   It writes an `index-entry.json` with the metadata and the `url`, `sha256` and `size` of the jar.
   Attach it to your release.
3. Open a pull request against this repository:
   - **New plugin:** add the entry to the `plugins` array of `index.json`.
   - **New version:** append the release object to the `downloads` array of the existing entry.
     Do not change or remove older releases.

The format follows `PluginIndex.java` in HeadlessMc. Unknown fields are ignored.

| Field | Where | Description |
|-------|-------|-------------|
| `id` | plugin | Lowercase, unique, the same as the id in the plugin manifest |
| `name`, `description`, `authors`, `license`, `homepage`, `icon` | plugin | Human-readable metadata, all optional |
| `downloads` | plugin | The released versions |
| `version` | release | Unique per plugin |
| `headlessmc` | release | Compatible HeadlessMc versions, a version range such as `[3.0.0,4)` |
| `java` | release | Minimum Java version |
| `url` | release | Where to download the jar |
| `sha256` | release | SHA-256 of the jar, lowercase hex |
| `size` | release | Size of the jar in bytes |

[`index.schema.json`](index.schema.json) is a JSON Schema for editor completion and validation.
Add `"$schema": "./index.schema.json"` to get it in your editor.

### Checks

A workflow validates every pull request with `scripts/validate-index.sh`: schema version 1, unique lowercase ids,
unique versions per plugin, and for every release a reachable `url` whose SHA-256 and size match.
Run it locally with `GH_TOKEN=$(gh auth token) scripts/validate-index.sh` (needs `jq` and `curl`;
`--offline` skips the downloads). While plugin repositories are private, github.com release URLs
are downloaded through `gh` with the token; other URLs are fetched anonymously.

## Review and trust policy

Plugins run with the full permissions of HeadlessMc, so listing is a trust decision.

- Every change to `index.json` goes through a pull request reviewed by a maintainer.
- Plugins must be open source, with the `homepage` pointing to the source code, and a license.
- The jar must be reproducible from the tagged source, and `url` must point to an immutable release asset.
- Published releases are never modified. Fix a problem by releasing a new version.
- Maintainers may remove a release or plugin that is malicious, abandoned or unsafe.
- Listing is not an audit. Only install plugins you trust.

## Listed plugins

| Id | Name | Description | Latest | Source |
|----|------|-------------|--------|--------|
| `quilt` | Quilt | Adds the Quilt platform to HeadlessMc | 1.0.0 | [headlessmc-quilt](https://github.com/headlesshq/headlessmc-quilt) |
