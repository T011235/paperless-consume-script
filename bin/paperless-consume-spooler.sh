#!/bin/bash

ENV_FILE="/etc/paperless-consume-spooler.env"
WATCH_DIRS=(
    "/your/watch/dir"
)

LOG_FILE="/var/log/paperless-consume-spooler.log"

if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
else
    echo "ENV-Datei nicht gefunden: $ENV_FILE" | tee -a "$LOG_FILE"
    exit 1
fi

if [[ -z "$API_TOKEN" || -z "$PAPERLESS_URL" ]]; then
    echo "API_TOKEN oder PAPERLESS_URL nicht gesetzt." | tee -a "$LOG_FILE"
    exit 1
fi

upload_file() {
    local FILE="$1"
    local TITLE
    TITLE="$(basename "$FILE")"

    echo "[$(date)] Warte 10 Sekunden auf Datei-Stabilisierung: $FILE" >> "$LOG_FILE"
    sleep 10

    if [[ ! -f "$FILE" ]]; then
        echo "[$(date)] Datei existiert nicht mehr nach sleep: $FILE" >> "$LOG_FILE"
        return
    fi

    echo "[$(date)] Versuche Upload: $FILE" >> "$LOG_FILE"

    RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/paperless_response.json \
        -X POST "$PAPERLESS_URL/api/documents/post_document/" \
        -H "Authorization: Token $API_TOKEN" \
        -F "document=@$FILE" \
        -F "title=$TITLE")

    if [[ "$RESPONSE" -eq 200 ]]; then
        echo "[$(date)] Erfolgreich hochgeladen: $TITLE" >> "$LOG_FILE"
        rm -f "$FILE"
    else
        echo "[$(date)] Fehler beim Upload ($RESPONSE): $FILE" >> "$LOG_FILE"
        cat /tmp/paperless_response.json >> "$LOG_FILE"
    fi
}

start_watching() {
    echo "[$(date)] Starte inotifywait für: ${WATCH_DIRS[*]}" >> "$LOG_FILE"
    inotifywait -m -e close_write,moved_to --format '%w%f' "${WATCH_DIRS[@]}" |
    while read FILE; do
        if [[ -f "$FILE" ]]; then
            upload_file "$FILE" &
        fi
    done
}

start_watching
