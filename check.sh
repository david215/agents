#!/bin/sh
# Regression guard, not a test suite. Each check exists because the thing it looks for
# already shipped broken once and no amount of re-reading caught it. Run before committing.
set -u
LOG=$(mktemp)
say() { printf '%s\n' "$*" >> "$LOG"; }

# 1. BSD grep has no -P and exits 2 on it — not the exit 1 that means "no match" — so a PCRE
#    pattern silently stops checking anything on macOS while still looking like it ran.
#    Match invocation shapes only, so prose naming the ban does not trip it.
grep -rnE '(^|\| *)grep -[A-Za-z]*P ' skills/ 2>/dev/null \
  && say "grep -P is not portable. Match raw bytes instead."

# 2. wc -m counts characters only in a UTF-8 locale; under LC_ALL=C — the default in Docker,
#    cron and most CI — it counts bytes, silently becoming the wc -c it was meant to replace.
grep -rn 'wc -m' skills/ 2>/dev/null | grep -vE 'LC_ALL|never .wc -m|not .wc -m|`wc -m`' \
  && say "wc -m needs an explicit UTF-8 locale prefix."

# 3. Every skill needs SKILL.md with frontmatter, and an agents/openai.yaml — without the
#    latter, a disable-model-invocation choice is contradicted for non-Claude agents.
for d in skills/*/; do
  n=$(basename "$d")
  [ -f "$d/SKILL.md" ] || { say "$n has no SKILL.md"; continue; }
  grep -q '^name:' "$d/SKILL.md" || say "$n SKILL.md has no name:"
  grep -q '^description:' "$d/SKILL.md" || say "$n SKILL.md has no description:"
  [ -f "$d/agents/openai.yaml" ] || say "$n has no agents/openai.yaml"
done

# 4. Relative links resolve from the directory of the file holding them. A deleted seed leaves
#    a pointer that still reads perfectly well. CONTEXT-FORMAT.md is skipped: its ./src/... links
#    illustrate a consumer repo's tree, not this one.
for f in $(find skills/ -name '*.md' ! -name 'CONTEXT-FORMAT.md'); do
  for t in $(grep -oE '\]\(\./[^)]+\)' "$f" 2>/dev/null | sed -E 's/^\]\(\.\///; s/\)$//'); do
    [ -f "$(dirname "$f")/$t" ] || say "$f links to ./$t, which does not exist"
  done
done

# 5. Nothing may point at a doc the setup skills no longer generate.
grep -rn 'docs/agents/findings' skills/ README.md 2>/dev/null \
  && say "docs/agents/findings.md is not generated any more."

# 6. Minimal provenance (house-rules §6): a skill states the failure mode, not the story of
#    learning it. pr/hosts/ is excluded — a host's measured cap is a fact about the world.
#    No space before the punctuation: the text is "Measured:", not "Measured :".
grep -rnE '[Mm]easured(:| on )' skills/ 2>/dev/null | grep -v 'pr/hosts/' \
  && say "Provenance in a skill. State the failure mode; git log -S recovers the incident."

if [ -s "$LOG" ]; then cat "$LOG"; rm -f "$LOG"; exit 1; fi
rm -f "$LOG"; echo "ok"
