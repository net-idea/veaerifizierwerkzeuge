#!/bin/bash

# =============================================================
# deploy.sh – Deployment-Skript für Produktionsumgebung
# VEA – Verifizierte Aerifizierwerkzeuge für Sportrasen
# =============================================================
set -euo pipefail

# Gibt eine farbige Meldung aus
info()    { echo -e "\033[0;32m[INFO]\033[0m    $*"; }
success() { echo -e "\033[0;36m[SUCCESS]\033[0m $*"; }
warn()    { echo -e "\033[0;33m[WARN]\033[0m    $*"; }
error()   { echo -e "\033[0;31m[ERROR]\033[0m   $*" >&2; }

# Zeigt die fehlerhafte Zeile bei Abbruch an
trap 'error "Deployment abgebrochen in Zeile $LINENO – Exit-Code: $?"' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# -------------------------------------------------------------
# 1. Optionalen SSH-Ziel-Host ermitteln
# -------------------------------------------------------------
SSH_HOST="${1:-}"

# Falls kein Parameter übergeben wurde, .deploy.env prüfen
if [ -z "$SSH_HOST" ] && [ -f .deploy.env ]; then
    # shellcheck source=/dev/null
    source .deploy.env
    SSH_HOST="${DEPLOY_HOST:-}"
fi

if [ -n "$SSH_HOST" ]; then
    info "Deployment-Ziel: $SSH_HOST"
    REMOTE_DEPLOY=true
else
    info "Kein SSH-Host angegeben – lokales Deployment."
    REMOTE_DEPLOY=false
fi

# -------------------------------------------------------------
# 2. Umgebungsvariablen setzen
# -------------------------------------------------------------
export APP_ENV=prod
export APP_DEBUG=0
info "APP_ENV=prod, APP_DEBUG=0 gesetzt."

# -------------------------------------------------------------
# 3. Composer-Abhängigkeiten (Produktion)
# -------------------------------------------------------------
info "Installiere Composer-Abhängigkeiten (Produktion)..."
composer install \
    --no-dev \
    --optimize-autoloader \
    --classmap-authoritative \
    --no-interaction

# -------------------------------------------------------------
# 4. Cache leeren und aufwärmen
# -------------------------------------------------------------
info "Leere Symfony-Cache..."
php bin/console cache:clear --env=prod --no-debug

info "Wärme Cache auf..."
php bin/console cache:warmup --env=prod --no-debug

# -------------------------------------------------------------
# 5. Assets produktiv kompilieren
# -------------------------------------------------------------
info "Kompiliere Assets (prod)..."
php bin/console asset-map:compile

# -------------------------------------------------------------
# 6. Berechtigungen für var/ setzen
# -------------------------------------------------------------
info "Setze Berechtigungen für var/..."
if [ -d var ]; then
    chmod -R 775 var/
fi

# .env.local NIEMALS überschreiben – Sicherheitshinweis ausgeben
if [ -f .env.local ]; then
    info ".env.local ist vorhanden und wird NICHT verändert."
else
    warn ".env.local fehlt! Bitte APP_SECRET und CONTACT_* Variablen setzen."
fi

# -------------------------------------------------------------
# 7. Zusammenfassung ausgeben
# -------------------------------------------------------------
DEPLOY_DATE=$(date "+%Y-%m-%d %H:%M:%S %Z")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unbekannt")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unbekannt")

echo ""
success "============================================="
success "  Deployment erfolgreich abgeschlossen!"
success "============================================="
echo ""
info "Datum:         $DEPLOY_DATE"
info "Git-Commit:    $GIT_COMMIT"
info "Git-Branch:    $GIT_BRANCH"
info "Umgebung:      $APP_ENV"
if [ "$REMOTE_DEPLOY" = true ]; then
    info "SSH-Ziel:      $SSH_HOST"
fi
echo ""
