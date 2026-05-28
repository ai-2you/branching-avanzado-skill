#!/usr/bin/env bash
# install.sh — Instalador del skill branching-avanzado para Claude Code
set -euo pipefail

SKILL_NAME="branching-avanzado"
REPO_URL="${BRANCHING_SKILL_REPO:-https://github.com/yosnap/branching-avanzado-skill}"
GLOBAL_DIR="$HOME/.claude/skills/$SKILL_NAME"
LOCAL_DIR=".claude/skills/$SKILL_NAME"

usage() {
  echo "Uso: $0 [--local] [--update] [--uninstall] [--version]"
  echo ""
  echo "  --local      Instalar solo en el proyecto actual (.claude/skills/)"
  echo "  --update     Actualizar a la última versión (global o local según exista)"
  echo "  --uninstall  Eliminar el skill"
  echo "  --version    Mostrar versión instalada"
  echo ""
  echo "Sin flags: instala globalmente (~/.claude/skills/)"
  echo ""
  echo "One-liner:"
  echo "  curl -sSL https://raw.githubusercontent.com/yosnap/branching-avanzado-skill/main/scripts/install.sh | bash"
}

check_deps() {
  if ! command -v git >/dev/null 2>&1; then
    echo "✗ git no está instalado. Instálalo desde https://git-scm.com/"
    exit 1
  fi
}

show_version() {
  local installed_dir=""
  [[ -d "$GLOBAL_DIR" ]] && installed_dir="$GLOBAL_DIR"
  [[ -d "$LOCAL_DIR" ]]  && installed_dir="$LOCAL_DIR"
  if [[ -z "$installed_dir" ]]; then
    echo "$SKILL_NAME: no instalado"
    exit 0
  fi
  local ver
  ver=$(git -C "$installed_dir" describe --tags --abbrev=0 2>/dev/null || echo "sin-tag")
  echo "$SKILL_NAME $ver (en $installed_dir)"
}

install_global() {
  if [[ -d "$GLOBAL_DIR" ]]; then
    echo "✓ El skill ya está instalado globalmente en $GLOBAL_DIR"
    echo "  Usa --update para actualizar."
    exit 0
  fi
  echo "→ Instalando $SKILL_NAME globalmente..."
  git clone "$REPO_URL" "$GLOBAL_DIR"
  echo "✓ Instalado en $GLOBAL_DIR"
  echo "  Activa con: /branching-avanzado en cualquier proyecto con Claude Code"
}

install_local() {
  local toplevel
  toplevel=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
  if [[ -z "$toplevel" ]]; then
    echo "⚠ No estás en un repositorio git. Instala desde la raíz del proyecto."
    exit 1
  fi
  if [[ -d "$LOCAL_DIR" ]]; then
    echo "✓ El skill ya está instalado localmente en $LOCAL_DIR"
    echo "  Usa --update para actualizar."
    exit 0
  fi
  echo "→ Instalando $SKILL_NAME en el proyecto actual..."
  mkdir -p ".claude/skills"
  git clone "$REPO_URL" "$LOCAL_DIR"
  echo "✓ Instalado en $LOCAL_DIR"
  echo ""
  echo "  Para compartir con el equipo: commitea .claude/skills/$SKILL_NAME/"
  echo "  Para uso personal: agrega .claude/skills/ a .gitignore"
}

update_skill() {
  local target=""
  [[ -d "$GLOBAL_DIR" ]] && target="$GLOBAL_DIR"
  [[ -d "$LOCAL_DIR" ]]  && target="$LOCAL_DIR"
  if [[ -z "$target" ]]; then
    echo "✗ El skill no está instalado. Ejecuta el script sin flags para instalar."
    exit 1
  fi
  echo "→ Actualizando $SKILL_NAME en $target..."
  git -C "$target" pull origin main
  local ver
  ver=$(git -C "$target" describe --tags --abbrev=0 2>/dev/null || echo "sin-tag")
  echo "✓ Actualizado a $ver"
}

uninstall_skill() {
  local removed=0
  if [[ -d "$GLOBAL_DIR" ]]; then
    rm -rf "$GLOBAL_DIR"
    echo "✓ Desinstalado de $GLOBAL_DIR"
    removed=1
  fi
  if [[ -d "$LOCAL_DIR" ]]; then
    rm -rf "$LOCAL_DIR"
    echo "✓ Desinstalado de $LOCAL_DIR"
    removed=1
  fi
  if [[ $removed -eq 0 ]]; then
    echo "✗ El skill no está instalado."
    exit 1
  fi
}

# Verificar dependencias antes de cualquier operación
check_deps

# Parseo de argumentos
MODE="global"
for arg in "$@"; do
  case "$arg" in
    --local)     MODE="local" ;;
    --update)    MODE="update" ;;
    --uninstall) MODE="uninstall" ;;
    --version)   MODE="version" ;;
    --help|-h)   usage; exit 0 ;;
    *) echo "Flag desconocido: $arg"; usage; exit 1 ;;
  esac
done

case "$MODE" in
  global)    install_global ;;
  local)     install_local ;;
  update)    update_skill ;;
  uninstall) uninstall_skill ;;
  version)   show_version ;;
esac
