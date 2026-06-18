#!/usr/bin/env bash
set -euo pipefail

# === CONFIGURACIÓN ===
# Primer argumento: entorno (dev, prod, etc.). Por defecto dev.
ENVIRONMENT="${1:-dev}"

# Segundo argumento: acción (plan | apply). Por defecto "plan".
ACTION="${2:-plan}"

# Directorio raíz del repo
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT_DIR}/terraform/envs/${ENVIRONMENT}"

echo "=========================================="
echo "🚀 TERRAFORM - ENTORNO: ${ENVIRONMENT}"
echo "=========================================="
echo "Acción:  ${ACTION}"
echo "Carpeta: ${ENV_DIR}"

# Verificar que exista el directorio del entorno
if [ ! -d "${ENV_DIR}" ]; then
  echo "❌ ERROR: El directorio de entorno no existe: ${ENV_DIR}"
  echo "ℹ️  Directorios disponibles:"
  ls -la "${ROOT_DIR}/terraform/envs/" 2>/dev/null || echo "   (no se encontró la carpeta envs)"
  exit 1
fi

cd "${ENV_DIR}"

echo ""
echo "📂 Directorio actual: $(pwd)"
echo ""

# === TERRAFORM INIT ===
echo "📦 terraform init..."
terraform init -input=false -reconfigure

# === TERRAFORM VALIDATE ===
echo ""
echo "✅ terraform validate..."
terraform validate

# === VERIFICAR ARCHIVO DE VARIABLES ===
TFVARS_ARG=()
if [ -f "terraform.tfvars" ]; then
  echo "📝 Usando terraform.tfvars para el entorno ${ENVIRONMENT}"
  TFVARS_ARG=(-var-file="terraform.tfvars")
else
  echo "⚠️  ATENCIÓN: No se encontró terraform.tfvars"
  if [ -f "terraform.tfvars.example" ]; then
    echo "ℹ️  Puedes copiar terraform.tfvars.example a terraform.tfvars"
    echo "   cp terraform.tfvars.example terraform.tfvars"
  fi
  echo "ℹ️  Ejecutando con valores por defecto..."
fi

# === EJECUTAR ACCIÓN ===
echo ""
case "${ACTION}" in
  plan)
    echo "🔍 terraform plan (generando tfplan)..."
    terraform plan -input=false -out=tfplan "${TFVARS_ARG[@]}"
    echo ""
    echo "✅ Plan generado: tfplan"
    echo "💡 Para aplicar este plan ejecuta:"
    echo "   ./ci/terraform-plan.sh ${ENVIRONMENT} apply"
    ;;

  apply)
    if [ -f "tfplan" ]; then
      echo "📌 Se encontró tfplan existente. Aplicando ese plan..."
      terraform apply -input=false tfplan
    else
      echo "⚠️  No existe tfplan. Generando plan rápido antes del apply..."
      terraform plan -input=false -out=tfplan "${TFVARS_ARG[@]}"
      terraform apply -input=false tfplan
    fi
    echo ""
    echo "✅ Terraform apply finalizado correctamente."
    echo "💡 Para ver los outputs ejecuta:"
    echo "   terraform output"
    ;;

  destroy)
    echo "⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️"
    echo "   ¡¡¡ DESTRUYENDO INFRAESTRUCTURA !!!"
    echo "⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️"
    echo ""
    echo "¿Estás seguro? Escribe 'yes' para confirmar:"
    read -r CONFIRM
    if [ "${CONFIRM}" != "yes" ]; then
      echo "❌ Cancelado."
      exit 0
    fi
    terraform destroy -input=false "${TFVARS_ARG[@]}"
    echo ""
    echo "✅ Infraestructura destruida."
    ;;

  *)
    echo "❌ Acción no reconocida: ${ACTION}"
    echo "ℹ️  Opciones válidas: plan, apply, destroy"
    exit 1
    ;;
esac

echo ""
echo "=========================================="
echo "✅ TERRAFORM COMPLETADO"
echo "=========================================="