#!/usr/bin/env bash
# =============================================================================
# ci/sonar-scan.sh — Ejecuta SonarScanner CLI sobre EduCloud
# Uso local:
#   export SONAR_TOKEN=sqa_xxx
#   ./ci/sonar-scan.sh
# En CI el token viene de los secretos del pipeline, no hace falta exportarlo
# =============================================================================

set -euo pipefail

# ─── Colores ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; CYAN='\033[0;36m'; RED='\033[0;31m'; RESET='\033[0m'
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }

# ─── Validaciones ─────────────────────────────────────────────────────────────
[[ -z "${SONAR_TOKEN:-}" ]]    && error "Variable SONAR_TOKEN no definida."
[[ -z "${SONAR_HOST_URL:-}" ]] && error "Variable SONAR_HOST_URL no definida."

# ─── Raíz del proyecto (un nivel arriba de ci/) ───────────────────────────────
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[[ -f "$PROJECT_DIR/sonar-project.properties" ]] \
  || error "sonar-project.properties no encontrado en $PROJECT_DIR"

info "Proyecto  : $PROJECT_DIR"
info "Servidor  : $SONAR_HOST_URL"
info "Ejecutando SonarScanner CLI..."

docker run --rm \
  -e SONAR_HOST_URL="$SONAR_HOST_URL" \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -v "$PROJECT_DIR:/usr/src" \
  sonarsource/sonar-scanner-cli

success "Análisis completado → $SONAR_HOST_URL/dashboard?id=educloud"