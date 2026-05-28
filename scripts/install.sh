#!/usr/bin/env bash
# install.sh — Instalador del skill branching-avanzado para Claude Code
set -euo pipefail

SKILL_NAME="branching-avanzado"
REPO_URL="${BRANCHING_SKILL_REPO:-https://github.com/paulo/branching-avanzado-skill}"
GLOBAL_DIR="$HOME/.claude/skills/$SKILL_NAME"
LOCAL_DIR=".claude/skills/$SKILL_NAME"

usage() {
  echo "Uso: $0 [--local] [--update] [--uninstall]"
  echo ""
  echo "  --local      Instalar solo en el proyecto actual (.claude/skills/)"
  echo "  --update     Actualizar a la última versión (global o local según exista)"
  echo "  --uninstall  Eliminar el skill"
  echo ""
  echo "Sin flags: instala globalmente (~/.claude/skills/)"
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
  echo "  Activa con: /branching-avanzado"
}

install_local() {
  if [[ ! -f "$(git rev-parse --show-toplevel 2>/dev/null)/.git/config" ]] && [[ ! -d ".git" ]]; then
    echo "⚠ No estás en la raíz de un repositorio git. Instala desde la raíz del proyecto."
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
  echo "  Para compartir con el equipo, commitea .claude/skills/$SKILL_NAME/"
  echo "  Para uso personal, agrega .claude/skills/ a .gitignore"
}

update_skill() {
  local target=""
  if [[ -d "$GLOBAL_DIR" ]]; then
    target="$GLOBAL_DIR"
  elif [[ -d "$LOCAL_DIR" ]]; then
    target="$LOCAL_DIR"
  else
    echo "✗ El skill no está instalado. Ejecuta el script sin flags para instalar."
    exit 1
  fi
  echo "→ Actualizando $SKILL_NAME en $target..."
  git -C "$target" pull origin main
  echo "✓ Actualizado correctamente."
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

# Parseo de argumentos
MODE="global"
for arg in "$@"; do
  case "$arg" in
    --local)     MODE="local" ;;
    --update)    MODE="update" ;;
    --uninstall) MODE="uninstall" ;;
    --help|-h)   usage; exit 0 ;;
    *) echo "Flag desconocido: $arg"; usage; exit 1 ;;
  esac
done

case "$MODE" in
  global)    install_global ;;
  local)     install_local ;;
  update)    update_skill ;;
  uninstall) uninstall_skill ;;
esac
