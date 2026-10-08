#!/usr/bin/env bash
set -euo pipefail

export DEPLOY_ENV="$1"
export IMAGE="$2"
COMMIT="$3"

case "$DEPLOY_ENV" in
  qa) export DOMAIN="qa.gerardalmenares.com" ;;
  prod) export DOMAIN="gerardalmenares.com" ;;
  *) echo "Invalid environment"; exit 1 ;;
esac

export DOCKER_CONFIG="$HOME/.docker-ci"
trap 'docker logout ghcr.io >/dev/null 2>&1 || true' EXIT

cd "$HOME/deploy-$DEPLOY_ENV"

docker compose -p "secure-$DEPLOY_ENV" config -q
docker compose -p "secure-$DEPLOY_ENV" pull
docker compose -p "secure-$DEPLOY_ENV" up -d --wait --wait-timeout 90

printf 'IMAGE=%s\nDEPLOY_ENV=%s\nDOMAIN=%s\n' \
  "$IMAGE" "$DEPLOY_ENV" "$DOMAIN" > .env

curl --retry 18 --retry-delay 5 --retry-all-errors \
  --max-time 10 -fsS "https://$DOMAIN/revision.txt" > deployed-revision.txt

test "$(cat deployed-revision.txt)" = "$COMMIT"
echo "Verified https://$DOMAIN at commit $COMMIT"
