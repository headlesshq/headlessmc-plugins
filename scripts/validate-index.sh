#!/usr/bin/env bash
# Validates index.json: schema version, ids, versions and that every url matches its sha256 and size.
# github.com release URLs are fetched with `gh` when GH_TOKEN is set (needed while plugin repos are private),
# everything else anonymously. Use --offline to skip the downloads.
set -uo pipefail
index="index.json"; offline=0
for a in "$@"; do [ "$a" = "--offline" ] && offline=1 || index="$a"; done
fail=0
err() { echo "::error::$*"; fail=1; }

[ "$(jq -r '.schemaVersion' "$index")" = "1" ] || err "schemaVersion must be 1"
jq -e '.plugins | type == "array"' "$index" >/dev/null || err "plugins must be an array"

jq -r '.plugins[].id' "$index" | grep -vE '^[a-z0-9][a-z0-9._-]*$' | while read -r id; do err "plugin id '$id' must be lowercase ([a-z0-9._-])"; done
dups=$(jq -r '.plugins[].id' "$index" | sort | uniq -d)
[ -z "$dups" ] || err "duplicate plugin ids: $dups"
dups=$(jq -r '.plugins[] | .id as $id | .downloads[]?.version | "\($id) \(.)"' "$index" | sort | uniq -d)
[ -z "$dups" ] || err "duplicate versions: $dups"

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
while IFS=$'\t' read -r id version url sha size; do
  where="$id $version"
  if [ -z "$url" ] || [ -z "$sha" ] || [ -z "$size" ]; then err "$where: url, sha256 and size are required"; continue; fi
  [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || { err "$where: sha256 must be 64 lowercase hex characters"; continue; }
  [ "$offline" = 1 ] && continue
  jar="$work/plugin.jar"; rm -f "$jar"
  if [[ "$url" =~ ^https://github\.com/([^/]+/[^/]+)/releases/download/([^/]+)/([^/]+)$ ]] && [ -n "${GH_TOKEN:-}" ]; then
    gh release download "${BASH_REMATCH[2]}" -R "${BASH_REMATCH[1]}" -p "${BASH_REMATCH[3]}" -O "$jar" 2>"$work/log" \
      || { err "$where: url not reachable: $url ($(tr '\n' ' ' <"$work/log"))"; continue; }
  else
    curl -fsSL --retry 2 -o "$jar" "$url" 2>"$work/log" \
      || { err "$where: url not reachable: $url ($(tr '\n' ' ' <"$work/log"))"; continue; }
  fi
  actual_size=$(stat -c %s "$jar"); actual_sha=$(sha256sum "$jar" | cut -d' ' -f1)
  [ "$actual_size" = "$size" ] || err "$where: size is $actual_size, index says $size"
  [ "$actual_sha" = "$sha" ] || err "$where: sha256 is $actual_sha, index says $sha"
  echo "checked $where"
done < <(jq -r '.plugins[] | .id as $id | .downloads[]? | [$id, .version, .url, .sha256, .size] | map(. // "" | tostring) | @tsv' "$index")
exit $fail
