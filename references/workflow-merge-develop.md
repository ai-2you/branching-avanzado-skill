# Workflow: Merge de feature → develop

## Condiciones para hacer merge

Verificar antes de iniciar:
- [ ] Todos los tests pasan localmente
- [ ] Code review completado (o auto-aprobado en proyectos personales)
- [ ] Sin conflictos con develop actualizado
- [ ] La funcionalidad está completa según los criterios de la fase

## Paso 1 — Actualizar la rama con develop

```bash
git checkout feat/0.2.0-autenticacion-usuario
git fetch origin
git rebase origin/develop
```

Si hay conflictos durante el rebase:
```bash
# Resolver conflictos en los archivos marcados
git add <archivos-resueltos>
git rebase --continue
# Si necesitas abortar:
git rebase --abort
```

## Paso 2 — Push de la rama actualizada

```bash
git push origin feat/0.2.0-autenticacion-usuario
# Si hiciste rebase (historial reescrito):
git push --force-with-lease origin feat/0.2.0-autenticacion-usuario
```

> Nota: `--force-with-lease` es más seguro que `--force` — falla si alguien más hizo push.

## Paso 3 — Crear Pull Request hacia develop

```bash
gh pr create \
  --base develop \
  --title "feat(auth): autenticación de usuario v0.2.0" \
  --body "## Cambios
- Modelo de usuario con hash de contraseña
- Endpoint POST /login con JWT
- Tests de integración

## Versión
- Fase: phase-02-autenticacion
- Versión objetivo: 0.2.0

## Checklist
- [x] Tests pasan
- [x] Sin secrets en el código
- [x] Documentación actualizada"
```

## Paso 4 — Merge a develop (tras aprobación)

**Opción A — Desde GitHub UI:**
Usar "Merge pull request" → "Create a merge commit" (preserva historial)

**Opción B — Desde CLI:**
```bash
gh pr merge <pr-number> --merge --delete-branch
```

**Importante:** Usar siempre `--merge` (no `--squash` ni `--rebase`) para preservar el historial de commits de la feature.

## Paso 5 — Limpiar la rama local

```bash
git checkout develop
git pull origin develop
git branch -d feat/0.2.0-autenticacion-usuario
```

## Flujo visual

```
develop ──────────────────────────────────────────→
         \                                   /
          feat/0.2.0-autenticacion-usuario ──
          (rebase → push → PR → merge --no-ff)
```

## Casos especiales

**Feature bloqueada por otra feature en progreso:**
Esperar a que la dependencia llegue a `develop` antes de hacer rebase.

**Feature que dura múltiples sesiones:**
Hacer rebase contra `develop` al inicio de cada sesión de trabajo para mantener la rama actualizada.
