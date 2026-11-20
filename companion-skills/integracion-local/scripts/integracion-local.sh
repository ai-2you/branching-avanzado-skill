#!/usr/bin/env bash
# integracion-local.sh — parte mecánica (determinista) del flujo «Integración Local».
#
# El juicio (code review, verificación, versión, promoción) lo lleva la skill
# `integracion-local`; este script solo hace las comprobaciones y operaciones git
# que no deben depender de la memoria de un agente:
#
#   ruta                       imprime la carpeta del worktree integrador
#   estado                     integradora vs destino remoto, lote pendiente y cerrojo
#   comprobar [rama]           requisitos para fusionar una rama en la integradora
#   bloquear <motivo>          toma el cerrojo de integración (uno a la vez)
#   liberar [--forzar]         suelta el cerrojo
#   fusionar <rama> <fichero>  merge --no-ff en la integradora con el mensaje del fichero
#   sacar <sha-del-merge>      revierte (revert -m 1) una fusión del lote
#
# Configuración opcional por proyecto: .claude/integracion-local.json (ver assets/).
# Funciona en Git Bash (Windows), Linux y macOS. Sin dependencias salvo git (y node
# solo para leer el JSON de configuración; sin node se usan los valores por defecto).
set -euo pipefail

CMD="${1:-ayuda}"
if [ $# -gt 0 ]; then shift; fi

ROOT="$(git rev-parse --show-toplevel)"
COMMON="$(cd "$(git rev-parse --git-common-dir)" && pwd)"
CFG="$ROOT/.claude/integracion-local.json"
LOCK="$COMMON/integracion-local.lock"

die() { echo "ERROR: $*" >&2; exit "${CODIGO:-1}"; }

leer_cfg() { # leer_cfg <clave.anidada> <por-defecto>
  local clave="$1" defecto="$2" ruta="$CFG"
  if [ -f "$CFG" ] && command -v node >/dev/null 2>&1; then
    command -v cygpath >/dev/null 2>&1 && ruta="$(cygpath -w "$CFG")"
    node -e '
      const c = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      const v = process.argv[2].split(".").reduce((o, k) => (o == null ? o : o[k]), c);
      process.stdout.write(v == null ? process.argv[3] : String(v));
    ' "$ruta" "$clave" "$defecto"
  else
    printf '%s' "$defecto"
  fi
}

existe_ref() { git show-ref --verify --quiet "$1"; }

INTEG="$(leer_cfg ramaIntegradora integracion-local)"
PRINCIPAL_DEF="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
PRINCIPAL="$(leer_cfg ramaPrincipal "${PRINCIPAL_DEF:-main}")"
if existe_ref refs/remotes/origin/develop || existe_ref refs/heads/develop; then DEST_DEF=develop; else DEST_DEF="$PRINCIPAL"; fi
DESTINO="$(leer_cfg ramaDestino "$DEST_DEF")"

# Ref de comparación del destino: el remoto si existe (proyectos con GitHub), si no la rama local.
if existe_ref "refs/remotes/origin/$DESTINO"; then DEST_REF="origin/$DESTINO"; else DEST_REF="$DESTINO"; fi

ruta_de_rama() { # carpeta del worktree que tiene la rama abierta (vacío si ninguno)
  git worktree list --porcelain | awk -v b="refs/heads/$1" '
    /^worktree /{w=substr($0,10)} $0=="branch " b {print w; exit}'
}

ruta_integradora() {
  local r; r="$(ruta_de_rama "$INTEG")"
  [ -n "$r" ] || CODIGO=2 die "la rama «$INTEG» no está abierta en ningún worktree. Créalo (skill integracion-local, modo «iniciar»)."
  printf '%s' "$r"
}

arbol_limpio() { [ -z "$(git -C "$1" status --porcelain --untracked-files=normal)" ]; }

info_cerrojo() {
  if [ -d "$LOCK" ]; then
    local edad; edad=$(( $(date +%s) - $(stat -c %Y "$LOCK" 2>/dev/null || stat -f %m "$LOCK") ))
    echo "cerrojo: OCUPADO hace $((edad / 60)) min — $(cat "$LOCK/quien" 2>/dev/null || echo '?')"
  else
    echo "cerrojo: libre"
  fi
}

cmd_bloquear() {
  local motivo="${*:-sin motivo}"
  if mkdir "$LOCK" 2>/dev/null; then
    printf '%s · %s · %s\n' "$motivo" "$(git branch --show-current 2>/dev/null || echo '?')" "$(date '+%d-%m-%Y %H:%M')" > "$LOCK/quien"
    echo "cerrojo tomado: $motivo"
  else
    CODIGO=3 die "$(info_cerrojo). Espera a que termine la otra integración (no lo fuerces sin permiso del usuario)."
  fi
}

cmd_liberar() {
  [ -d "$LOCK" ] || { echo "cerrojo ya estaba libre"; return 0; }
  local mia; mia="$(git branch --show-current 2>/dev/null || true)"
  if [ "${1:-}" != "--forzar" ] && ! grep -qF -- "· ${mia:-?} ·" "$LOCK/quien" 2>/dev/null; then
    CODIGO=3 die "el cerrojo lo tomó otra rama: $(cat "$LOCK/quien" 2>/dev/null). Solo con permiso del usuario: «liberar --forzar»"
  fi
  rm -rf "$LOCK"; echo "cerrojo liberado"
}

cmd_estado() {
  local w; w="$(ruta_integradora)"
  git fetch --quiet origin 2>/dev/null || echo "(aviso: sin fetch; datos del remoto pueden estar viejos)"
  echo "integradora: $INTEG → $w"
  echo "destino:     $DEST_REF · principal: $PRINCIPAL"
  echo "HEAD:        $(git -C "$w" log -1 --format='%h %s')"
  arbol_limpio "$w" && echo "árbol:       limpio" || echo "árbol:       CON CAMBIOS SIN COMITEAR"
  echo "vs $DEST_REF: por delante $(git rev-list --count "$DEST_REF..$INTEG") · por detrás $(git rev-list --count "$INTEG..$DEST_REF")"
  info_cerrojo
  echo; echo "Lote pendiente de promoción (fusiones en la integradora que no están en $DEST_REF):"
  git log --first-parent --merges --format='  %h %ad %s' --date=format:'%d-%m %H:%M' "$DEST_REF..$INTEG" || true
}

cmd_comprobar() {
  local rama="${1:-$(git branch --show-current)}" w_rama w fallos=0
  [ -n "$rama" ] || die "no estás en ninguna rama"
  case "$rama" in "$INTEG"|"$DESTINO"|"$PRINCIPAL") die "«$rama» no se integra con este flujo";; esac
  existe_ref "refs/heads/$rama" || die "la rama local «$rama» no existe"
  w="$(ruta_integradora)"
  w_rama="$(ruta_de_rama "$rama")"

  if [ -n "$w_rama" ] && ! arbol_limpio "$w_rama"; then
    echo "✗ $w_rama tiene cambios sin comitear (comitéalos o descártalos antes)"; fallos=1
  fi
  arbol_limpio "$w" || { echo "✗ la integradora ($w) tiene cambios sin comitear"; fallos=1; }

  if git merge-base --is-ancestor "$INTEG" "$rama"; then
    echo "✓ «$rama» ya contiene la integradora actual"
  else
    echo "✗ «$rama» no contiene la integradora: en su worktree ejecuta «git merge $INTEG», resuelve conflictos y vuelve a verificar"; fallos=1
  fi

  local n; n="$(git rev-list --count "$INTEG..$rama")"
  [ "$n" -gt 0 ] && echo "✓ $n commits por integrar" || { echo "✗ no hay nada que integrar"; fallos=1; }

  if git log "$INTEG..$rama" --format='%B' | grep -qiE 'co-authored-by:.*(claude|anthropic|openai|gpt|copilot|gemini|cursor)'; then
    echo "✗ hay commits con Co-Authored-By de IA: reescribir antes de integrar"; fallos=1
  fi
  echo "autores: $(git log "$INTEG..$rama" --no-merges --format='%an <%ae>' | sort -u | paste -sd ',' -)"

  [ "$fallos" -eq 0 ] && echo "OK: «$rama» se puede fusionar en «$INTEG»" || CODIGO=4 die "requisitos sin cumplir"
}

cmd_fusionar() {
  local rama="${1:-}" msg="${2:-}" w
  [ -n "$rama" ] && [ -f "$msg" ] || die "uso: fusionar <rama> <fichero-con-el-mensaje>"
  [ -d "$LOCK" ] || die "toma antes el cerrojo: «bloquear integrar $rama»"
  cmd_comprobar "$rama"
  w="$(ruta_integradora)"
  if git -C "$w" merge --no-ff --no-edit -F "$msg" "$rama"; then
    echo "FUSIONADA: $(git -C "$w" log -1 --format='%h %s')"
  else
    git -C "$w" merge --abort 2>/dev/null || true
    CODIGO=5 die "conflicto al fusionar: la integradora queda como estaba. Trae «$INTEG» a la rama y resuelve allí."
  fi
}

cmd_sacar() {
  local sha="${1:-}" w
  [ -n "$sha" ] || die "uso: sacar <sha-del-merge>"
  [ -d "$LOCK" ] || die "toma antes el cerrojo: «bloquear sacar $sha»"
  w="$(ruta_integradora)"
  [ "$(git -C "$w" rev-list --parents -n1 "$sha" | wc -w)" -eq 3 ] || die "$sha no es un commit de merge"
  git -C "$w" revert -m 1 --no-edit "$sha"
  echo "SACADA del lote: $(git -C "$w" log -1 --format='%h %s')"
}

case "$CMD" in
  ruta) ruta_integradora; echo ;;
  estado) cmd_estado ;;
  comprobar) cmd_comprobar "$@" ;;
  bloquear) cmd_bloquear "$@" ;;
  liberar) cmd_liberar "$@" ;;
  fusionar) cmd_fusionar "$@" ;;
  sacar) cmd_sacar "$@" ;;
  *) sed -n '2,16p' "$0" ;;
esac
