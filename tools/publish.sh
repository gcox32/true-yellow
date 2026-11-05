#!/usr/bin/env bash
# Upload the built ROM to Vercel Blob, replacing any copy already there.
# Run it with `make publish`, which rebuilds the ROM first.
#
# Reads from .env (git-ignored):
#   BLOB_READ_WRITE_TOKEN  selects the store and authorizes the write
#   BLOB_DIR               folder within the store, no leading or trailing slash
set -euo pipefail
cd "$(dirname "$0")/.."

rom=pokeyellow.gbc

if [ -f .env ]; then
	set -a
	. ./.env
	set +a
fi
: "${BLOB_READ_WRITE_TOKEN:?missing from .env}"
: "${BLOB_DIR:?missing from .env}"

# The CLI version is pinned because its flags differ from Vercel's docs (--force
# here, --allow-overwrite there). The short max-age stops the default 30-day cache
# from serving an old ROM after an overwrite.
npx --yes vercel@65.11.0 blob put "$rom" \
	--rw-token "$BLOB_READ_WRITE_TOKEN" \
	--pathname "$BLOB_DIR/$rom" \
	--access public \
	--content-type application/octet-stream \
	--cache-control-max-age 60 \
	--force
