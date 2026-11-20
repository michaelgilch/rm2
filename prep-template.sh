#!/bin/bash
#
# Prepare a custom reMarkable Methods template for installation by creating the
# necessary UUID and files.
#
# Takes in a JSON <filename>.template, to be installed as a Methods template.
# Creates a UUID from the template's 'name' field.
# Writes out/<uuid>.template, out/<uuid>.content and out/<uuid>.metadata.
#
#   <uuid>.template   A copy of the given .template, rewritten on every run.
#   <uuid>.content    An empty JSON object.
#   <uuid>.metadata   Written only if missing, so edits are retained.
#
# The UUID is derived from the template's "name", so the same name always gives
# the same UUID and a reinstall replaces the template on the tablet.
#
# Usage: tools/prep-template.sh <file.template>

set -eu
SRC=${1:-}
[ -f "$SRC" ] || { echo "usage: $0 <file.template>"; exit 2; }
OUT=$PWD/out

# Parse the name from the JSON template
NAME=$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["name"])' "$SRC")
# Construct a UUID for the template's name field with a namespace UUID
UUID=$(python3 -c 'import sys, uuid
print(uuid.uuid5(uuid.UUID("6f0e1c6e-6b0b-4a57-9a5e-0d2f6c1f3b11"), sys.argv[1]))' "$NAME")

mkdir -p "$OUT"
cp "$SRC" "$OUT/$UUID.template"
printf '{\n}\n' > "$OUT/$UUID.content"

if [ -e "$OUT/$UUID.metadata" ]; then
  echo "Kept the existing $UUID.metadata; delete it to regenerate."
else
  NOW=$(date +%s%3N)
  cat > "$OUT/$UUID.metadata" <<EOF
{
    "createdTime": "$NOW",
    "lastModified": "$NOW",
    "new": false,
    "parent": "",
    "pinned": false,
    "source": "michaelgilch.custom",
    "type": "TemplateType",
    "visibleName": "$NAME"
}
EOF
fi

XDIR=/home/root/.local/share/remarkable/xochitl
cat <<DONE
UUID=$UUID   ("$NAME")

Edit .metadata to customize before installing on ReMarkable.
  scp $OUT/$UUID.template $OUT/$UUID.content $OUT/$UUID.metadata root@10.11.99.1:$XDIR/
  ssh root@10.11.99.1 "systemctl restart xochitl"
DONE
