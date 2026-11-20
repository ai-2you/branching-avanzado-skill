---
name: integracion-local
description: >
  Flujo global «Integración Local» para trabajar con varios worktrees en paralelo sin pagar un CI
  por cada uno. Cuando un worktree termina, se trae la rama integradora, se hace code review y
  verificación en local y se fusiona con merge --no-ff en la rama local `integracion-local`; los
  lotes de varios worktrees se promocionan juntos a develop (o a la principal) y la versión solo
  sube en cada promoción. Usar SIEMPRE al terminar un worktree o una fase («/integracion-local»,
  «integra esto», «PR local», «fusiona en local»), al promocionar un lote («/integracion-local
  promocionar») y al montar el flujo en un proyecto («/integracion-local iniciar»).
argument-hint: "[integrar | promocionar | estado | sacar <sha> | iniciar]"
metadata:
  scope: global
  author: user
  version: "1.0.0"
  basado-en: branching-avanzado (Paulo)
---

# /integracion-local — PR local, fusión en local y promoción por lotes

Norma global para **todos los proyectos**, también los futuros. Se apoya en la skill
`branching-avanzado` (ramas por fase, seguimiento, revisión por fase, merges locales sin PR) y le
añade el trabajo en **varios worktrees en paralelo** con una **rama integradora local**.

```
origin/develop ─┐
                └─▶ integracion-local  (worktree «Integración-Local», solo local + copia en remoto)
                      ▲ merge --no-ff        ▲ merge --no-ff        ▲ merge --no-ff
                 worktree A             worktree B             worktree C
                 (review + verify)      (review + verify)      (review + verify)
                      │
                      └── /integracion-local promocionar ──▶ versión ─▶ 1 PR + 1 CI ─▶ develop ─▶ main
```

**Script determinista:** `~/.claude/skills/integracion-local/scripts/integracion-local.sh`
(abreviado aquí como `IL`). Ejecutarlo con `bash` desde el worktree que se integra.

## Configuración por proyecto

`.claude/integracion-local.json` en la raíz del repo (plantilla en `assets/integracion-local.ejemplo.json`).
Sin fichero se usan los valores por defecto:

| Clave | Por defecto | Uso |
|---|---|---|
| `ramaIntegradora` | `integracion-local` | rama local donde se fusiona todo |
| `ramaDestino` | `develop` si existe, si no la principal | adónde va el lote |
| `ramaPrincipal` | la de `origin/HEAD` o `main` | producción |
| `promocion` | `local` | `local` (merge local + tag; push solo si `publicar`) o `github-pr` (1 PR por lote) |
| `publicar` | `false` | en modo `local`, si se hace push tras promocionar |
| `verificacionRapida` | — | comando tras cada fusión (p. ej. `pnpm run verify:fast`) |
| `verificacionCompleta` | — | comando antes de promocionar |
| `verificacionMigraciones` | — | aplicar TODAS las migraciones desde cero en una BD de integración |
| `version.incremento` | `patch` | `patch` (último número: 0.0.n) o `minor` (solo proyectos que ya lo usaban) |
| `version.ficheros` | `["package.json"]` | ficheros con el número de versión |
| `changelog` | `CHANGELOG.md` | con sección `## [Sin publicar]` |
| `turnos` | — | protocolo de turnos del proyecto para push/PR/deploy (si existe) |

## Reglas que no se negocian

1. **La versión solo cambia al promocionar.** Los worktrees NO suben versión: escriben su entrada en
   `## [Sin publicar]` del CHANGELOG. Por defecto se sube el último número (`0.0.n`).
2. **Una fusión = un commit `--no-ff`** en la integradora. Así un trabajo se saca del lote con `IL sacar`.
3. **Los conflictos se resuelven en la rama del worktree**, nunca en la integradora: antes de fusionar,
   el worktree trae la integradora (`git merge integracion-local`) y vuelve a verificar.
4. **Nada se pierde:** prohibido `reset --hard`, `branch -D`, `push --force`, `worktree remove` o borrar
   carpetas de trabajo sin permiso explícito del usuario. Antes de cerrar un worktree, su rama debe
   estar en la integradora (`git merge-base --is-ancestor <rama> integracion-local`).
5. **Un integrador cada vez:** el cerrojo de `IL bloquear`/`IL liberar` cubre fusión + verificación.
   Fusionar en local NO pide turno a ningún orquestador; push, PR y despliegues SÍ lo piden si el
   proyecto tiene protocolo de turnos.
6. **Migraciones y código viajan juntos** en el mismo lote. Nunca se promociona una migración sin el
   código que la usa, ni al revés.
7. **Autoría:** solo el usuario. Sin `Co-Authored-By` de IA (el script lo comprueba).
8. **Ramas nuevas** salen de la integradora actualizada (en Orca: `--base-branch integracion-local`),
   no de `develop`, para heredar lo ya integrado y no chocar después.

## [INTEGRAR] Al terminar un worktree (modo por defecto)

Desde el worktree que termina. Sin preguntas intermedias: el usuario ya lo pidió al invocarla.

1. **Todo comiteado.** `git status` limpio. Si hay trabajo sin comitear, comitearlo (conventional commit).
2. **Traer la integradora:** `git merge integracion-local` en la rama. Conflictos → resolverlos aquí,
   con criterio del dominio; si una resolución no es obvia, preguntar al usuario.
3. **Code review = la «PR local»:** `/ck:code-review` sobre `git diff integracion-local...HEAD`.
   Informe en `plans/reports/` (o la carpeta de informes del proyecto). Aplicar en la rama los
   hallazgos críticos/altos y repetir la revisión de lo corregido.
4. **Verificación local** en la rama: la `verificacionRapida` del proyecto (o typecheck + lint + tests
   + build) y la E2E local si el trabajo toca interfaz. Nada en rojo.
5. **CHANGELOG:** entrada en `## [Sin publicar]`. Sin tocar la versión.
6. `bash IL comprobar` → todo ✓.
7. `bash IL bloquear "integrar <rama>"`.
8. Escribir el mensaje del merge en un fichero temporal (es el registro de la «PR»):
   ```
   chore(integracion): <qué aporta, en una línea> (#<issue>)

   Rama: <rama> · Worktree: <carpeta>
   Issues: Closes #<n>   (se activa al llegar a develop/main)
   Revisión: plans/reports/<informe>.md — <n> hallazgos, <n> corregidos
   Verificación: <comando> ✓ · E2E local: <sí/no/no aplica>
   Migraciones: <ninguna | lista>
   PR antigua en GitHub: <#n o —> (se cierra al promocionar)
   ```
9. `bash IL fusionar <rama> <fichero>`.
10. **Verificar el resultado fusionado** en la carpeta de `IL ruta` (typecheck + tests afectados o la
    `verificacionRapida`). Si falla por la combinación: `bash IL sacar <sha>`, liberar y arreglar en la
    rama. Nunca dejar la integradora en rojo. Si la verificación regenera ficheros versionados
    (informes, inventarios), restaurarlos con `git restore` para dejar la integradora limpia.
11. `bash IL liberar`.
12. **Seguimiento:** marcar la fase/worktree como «✅ Integrado en local, pendiente de promoción» en el
    plan y en la memoria del proyecto. El worktree puede pasar ya a `check-cierre`.

## [PROMOCIONAR] Llevar el lote a develop

Lo lanza el usuario o el orquestador. Lotes de 3-5 trabajos o diarios, no semanales.

1. **Turno** si el proyecto tiene protocolo (`turnos`): es una acción en GitHub.
2. `bash IL bloquear promocion` y `bash IL estado` → lista del lote.
3. **Traer el destino:** en la integradora, `git fetch` y `git merge --no-ff origin/<destino>` si va por
   detrás (hotfixes u olas del sistema antiguo). Conflictos → resolver aquí con cuidado y verificar.
4. **Versión:** subir según `version.incremento` en todos los `version.ficheros`; en el CHANGELOG,
   `## [Sin publicar]` pasa a `## [X.Y.Z] — <resumen del lote> (DD-MM-YYYY)` y se abre uno vacío.
   Commit `chore(release): bump version to X.Y.Z` en la integradora (única excepción a «no comitear
   directo en la integradora»).
5. **Verificación completa** en la integradora: `verificacionCompleta` + `verificacionMigraciones`.
6. **Promocionar** según `promocion`:
   - `github-pr`: `git push origin integracion-local` → `gh pr create --base <destino> --head
     integracion-local --title "release: vX.Y.Z — <lote>"` con la lista del lote y todas las líneas
     `Closes #n` → esperar CI → merge **con merge commit** (`gh pr merge --merge`, nunca squash) →
     `git -C <integradora> merge --ff-only origin/<destino>`.
   - `local`: merge `--no-ff` de la integradora en el destino (y del destino en la principal si
     procede), tag anotado `vX.Y.Z`; push solo si `publicar: true`.
7. **PRs antiguas** de las ramas del lote (`gh pr list --head <rama>`): cerrarlas con un comentario que
   enlace la PR del lote, si GitHub no las marcó ya como fusionadas.
8. `bash IL liberar`. Despliegue y E2E en producción según el proyecto (un solo resumen de pruebas
   para todo el lote).

## [ESTADO] y [SACAR]

- `bash IL estado`: integradora, distancia al destino, lote pendiente y cerrojo.
- `bash IL sacar <sha>` (con cerrojo): revierte la fusión de un trabajo roto. Para volver a meterlo más
  tarde, revertir el revert en su rama (`git revert <sha-del-revert>`) antes de integrar de nuevo.

## [INICIAR] Montar el flujo en un proyecto

1. Crear la rama y su worktree desde el destino actualizado, **sin upstream** (un `git push` sin
   destino no puede caer en `develop`). En Orca:
   `orca worktree create --name Integración-Local --branch integracion-local --base-branch origin/develop --no-parent`.
   Sin Orca: `git worktree add -b integracion-local ../Integracion-Local origin/develop --no-track`.
2. Crear `.claude/integracion-local.json` con lo que aplique y `## [Sin publicar]` en el CHANGELOG.
3. Añadir al `CLAUDE.md` del proyecto una línea que remita a esta skill.
4. Decidir con el usuario qué trabajo en curso termina con el sistema antiguo (lo que ya va en la
   próxima subida) y cuál pasa al nuevo. Antes de cambiar, **respaldar** lo que no tenga copia en el
   remoto: `git bundle` de ramas solo locales y `tar` de cambios sin comitear, fuera del repo.

## Relación con otras skills

- `branching-avanzado`: ramas por fase, seguimiento y revisión por fase. Esta skill es su modo
  «worktrees en paralelo».
- `/cocinar`: termina llamando a `/integracion-local` (ya no promociona a `main` por su cuenta).
- `check-cierre`: un worktree se puede cerrar cuando su rama está en la integradora; la sincronía con
  GitHub se comprueba en la promoción del lote.
- Detalle y casos raros: `references/casos-y-riesgos.md`.
