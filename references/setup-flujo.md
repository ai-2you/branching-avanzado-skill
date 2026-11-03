# Setup: Configurar el flujo de branching avanzado

## Requisitos previos

- `git` instalado y configurado con usuario/email
- Repositorio git, con o sin remoto
- Solo si se acordó trabajar con pull requests, protección de ramas o releases: `gh` CLI autenticado
  (`gh auth login`), repositorio en GitHub y permisos de admin para la protección

## Pasos de configuración inicial

### 1. Identificar la rama principal y verificarla

La principal es la rama por defecto del repositorio: `main` en los proyectos nuevos, `master` en
muchos existentes. Si el proyecto tiene las dos (por ejemplo `main` congelada con una versión antigua
y `master` como principal), se pregunta una vez y se anota en el `plan.md`.

```bash
git symbolic-ref --short refs/remotes/origin/HEAD   # origin/main u origin/master
git checkout main                                   # o master
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
git push -u origin develop   # solo si se acordó publicar
```

### 3. Proteger ramas en GitHub (opcional, solo con pull requests)

Con el flujo por defecto (merge local y, si se acordó, push directo de la principal) la protección
estorba: bloquearía ese push. Solo se activa si se acordó trabajar con pull requests. El mismo cuerpo
está en `assets/branch-protection.json` para usarlo con `gh api --input`.

Proteger `main` (o `master`) — no permite push directo, requiere PR:
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
```

En un monorepo, anotar todos los archivos de versión (por ejemplo los `package.json` y
`package-lock.json` de cada paquete y el `app.json` de Expo): se suben todos en el mismo commit.

### 5. Confirmar estructura con el usuario

Antes de empezar, confirmar y anotar en el `plan.md`:
- ¿Cuál es la rama principal, `main` o `master`?
- ¿Qué archivos de versión usa el proyecto? ¿La versión inicial es `0.1.0` o diferente?
- ¿Merges locales con revisión por agente (por defecto) o pull requests con revisión humana?
- ¿Se hace push al cerrar cada fase verificada y testeada, o no se publica nada?
- ¿Se crean releases de GitHub además del tag?
- ¿GitHub Actions para CI? (opcional, fuera del scope de este skill)

## Estado esperado tras el setup

```
main (o master) ← rama principal: solo versiones integradas, con tag
develop         ← rama de integración activa
```

Las ramas de feature se crearán desde `develop` y se mergearan de vuelta a `develop`.
