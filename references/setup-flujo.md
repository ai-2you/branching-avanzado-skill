# Setup: Configurar el flujo de branching avanzado

## Requisitos previos

- `git` instalado y configurado con usuario/email
- `gh` CLI instalado y autenticado (`gh auth login`)
- Repositorio GitHub existente o nuevo
- Permisos de admin en el repositorio (para protección de ramas)

## Pasos de configuración inicial

### 1. Verificar rama main

```bash
git checkout main
git pull origin main
git status  # debe estar limpio
```

Si el repo es nuevo:
```bash
git init
git remote add origin <repo-url>
git checkout -b main
git commit --allow-empty -m "chore: initial commit"
git push -u origin main
```

### 2. Crear rama develop

```bash
git checkout -b develop
git push -u origin develop
```

### 3. Proteger ramas en GitHub

Proteger `main` — no permite push directo, requiere PR:
```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks=null \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

Proteger `develop` — no permite push directo:
```bash
gh api repos/{owner}/{repo}/branches/develop/protection \
  --method PUT \
  --field required_status_checks=null \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

### 4. Verificar archivo de versión

El proyecto debe tener un archivo de versión. Detecta cuál aplica:

| Tipo de proyecto | Archivo de versión |
|---|---|
| Node.js / npm | `package.json` → campo `"version"` |
| Python | `pyproject.toml` → `[project] version` |
| Python (setup.py) | `setup.py` → `version=` |
| Genérico | `VERSION` o `version.txt` |

Si no existe, crear `VERSION`:
```bash
echo "0.1.0" > VERSION
git add VERSION
git commit -m "chore: add version file"
git push origin develop
```

### 5. Confirmar estructura con el usuario

Antes de empezar, confirmar:
- ¿Qué archivo de versión usa el proyecto?
- ¿La versión inicial es `0.1.0` o diferente?
- ¿Se requiere revisión de PR antes de mergear a develop?
- ¿GitHub Actions para CI? (opcional, fuera del scope de este skill)

## Estado esperado tras el setup

```
origin/main     ← rama estable, solo releases
origin/develop  ← rama de integración activa
```

Las ramas de feature se crearán desde `develop` y se mergearan de vuelta a `develop`.
