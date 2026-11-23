#!/usr/bin/env bash
# Met à jour atomic.dlchost.com avec la dernière version du dépôt GitHub.
#
# À lancer régulièrement avec cron, par exemple toutes les 5 minutes :
#   */5 * * * * /opt/atomic/mise-a-jour-site.sh >> /var/log/atomic-maj.log 2>&1
#
# Le script ne télécharge rien tant que le dernier commit de la branche n'a
# pas changé. Réglages possibles par variables d'environnement :
#   SITE_DIR    dossier servi par le serveur web (obligatoire en pratique)
#   REPO        dépôt GitHub source            (défaut : dlctheo181234/Atomic-Orbital)
#   BRANCH      branche suivie                 (défaut : main)
#   FILES       fichiers à copier              (défaut : index.html)
#   STATE_FILE  où retenir la version installée (défaut : ~/.atomic-site-version)

set -euo pipefail

REPO="${REPO:-dlctheo181234/Atomic-Orbital}"
BRANCH="${BRANCH:-main}"
SITE_DIR="${SITE_DIR:-/var/www/atomic}"
FILES="${FILES:-index.html}"
STATE_FILE="${STATE_FILE:-$HOME/.atomic-site-version}"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }

# Un seul passage à la fois, même si cron relance pendant un téléchargement lent
if command -v flock >/dev/null 2>&1; then
  exec 9>"${TMPDIR:-/tmp}/atomic-mise-a-jour.lock"
  flock -n 9 || exit 0
fi

# Identifiant (SHA) du dernier commit, en texte brut grâce à ce type de réponse.
# Les nouvelles tentatives couvrent les ratés ponctuels (DNS, réseau).
latest=$(curl -fsS --max-time 20 --retry 3 --retry-delay 5 --retry-all-errors \
  -H "Accept: application/vnd.github.sha" \
  "https://api.github.com/repos/$REPO/commits/$BRANCH")

if [[ ! "$latest" =~ ^[0-9a-f]{40}$ ]]; then
  log "Réponse inattendue de GitHub, rien n'est modifié : $latest"
  exit 1
fi

installed=$(cat "$STATE_FILE" 2>/dev/null || true)
if [[ "$latest" == "$installed" ]]; then
  exit 0
fi

# Téléchargement dans un dossier temporaire du même disque que le site,
# pour que le remplacement final (mv) soit instantané
tmp=$(mktemp -d "$SITE_DIR/.maj-XXXXXX")
trap 'rm -rf "$tmp"' EXIT

for f in $FILES; do
  mkdir -p "$tmp/$(dirname "$f")"
  # Fichiers du commit exact, pas de « main », pour éviter le cache de GitHub
  curl -fsS --max-time 60 --retry 3 --retry-delay 5 --retry-all-errors \
    "https://raw.githubusercontent.com/$REPO/$latest/$f" -o "$tmp/$f"
  if [[ ! -s "$tmp/$f" ]]; then
    log "Fichier vide reçu pour $f, mise à jour annulée."
    exit 1
  fi
  if [[ "$f" == *.html ]] && ! grep -qi "</html>" "$tmp/$f"; then
    log "$f semble incomplet, mise à jour annulée."
    exit 1
  fi
done

for f in $FILES; do
  mkdir -p "$SITE_DIR/$(dirname "$f")"
  chmod 644 "$tmp/$f"
  mv -f "$tmp/$f" "$SITE_DIR/$f"
done

echo "$latest" > "$STATE_FILE"
log "Site mis à jour : ${installed:0:7}${installed:+ → }${latest:0:7}"
