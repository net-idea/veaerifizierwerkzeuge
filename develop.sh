#!/bin/bash

# =============================================================
# develop.sh – Startet die lokale Entwicklungsumgebung
# VEA – Verifizierte Aerifizierwerkzeuge für Sportrasen
# =============================================================
set -euo pipefail

# Gibt eine farbige Meldung aus
info()  { echo -e "\033[0;32m[INFO]\033[0m  $*"; }
warn()  { echo -e "\033[0;33m[WARN]\033[0m  $*"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; }

# Zeigt die fehlerhafte Zeile bei Abbruch an
trap 'error "Abbruch in Zeile $LINENO – Exit-Code: $?"' ERR

# -------------------------------------------------------------
# 1. Voraussetzungen prüfen
# -------------------------------------------------------------
info "Prüfe Voraussetzungen..."

# Prüfe PHP 8.3+
if ! command -v php &>/dev/null; then
    error "PHP ist nicht installiert oder nicht im PATH."
    error "Bitte PHP 8.3 oder neuer installieren: https://www.php.net/downloads"
    exit 1
fi

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')
PHP_MAJOR=$(echo "$PHP_VERSION" | cut -d. -f1)
PHP_MINOR=$(echo "$PHP_VERSION" | cut -d. -f2)

if [ "$PHP_MAJOR" -lt 8 ] || { [ "$PHP_MAJOR" -eq 8 ] && [ "$PHP_MINOR" -lt 3 ]; }; then
    error "PHP 8.3 oder neuer wird benötigt (gefunden: PHP $PHP_VERSION)."
    error "Bitte PHP aktualisieren: https://www.php.net/downloads"
    exit 1
fi
info "PHP $PHP_VERSION gefunden – OK"

# Prüfe Composer
if ! command -v composer &>/dev/null; then
    error "Composer ist nicht installiert oder nicht im PATH."
    error "Installation: https://getcomposer.org/download/"
    exit 1
fi
info "Composer $(composer --version 2>/dev/null | head -1 | awk '{print $3}') gefunden – OK"

# Prüfe Symfony CLI (optional, aber empfohlen)
if ! command -v symfony &>/dev/null; then
    warn "Symfony CLI nicht gefunden. Es wird der eingebaute PHP-Server verwendet."
    warn "Empfehlung: Symfony CLI installieren – https://symfony.com/download"
    USE_SYMFONY_CLI=false
else
    info "Symfony CLI $(symfony version --short 2>/dev/null || echo '(Version unbekannt)') gefunden – OK"
    USE_SYMFONY_CLI=true
fi

# -------------------------------------------------------------
# 2. Composer-Abhängigkeiten installieren
# -------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d vendor ] || [ composer.lock -nt vendor/autoload.php ]; then
    info "Installiere Composer-Abhängigkeiten..."
    composer install --no-interaction
else
    info "vendor/ ist aktuell – überspringe composer install."
fi

# -------------------------------------------------------------
# 3. .env.local anlegen, falls nicht vorhanden
# -------------------------------------------------------------
if [ ! -f .env.local ]; then
    if [ -f .env.example ]; then
        cp .env.example .env.local
        info ".env.local aus .env.example erstellt. Bitte Werte anpassen!"
    else
        warn ".env.example nicht gefunden – .env.local wurde nicht erstellt."
    fi
else
    info ".env.local vorhanden – wird nicht überschrieben."
fi

# -------------------------------------------------------------
# 4. Assets kompilieren (dev-Modus)
# -------------------------------------------------------------
info "Kompiliere Assets (dev)..."
php bin/console asset-map:compile

# -------------------------------------------------------------
# 5. Entwicklungsserver starten
# -------------------------------------------------------------
info "Starte Entwicklungsserver..."

if [ "$USE_SYMFONY_CLI" = true ]; then
    info "Verwende Symfony CLI: symfony serve --no-tls"
    exec symfony serve --no-tls
else
    info "Verwende eingebauten PHP-Server auf http://127.0.0.1:8000"
    exec php -S 127.0.0.1:8000 -t public/
fi
