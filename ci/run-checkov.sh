#!/usr/bin/env bash
set -euo pipefail

# ============================================
# CHECKOV - AUDITORÍA DE SEGURIDAD
# ============================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${ROOT_DIR}/.checkov.yaml"
RESULTS_FILE="${ROOT_DIR}/results.xml"

echo "=========================================="
echo "🔍 CHECKOV - Auditoría de Seguridad"
echo "=========================================="

cd "${ROOT_DIR}"

# ============================================
# EJECUTAR CHECKOV USANDO CONFIGURACIÓN
# ============================================

if [ -f "${CONFIG_FILE}" ]; then
  echo "✅ Usando configuración: ${CONFIG_FILE}"
  
  # Con Docker
  docker run --rm \
    -v "${ROOT_DIR}:/tf" \
    --workdir /tf \
    bridgecrew/checkov:3 \
    --config-file /tf/.checkov.yaml
  
  # Sin Docker (si tienes checkov instalado)
  # checkov --config-file .checkov.yaml
  
else
  echo "⚠️  No se encuentra .checkov.yaml"
  echo "ℹ️  Usando configuración por defecto..."
  
  docker run --rm \
    -v "${ROOT_DIR}:/tf" \
    --workdir /tf \
    bridgecrew/checkov:3 \
    --directory /tf/terraform \
    --quiet \
    --soft-fail \
    --output junitxml \
    --output-file-path /tf/results.xml
fi

# ============================================
# MOSTRAR RESULTADOS
# ============================================
echo ""
echo "=========================================="
echo "✅ CHECKOV FINALIZADO"
echo "=========================================="

if [ -f "${RESULTS_FILE}" ]; then
  ERROR_COUNT=$(grep -c "failure" "${RESULTS_FILE}" 2>/dev/null || echo "0")
  TOTAL_TESTS=$(grep -c "testcase" "${RESULTS_FILE}" 2>/dev/null || echo "0")
  
  echo "📊 TESTS: ${TOTAL_TESTS} | FALLOS: ${ERROR_COUNT}"
  
  if [ "${ERROR_COUNT}" -gt 0 ]; then
    echo ""
    echo "⚠️  Errores encontrados:"
    grep -B 1 "failure" "${RESULTS_FILE}" | grep "name" | sed 's/.*name="//' | sed 's/".*//' | sort -u
  else
    echo "✅ ¡Sin errores! 🎉"
  fi
fi