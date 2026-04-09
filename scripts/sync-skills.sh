#!/usr/bin/env bash
#
# sync-skills.sh
#
# Syncs a single skill file's content to its downstream counterpart.
# - Preserves the downstream file's front matter (the YAML block between --- markers).
# - Strips skill-repo-only comments (blocks delimited by /~~ ... ~/).
# - Replaces only the body content after the front matter.
#
# Usage:
#   sync-skills.sh <skill-file> <downstream-file>

set -euo pipefail

SKILL_FILE="$1"
DOWNSTREAM_FILE="$2"

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "Error: Skill file not found: $SKILL_FILE"
  exit 1
fi

if [[ ! -f "$DOWNSTREAM_FILE" ]]; then
  echo "Error: Downstream file not found: $DOWNSTREAM_FILE"
  exit 1
fi

echo "Syncing: $SKILL_FILE -> $DOWNSTREAM_FILE"

# Extract body from skill file (everything after front matter), then strip comments
SKILL_CONTENT="$(awk '
  BEGIN { in_fm = 0; fm_count = 0; body = "" }
  {
    if ($0 == "---") {
      fm_count++
      if (fm_count == 1) { in_fm = 1; next }
      if (fm_count == 2) { in_fm = 0; next }
    }
    if (in_fm) next
    if (fm_count >= 2) print
  }
' "$SKILL_FILE")"

# Strip /~~ ... ~/ comment blocks
SKILL_CONTENT="$(echo "$SKILL_CONTENT" | awk '
  BEGIN { in_comment = 0 }
  /^\/~~/ { in_comment = 1; next }
  /^~\// { in_comment = 0; next }
  { if (!in_comment) print }
')"

# Extract existing front matter from downstream file
DOWNSTREAM_FM="$(awk '
  BEGIN { in_fm = 0; fm_count = 0 }
  {
    if ($0 == "---") {
      fm_count++
      print
      if (fm_count == 2) exit
      in_fm = 1
      next
    }
    if (in_fm) print
  }
' "$DOWNSTREAM_FILE")"

# Combine downstream front matter with new body content
{
  echo "$DOWNSTREAM_FM"
  echo "$SKILL_CONTENT"
} > "$DOWNSTREAM_FILE"

echo "  Updated: $DOWNSTREAM_FILE"
