#!/bin/bash
# Melina Bakes — SSL Certificate Generator
# Generates a self-signed cert for local dev, or instructions for Let's Encrypt.
#
# Usage:
#   bash scripts/generate_ssl_certs.sh [dev|prod]
#   dev  — Self-signed cert for localhost (./docker/nginx/ssl/)
#   prod — Instructions for Let's Encrypt certbot

set -euo pipefail

MODE="${1:-dev}"
SSL_DIR="docker/nginx/ssl"

mkdir -p "$SSL_DIR"

if [ "$MODE" = "dev" ]; then
  echo "=== Generating self-signed certificate for local development ==="
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/key.pem" \
    -out "$SSL_DIR/cert.pem" \
    -subj "/C=UG/L=Kampala/O=Melina Bakes/CN=localhost"
  echo "=== Done: cert.pem and key.pem written to $SSL_DIR ==="
  echo ""
  echo "NOTE: This is a SELF-SIGNED certificate. Browsers will show a warning."
  echo "      For development this is fine. For production, use 'prod' mode."

elif [ "$MODE" = "prod" ]; then
  echo "=== Production — Let's Encrypt via Certbot ==="
  echo ""
  echo "Run the following commands on your production server:"
  echo ""
  echo "  # Install certbot"
  echo "  sudo apt-get install -y certbot python3-certbot-nginx"
  echo ""
  echo "  # Obtain certificate"
  echo "  sudo certbot certonly --standalone -d melinabakes.com -d www.melinabakes.com"
  echo ""
  echo "  # Copy to Docker SSL directory"
  echo "  sudo cp /etc/letsencrypt/live/melinabakes.com/fullchain.pem docker/nginx/ssl/cert.pem"
  echo "  sudo cp /etc/letsencrypt/live/melinabakes.com/privkey.pem docker/nginx/ssl/key.pem"
  echo ""
  echo "  # Auto-renewal: certbot renews as a systemd timer by default"
  echo "  sudo systemctl list-timers | grep certbot"
  echo ""
  echo "  # Add a post-renewal hook to copy certs into Docker volume"
  echo "  echo 'cp /etc/letsencrypt/live/melinabakes.com/fullchain.pem /opt/melina_bakes/docker/nginx/ssl/cert.pem' |"
  echo "  echo 'cp /etc/letsencrypt/live/melinabakes.com/privkey.pem /opt/melina_bakes/docker/nginx/ssl/key.pem' |"
  echo "  echo 'docker compose - /opt/melina_bakes/docker/docker-compose.prod.yml restart nginx' |"
  echo "  sudo tee /etc/letsencrypt/renewal-hooks/deploy/melina_bakes.sh > /dev/null"
  echo "  sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/melina_bakes.sh"

else
  echo "Usage: bash scripts/generate_ssl_certs.sh [dev|prod]"
  exit 1
fi