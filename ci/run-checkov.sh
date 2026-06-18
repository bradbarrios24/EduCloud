#!/usr/bin/env bash
set -euo pipefail

# === CONFIGURACIÓN ===
# Ruta al root del repo (donde está la carpeta terraform)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${ROOT_DIR}/terraform"

echo "=========================================="
echo "🔍 EJECUTANDO CHECKOV - AUDITORÍA DE SEGURIDAD"
echo "=========================================="
echo "Directorio raíz: ${ROOT_DIR}"
echo "Directorio Terraform: ${TERRAFORM_DIR}"

# Verificar que exista la carpeta terraform
if [ ! -d "${TERRAFORM_DIR}" ]; then
  echo "❌ ERROR: No se encuentra la carpeta terraform en: ${TERRAFORM_DIR}"
  exit 1
fi

cd "${TERRAFORM_DIR}"

echo ""
echo "📂 Escaneando: $(pwd)"
echo ""

# === EJECUTAR CHECKOV ===
# -d: directorio a escanear
# --quiet: salida menos verbosa
# --soft-fail: NO falla el pipeline (solo reporta)
# -o junitxml: formato de salida para Jenkins/CI
# --output-file-path: guardar resultado en archivo

echo "📊 Ejecutando Checkov con formato JUnit XML..."
checkov -d . --quiet --soft-fail -o junitxml --output-file-path "${ROOT_DIR}/results.xml"

echo ""
echo "=========================================="
echo "✅ CHECKOV FINALIZADO"
echo "=========================================="
echo "📄 Resultados guardados en: ${ROOT_DIR}/results.xml"
echo "💡 Revisa el archivo results.xml para ver los hallazgos"

# Mostrar resumen rápido (si checkov tiene comando de resumen)
echo ""
echo "📋 Resumen rápido:"
checkov -d . --quiet --soft-fail --summary 2>/dev/null || echo "   (resumen no disponible en esta versión)"

echo ""
echo "🔍 Para ver los errores en detalle:"
echo "   cat ${ROOT_DIR}/results.xml | grep -A 5 'failure'"