# Workflow: Merge de feature → develop

## Condiciones para hacer merge

Verificar antes de iniciar:
- [ ] Tests, lint, typecheck y build pasan en local
- [ ] Revisión de código de la fase hecha por un agente revisor sobre el diff contra `develop`, con las
      correcciones aplicadas y el informe en `plans/reports/`
- [ ] Sin conflictos con develop actualizado
- [ ] La funcionalidad está completa según los criterios de la fase
- [ ] Versión subida en todos los ficheros de versión si esta fase cierra una versión (ver `workflow-release.md`)

## Paso 1 — Actualizar la rama con develop

Solo hace falta si `develop` avanzó desde que salió la rama:
```bash
git checkout feat/0.2.0-autenticacion-usuario
git rebase develop
```

Si hay conflictos durante el rebase:
```bash
# Resolver conflictos en los archivos marcados
git add <archivos-resueltos>
git rebase --continue
# Si necesitas abortar:
git rebase --abort
```

## Paso 2 — Merge local a develop (por defecto)

```bash
git checkout develop
git merge --no-ff feat/0.2.0-autenticacion-usuario
```

`--no-ff` crea un commit de merge aunque fuera posible un fast-forward, así el historial muestra
dónde empieza y acaba cada fase. Nunca `--squash`: se perdería el detalle de los commits.

## Paso 3 — Solo si se acordó trabajar con pull requests

Si en la planificación se acordó revisión humana en GitHub, en lugar del paso 2:

```bash
git push origin feat/0.2.0-autenticacion-usuario
# Si hiciste rebase (historial reescrito):
git push --force-with-lease origin feat/0.2.0-autenticacion-usuario
```

> Nota: `--force-with-lease` es más seguro que `--force` — falla si alguien más hizo push.

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

Tras la aprobación, merge con commit de merge para conservar el historial:
```bash
gh pr merge <pr-number> --merge
```

**Importante:** nunca `--squash` ni `--rebase` al integrar: se perdería el historial de commits de la fase.

## Paso 4 — Limpiar la rama (preguntar antes)

En algunos proyectos la rama se conserva hasta cerrar la versión; preguntar antes de borrarla.

```bash
git branch -d feat/0.2.0-autenticacion-usuario
git push origin --delete feat/0.2.0-autenticacion-usuario   # solo si se había publicado
```

## Paso 5 — Seguimiento

Marcar la fase ✅ «Terminada e integrada» en las dos tablas (o dejarla 🟡 si todavía falta la versión y
el merge a la principal), con los hashes de los commits y del merge, y hacer commit del plan. Si se
acordó publicar al cerrar la fase, el push va aquí: `git push origin develop`.

## Flujo visual

```
develop ──────────────────────────────────────────→
         \                                   /
          feat/0.2.0-autenticacion-usuario ──
          (rebase si hace falta → revisión → merge --no-ff local)
```

## Casos especiales

**Feature bloqueada por otra feature en progreso:**
Esperar a que la dependencia llegue a `develop` antes de hacer rebase.

**Feature que dura múltiples sesiones:**
Hacer rebase contra `develop` al inicio de cada sesión de trabajo para mantener la rama actualizada.
