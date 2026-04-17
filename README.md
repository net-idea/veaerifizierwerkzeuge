# VEA – Verifizierte Aerifizierwerkzeuge für Sportrasen

Offizielle Landingpage der Firma **VEA – Verifizierte Aerifizierwerkzeuge für Sportrasen**
([veaerifizierwerkzeuge.com](https://veaerifizierwerkzeuge.com)).

Gebaut mit Symfony 7 (PHP 8.3+), Twig und AssetMapper – ohne schwere UI-Frameworks,
DSGVO-freundlich und responsiv.

---

## Voraussetzungen

| Software | Mindestversion |
|---|---|
| PHP | 8.3 |
| Composer | 2.x |
| Symfony CLI | optional, empfohlen |

---

## Installation

```bash
# 1. Repository klonen
git clone https://github.com/net-idea/veaerifizierwerkzeuge.git
cd veaerifizierwerkzeuge

# 2. Abhängigkeiten installieren
composer install

# 3. Umgebungsdatei anlegen
cp .env.example .env.local
# → .env.local öffnen und Variablen anpassen
```

---

## Entwicklung

### Schnellstart (empfohlen)

```bash
chmod +x develop.sh
./develop.sh
```

Das Skript prüft alle Voraussetzungen, installiert Abhängigkeiten und startet den
Entwicklungsserver auf **http://127.0.0.1:8000**.

### Manuell

```bash
composer install
php bin/console asset-map:compile
symfony serve --no-tls        # mit Symfony CLI
# oder:
php -S 127.0.0.1:8000 -t public/   # ohne Symfony CLI
```

---

## Konfiguration

### Kontaktdaten

Die in der Website angezeigten Kontaktdaten werden über Umgebungsvariablen konfiguriert:

| Variable | Beschreibung | Beispiel |
|---|---|---|
| `APP_ENV` | Symfony-Umgebung | `dev` / `prod` |
| `APP_SECRET` | Geheimschlüssel | 32+ zufällige Zeichen |
| `CONTACT_EMAIL` | Kontakt-E-Mail | `info@example.com` |
| `CONTACT_PHONE` | Telefonnummer | `+49 000 000000` |
| `CONTACT_ADDRESS` | Postanschrift | `Musterstr. 1, 00000 Ort` |

Alle Variablen sind in `.env.example` dokumentiert.

---

## Deployment

```bash
chmod +x deploy.sh

# Lokales Deployment (Produktions-Build)
./deploy.sh

# Mit SSH-Ziel (aus .deploy.env oder als Parameter)
./deploy.sh user@mein-server.de
```

Bevor das Deployment ausgeführt wird:
- `.env.local` mit den Produktionswerten anlegen (wird nie überschrieben)
- `APP_SECRET` auf einen sicheren Zufallswert setzen
- Webserver auf `public/` als Document-Root konfigurieren

---

## Projektstruktur

```
├── assets/
│   ├── images/          SVG-Platzhalter (Logos, Produkticons)
│   ├── styles/
│   │   └── app.css      Hauptstylesheet (responsiv, mobile-first)
│   └── app.js           Asset-Einstiegspunkt
├── config/
│   ├── packages/
│   │   ├── asset_mapper.yaml
│   │   ├── framework.yaml
│   │   └── twig.yaml    Globaler `app_contact`-Parameter
│   └── services.yaml
├── public/
│   ├── index.php        Symfony-Front-Controller
│   ├── robots.txt       SEO: Crawler-Anweisungen
│   └── sitemap.xml      SEO: Sitemap
├── src/
│   ├── Controller/
│   │   ├── HomeController.php   GET / → Landingpage
│   │   └── LegalController.php  GET /impressum, /datenschutz
│   └── Kernel.php
├── templates/
│   ├── base.html.twig           Basis-Layout mit Header, Footer, Cookie-Banner
│   ├── home/
│   │   └── index.html.twig      Landingpage (Hero, Über uns, Sortiment, Qualität, Kontakt)
│   └── legal/
│       ├── impressum.html.twig  Impressum-Platzhalter (§ 5 TMG TODO)
│       └── datenschutz.html.twig Datenschutz-Platzhalter (DSGVO Art. 13 TODO)
├── .env.example         Dokumentierte Umgebungsvariablen
├── develop.sh           Entwicklungsserver-Skript
├── deploy.sh            Deployment-Skript
└── README.md            Diese Datei
```

---

## Rechtliche Hinweise

Die Templates `impressum.html.twig` und `datenschutz.html.twig` enthalten `TODO`-Platzhalter,
die vor dem Live-Betrieb mit den tatsächlichen Pflichtangaben gemäß **§ 5 TMG** und
**DSGVO Art. 13** ausgefüllt werden müssen.

⚠️ Es wird empfohlen, einen Rechtsanwalt oder Datenschutzbeauftragten hinzuzuziehen.
