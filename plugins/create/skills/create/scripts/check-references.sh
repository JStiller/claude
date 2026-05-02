#!/usr/bin/env bash
# check-references.sh — Detect when Claude Code docs have changed
#
# Fetches each reference file's source URL, hashes the page content, and
# compares against a local cache to report which references may need updating.
# Also tracks the latest Claude Code version from the official CHANGELOG.
#
# Usage:
#   ./check-references.sh            Check for changes vs cache (read-only)
#   ./check-references.sh --update   Check and write new hashes to cache
#
# Cache file: .reference-cache.json  (commit this file to share baseline)
#
# Dependencies: curl, jq, sha256sum (Linux) or shasum (macOS)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_FILE="$SCRIPT_DIR/.reference-cache.json"
CHANGELOG_URL="https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md"
UPDATE=false

# ── Argument parsing ───────────────────────────────────────────────────────────

for arg in "$@"; do
  case "$arg" in
    --update) UPDATE=true ;;
    --help|-h)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg  (try --help)" >&2
      exit 1
      ;;
  esac
done

# ── Dependency checks ──────────────────────────────────────────────────────────

for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

sha256_hash() {
  # Works on both Linux (sha256sum) and macOS (shasum)
  if command -v sha256sum &>/dev/null; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

# ── Helpers ────────────────────────────────────────────────────────────────────

# Fetch a URL, strip HTML tags and normalise whitespace, return sha256
fetch_and_hash() {
  local url="$1"
  local content
  # Follow redirects, timeout 30s, suppress progress, fake browser UA
  content=$(curl -sfL --max-time 30 \
    -H "Accept: text/html,application/xhtml+xml" \
    -H "User-Agent: Mozilla/5.0 (compatible; reference-check/1.0)" \
    "$url" 2>/dev/null) || { echo ""; return; }

  # Strip HTML: remove script/style blocks, then all remaining tags,
  # decode common entities, one word per line, drop blanks, hash.
  local text
  text=$(echo "$content" \
    | tr '\n' ' ' \
    | sed -e 's/<script[^>]*>[^<]*<\/script>//gI' \
          -e 's/<style[^>]*>[^<]*<\/style>//gI' \
          -e 's/<[^>]*>//g' \
          -e 's/&amp;/\&/g' -e 's/&lt;/</g' -e 's/&gt;/>/g' \
          -e 's/&nbsp;/ /g' -e 's/&#[0-9]*;//g' \
    | tr -s '[:space:]' '\n')
  if [[ -z "$text" ]]; then
    echo ""
    return 0
  fi
  echo "$text" | grep -v '^[[:space:]]*$' | sha256_hash
}

# Fetch the latest Claude Code version from the CHANGELOG
fetch_version() {
  local cl
  cl=$(curl -sf --max-time 15 "$CHANGELOG_URL" 2>/dev/null) || { echo "unknown"; return; }
  # Matches lines like:  ## 2.1.130  or  ## [2.1.130]
  local ver
  ver=$(echo "$cl" | grep -m1 "^## " | sed 's/^## //' | tr -d '[]' | awk '{print $1}')
  echo "${ver:-unknown}"
}

# ── Read cache ─────────────────────────────────────────────────────────────────

if [[ -f "$CACHE_FILE" ]]; then
  cache=$(cat "$CACHE_FILE")
else
  cache='{}'
fi

cached_version=$(echo "$cache"  | jq -r '.version   // "none"')
cached_timestamp=$(echo "$cache" | jq -r '.timestamp // "never"')

# ── Collect reference files and their primary source URLs ──────────────────────

declare -A sources   # filename → url

while IFS= read -r file; do
  name=$(basename "$file")
  # Only the first Source: line (header), not inline mentions
  url=$(head -15 "$file" | grep "^Source:" | head -1 \
        | sed 's/Source:[[:space:]]*//' | tr -d '<>' | xargs)
  if [[ -n "$url" ]]; then
    sources["$name"]="$url"
  fi
done < <(find "$SCRIPT_DIR" -maxdepth 1 -name "claude-code-*.md" | sort)

# ── Build new cache JSON incrementally ────────────────────────────────────────

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
echo '{"files":{}}' > "$tmp"

changed=()
unchanged=()
failed=()
total=${#sources[@]}
i=0

echo "Checking $total reference files…"
echo ""

for name in $(echo "${!sources[@]}" | tr ' ' '\n' | sort); do
  url="${sources[$name]}"
  i=$((i + 1))
  printf "  [%2d/%2d] %-42s" "$i" "$total" "$name"

  cached_hash=$(echo "$cache" | jq -r --arg f "$name" '.files[$f].hash // ""')

  current_hash=$(fetch_and_hash "$url")

  if [[ -z "$current_hash" ]]; then
    printf "  ⚠  FETCH FAILED\n"
    failed+=("$name")
    # Preserve old hash in new cache so a failed fetch doesn't mark everything stale
    if [[ -n "$cached_hash" ]]; then
      jq --arg f "$name" --arg h "$cached_hash" --arg u "$url" \
        '.files[$f] = {"hash": $h, "url": $u}' "$tmp" > "${tmp}.new" \
        && mv "${tmp}.new" "$tmp"
    fi
    continue
  fi

  jq --arg f "$name" --arg h "$current_hash" --arg u "$url" \
    '.files[$f] = {"hash": $h, "url": $u}' "$tmp" > "${tmp}.new" \
    && mv "${tmp}.new" "$tmp"

  if [[ -z "$cached_hash" ]]; then
    printf "  ✦  NEW\n"
    changed+=("$name")
  elif [[ "$current_hash" != "$cached_hash" ]]; then
    printf "  ✗  CHANGED\n"
    changed+=("$name")
  else
    printf "  ✓\n"
    unchanged+=("$name")
  fi
done

# ── Fetch CHANGELOG version ────────────────────────────────────────────────────

echo ""
printf "  Fetching CHANGELOG version… "
current_version=$(fetch_version)
printf "%s\n" "$current_version"

# ── Summary ────────────────────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════════════════════════════════"

version_note=""
if [[ "$cached_version" != "none" && "$cached_version" != "$current_version" ]]; then
  version_note="  ← version changed"
fi

printf "  Claude Code version : %s → %s%s\n" \
  "$cached_version" "$current_version" "$version_note"
printf "  Cache timestamp     : %s\n" "$cached_timestamp"
printf "  Unchanged           : %d\n" "${#unchanged[@]}"
printf "  Changed / new       : %d\n" "${#changed[@]}"
[[ ${#failed[@]} -gt 0 ]] && printf "  Fetch failures      : %d\n" "${#failed[@]}"

if [[ ${#changed[@]} -gt 0 ]]; then
  echo ""
  echo "  Files that may need updating:"
  for f in "${changed[@]}"; do
    echo "    • $f"
    echo "      ${sources[$f]}"
  done
fi

if [[ ${#failed[@]} -gt 0 ]]; then
  echo ""
  echo "  Fetch failures (cached hashes preserved):"
  for f in "${failed[@]}"; do
    echo "    • $f  (${sources[$f]})"
  done
fi

echo "══════════════════════════════════════════════════════════════"
echo ""

# ── Write cache ────────────────────────────────────────────────────────────────

if $UPDATE; then
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  jq --arg v "$current_version" --arg t "$timestamp" \
    '. + {"version": $v, "timestamp": $t}' "$tmp" > "$CACHE_FILE"
  echo "Cache written → $CACHE_FILE"
  echo "(Commit this file to share the baseline with your team.)"
elif [[ ${#changed[@]} -gt 0 ]] || [[ ! -f "$CACHE_FILE" ]]; then
  echo "Run with --update after reviewing and updating the reference files."
fi
