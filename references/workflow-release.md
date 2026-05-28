# Workflow: Release (develop → main)

## Cuándo hacer una release

- Todas las fases de la versión objetivo están en `develop`
- Tests pasan en `develop`
- El usuario confirma que la versión está lista para producción

## Paso 1 — Confirmar versión con el usuario

Antes de cualquier acción, confirmar:
- ¿Cuál es la versión que vamos a lanzar? (ej: `0.2.0`)
- ¿Hay algo pendiente que deba entrar en esta release?

## Paso 2 — Actualizar archivos de versión en develop

```bash
git checkout develop
git pull origin develop
```

Actualizar el archivo de versión según el tipo de proyecto:

**package.json:**
```bash
npm version 0.2.0 --no-git-tag-version
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
git add .
git commit -m "chore(release): bump version to 0.2.0"
git push origin develop
```

## Paso 3 — Merge develop → main

```bash
git checkout main
git pull origin main
git merge --no-ff develop -m "chore(release): v0.2.0"
git push origin main
```

## Paso 4 — Crear tag semántico

```bash
git tag -a v0.2.0 -m "Release v0.2.0

Cambios incluidos:
- Autenticación de usuario (feat/0.2.0-autenticacion-usuario)
- [otros cambios de la versión]"

git push origin v0.2.0
# o push de todos los tags:
git push origin --tags
```

## Paso 5 — Crear GitHub Release

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

## Paso 6 — Sincronizar develop con main

Tras la release, sincronizar develop para que tenga el tag:
```bash
git checkout develop
git merge --no-ff main -m "chore: sync develop with main after v0.2.0 release"
git push origin develop
```

## Flujo visual completo

```
develop ─────────────────────────────────────→
    feat/0.2.0-auth ──→ develop
    feat/0.2.0-pagos ──→ develop
                                 \
main ─────────────────────────────→ merge --no-ff → tag v0.2.0 → release
```

## Tipos de versión semántica

| Cambio | Tipo | Ejemplo |
|---|---|---|
| Breaking change / mayor funcionalidad | MAJOR (x.0.0) | 1.0.0, 2.0.0 |
| Nueva funcionalidad compatible | MINOR (0.x.0) | 0.2.0, 0.3.0 |
| Bug fix / patch | PATCH (0.0.x) | 0.1.1, 0.1.2 |

Para proyectos pre-1.0: usar `0.x.0` para features y `0.0.x` para patches.
