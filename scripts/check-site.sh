#!/usr/bin/env bash
# Builds the site and asserts that each page renders the content it promises.
# Any Hugo warning fails the build. Set HUGO to use a specific binary.
set -euo pipefail

cd "$(dirname "$0")/.."
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

"${HUGO:-hugo}" --panicOnWarning --minify -d "$out" >/dev/null

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$out/$1" text="$2"
  [[ -f "$file" ]] || fail "$1 was not built"
  grep -qF -- "$text" "$file" || fail "$1 does not contain: $text"
}

assert_absent_everywhere() {
  local text="$1" hits
  hits="$(grep -rlF -- "$text" "$out" || true)"
  [[ -z "$hits" ]] || fail "found '$text' in: ${hits//$out\//}"
}

# Base layout
assert_contains index.html 'class=sidebar'
assert_contains index.html 'JetBrains+Mono'
assert_absent_everywhere 'PaperMod'

# Home
for text in 'I build software that leaves the building.' 'ls shipped/' 'cat leadership.md' \
  'cat ai.md' 'git log --career' 'cat principles.txt' 'Kind and direct.' 'NetBox Labs' '500k+'; do
  assert_contains index.html "$text"
done

echo "PASS: site checks"
