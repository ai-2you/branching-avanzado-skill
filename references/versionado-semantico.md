# Versionado semántico en el flujo de branching

> **Regla vigente del usuario (20-11-2026), manda sobre lo que sigue:** la versión cambia SOLO al
> promocionar un lote (`/integracion-local promocionar`), y por defecto sube el **último número**
> (`0.0.n` → `0.0.n+1`), también en los proyectos ya abiertos. Las fases y ramas no llevan versión
> propia ni la suben. MAJOR solo con aprobación explícita del usuario. Excepción: proyectos que el
> usuario dejó con su numeración antigua (`version.incremento: "minor"` en su
> `.claude/integracion-local.json`).

## Formato: MAJOR.MINOR.PATCH

```
v0.2.1
 │ │ └─ PATCH: bug fix, sin cambio de API
 │ └─── MINOR: nueva funcionalidad, retrocompatible
 └───── MAJOR: breaking change, API incompatible
```

## Reglas para proyectos pre-1.0

La mayoría de proyectos en desarrollo activo usan `0.x.y`:
- `0.MINOR.PATCH` — MINOR para nuevas features, PATCH para fixes
- No hay garantía de estabilidad de API hasta `1.0.0`
- El primer release estable es `1.0.0`

## Correspondencia fase del plan → versión

Cada fase del plan debe tener su versión documentada. Leer de la tabla «## Seguimiento» de la fase:

```markdown
# phase-02-autenticacion.md
## Seguimiento
| Versión | 0.2.0 (se sube al integrar en `develop`) |
| Rama | `feat/0.2.0-autenticacion-usuario` |
```

O de la tabla resumen del `plan.md`:
```markdown
| # | Fase | Versión | Rama | Estado | Depende de |
|---|---|---|---|---|---|
| 1 | Setup inicial | 0.1.0 | `chore/0.1.0-setup-inicial` | ✅ Terminada e integrada | — |
| 2 | Autenticación | 0.2.0 | `feat/0.2.0-autenticacion-usuario` | 🟡 En curso: implementando | 1 |
| 3 | Sistema de pagos | 0.3.0 | `feat/0.3.0-sistema-pagos` | ⚪ Pendiente | 2 |
```

Las fases que solo producen documentos o informes no necesitan versión ni rama de código y se marcan
con «—». Una fase con código lleva versión aunque no cambie el comportamiento visible de la app.

## Incremento de versión por tipo de cambio

| Tipo de cambio | Incremento | Ejemplo |
|---|---|---|
| Breaking change, rediseño mayor | MAJOR | `0.x.y` → `1.0.0` |
| Nueva fase/feature completa | MINOR | `0.1.0` → `0.2.0` |
| Fix de bug dentro de una fase | PATCH | `0.2.0` → `0.2.1` |
| Fix urgente en producción (hotfix) | PATCH | `0.2.0` → `0.2.1` |

## Cuándo preguntar al usuario

Si el plan no especifica la versión de una fase:
1. Mostrar la versión actual del proyecto
2. Proponer la siguiente versión lógica según el tipo de cambio
3. Confirmar antes de crear la rama

**Ejemplo de pregunta:**
```
La versión actual es 0.1.0. Esta fase agrega nueva funcionalidad (feat).
La versión propuesta es 0.2.0. ¿Confirmas?
```

## Archivos de versión por ecosistema

| Ecosistema | Archivo | Campo |
|---|---|---|
| Node.js | `package.json` | `"version": "0.2.0"` |
| Python (Poetry) | `pyproject.toml` | `version = "0.2.0"` |
| Python (setup.py) | `setup.py` | `version="0.2.0"` |
| Rust | `Cargo.toml` | `version = "0.2.0"` |
| Go | `go.mod` + `git tag` | Solo tag |
| Genérico | `VERSION` | `0.2.0` |
| Monorepo / Expo | `package.json` y `package-lock.json` de cada paquete, `app.json` | Todos iguales, en el mismo commit |

## Tags de pre-release (opcional)

Para versiones candidatas antes de la release final:
```
v0.2.0-alpha.1    ← primera alpha
v0.2.0-beta.1     ← primera beta
v0.2.0-rc.1       ← release candidate
v0.2.0            ← release final
```

Crear tag de pre-release:
```bash
git tag -a v0.2.0-rc.1 -m "Release candidate 1 para v0.2.0"
# solo si se acordó publicar:
git push origin v0.2.0-rc.1
gh release create v0.2.0-rc.1 --prerelease --title "v0.2.0-rc.1"
```
