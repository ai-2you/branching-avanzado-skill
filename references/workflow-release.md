# Workflow: Release (develop → rama principal)

La rama principal es la que el repositorio tiene por defecto, `main` o `master`; los ejemplos usan `main`.

## Cuándo hacer una release

- Todas las fases de la versión objetivo están en `develop`, cada una con su revisión de código
- Tests pasan en `develop`
- El usuario confirma que la versión está lista para producción

## Paso 1 — Confirmar versión con el usuario

Antes de cualquier acción, confirmar:
- ¿Cuál es la versión que vamos a lanzar? (ej: `0.2.0`)
- ¿Hay algo pendiente que deba entrar en esta release?

## Paso 2 — Actualizar los archivos de versión

Dónde se hace el commit de versión:
- Si una fase equivale a una versión (lo habitual), al final de la rama de la fase, justo antes de
  integrarla en `develop`; así el merge ya lleva la versión.
- Si varias fases comparten versión, en `develop` cuando haya entrado la última, o en la rama
  integradora si se usa (ver `seguimiento-fases.md`).

Actualizar **todos** los archivos de versión del proyecto. En un monorepo suelen ser varios (por
ejemplo el `package.json` y el `package-lock.json` de cada paquete y el `app.json` de Expo); deben
quedar idénticos y en el mismo commit.

**package.json:**
```bash
npm version 0.2.0 --no-git-tag-version   # actualiza también package-lock.json; en un monorepo, en cada paquete
# o manualmente editar "version": "0.2.0"
```

**pyproject.toml:**
```toml
[project]
version = "0.2.0"
```

**VERSION / version.txt:**
```bash
echo "0.2.0" > VERSION
```

Commit del bump de versión:
```bash
git add <ficheros de versión>
git commit -m "chore(release): bump version to 0.2.0"
```

## Paso 3 — Merge local develop → principal

```bash
git checkout main            # o master
git merge --no-ff develop -m "chore(release): v0.2.0"
```

## Paso 4 — Crear tag semántico

```bash
git tag -a v0.2.0 -m "Release v0.2.0

Cambios incluidos:
- Autenticación de usuario (feat/0.2.0-autenticacion-usuario)
- [otros cambios de la versión]"

# Solo si se acordó publicar en la planificación:
git push origin main develop v0.2.0
```

## Paso 5 — Crear GitHub Release (solo si se acordó)

Opcional. Los tags ya marcan cada versión; la release se crea solo si se acordó en la planificación
y requiere haber subido el tag.

```bash
gh release create v0.2.0 \
  --title "v0.2.0 - Autenticación de usuario" \
  --generate-notes \
  --latest
```

`--generate-notes` usa los PRs mergeados desde el tag anterior para generar el changelog automáticamente.

Si prefieres notas manuales:
```bash
gh release create v0.2.0 \
  --title "v0.2.0 - Autenticación de usuario" \
  --notes "## Novedades

### ✨ Nuevas funcionalidades
- Sistema de autenticación con JWT
- Endpoint POST /login y POST /logout

### 🐛 Correcciones
- [lista de fixes si aplica]

### 📦 Dependencias
- [actualizaciones de dependencias si aplica]"
```

## Paso 6 — Sincronizar develop con la principal (solo si hace falta)

Solo si la principal recibió commits que `develop` no tiene (por ejemplo un hotfix). Con el flujo
normal, el merge `--no-ff` de `develop` en la principal no deja nada que sincronizar.
```bash
git checkout develop
git merge --no-ff main -m "chore: sync develop with main after v0.2.0 release"
git push origin develop   # solo si se acordó publicar
```

## Paso 7 — Seguimiento

Marcar la fase ✅ «Terminada e integrada» en las dos tablas del plan, con fin, commits (versión, merge
en `develop`, merge en la principal y tag), informes y pendientes reales, y hacer commit del plan.

## Flujo visual completo

```
develop ─────────────────────────────────────→
    feat/0.2.0-auth ──→ develop
    feat/0.2.0-pagos ──→ develop
                                 \
principal ────────────────────────→ merge --no-ff → tag v0.2.0 → (push y release si se acordaron)
```

## Tipos de versión semántica

| Cambio | Tipo | Ejemplo |
|---|---|---|
| Breaking change / mayor funcionalidad | MAJOR (x.0.0) | 1.0.0, 2.0.0 |
| Nueva funcionalidad compatible | MINOR (0.x.0) | 0.2.0, 0.3.0 |
| Bug fix / patch | PATCH (0.0.x) | 0.1.1, 0.1.2 |

Para proyectos pre-1.0: usar `0.x.0` para features y `0.0.x` para patches.
