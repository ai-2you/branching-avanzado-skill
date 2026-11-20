# Integración Local — casos y riesgos

## Ramas apiladas (una rama sale de otra que aún no está integrada)

Integrar primero la base y después la apilada. Si la apilada ya contiene la base entera, se puede
integrar sola: arrastra la base en la misma fusión (anotarlo en el mensaje del merge).

## Rama con PR abierta en GitHub (del sistema antiguo)

Se integra igual que cualquier otra. La PR se deja abierta hasta la promoción del lote; entonces se
cierra con un comentario que enlaza la PR del lote (GitHub suele marcarla fusionada sola cuando sus
commits llegan a la base, pero no hay que contar con ello).

## Trabajo que vuelve a subir por el sistema antiguo mientras hay un lote abierto

Pasa cuando un hotfix u otra ola entra directamente en `develop`. En la promoción, el paso «traer el
destino» lo incorpora a la integradora antes de subir la versión. Si hay conflicto, se resuelve en la
integradora con cuidado (es la única vez que se resuelve ahí) y se repite la verificación completa.

## Fallo de CI en la PR del lote

1. Reproducir en local en la integradora (`verificacionCompleta`).
2. Localizar la fusión culpable (`git log --first-parent`, `git bisect --first-parent`).
3. Arreglarla en la rama del worktree culpable y reintegrar, o sacarla del lote con `IL sacar`.
4. Volver a empujar la integradora: la PR se actualiza sola.

## Cerrojo abandonado

`IL estado` enseña quién lo tomó y hace cuánto. Si la sesión dueña ya no existe, solo el usuario
autoriza `IL liberar --forzar`. Antes de forzar: `git -C <integradora> status` (¿merge a medias?) y,
si hay merge a medias, `git -C <integradora> merge --abort`.

## Proyecto sin remoto o sin develop

`ramaDestino` = la principal y `promocion: local`. El flujo es el de Paulo tal cual: integradora →
principal en local, tag, y push solo si se acordó.

## Respaldo antes de migrar un proyecto al flujo

Para cada worktree que pasa al flujo nuevo:

```bash
git rev-list --count <rama> --not --remotes        # commits sin copia en el remoto
git status --porcelain | wc -l                      # cambios sin comitear
git bundle create <respaldos>/<rama>.bundle <rama> --not origin/develop
git ls-files -m -o --exclude-standard -z | tar --null -T - -czf <respaldos>/<rama>-sin-comitear.tgz
git bundle verify <respaldos>/<rama>.bundle
```

Los respaldos van fuera del repo (p. ej. `../_respaldos-integracion-local/<fecha>/`).

## Por qué no un `develop` local

En proyectos donde `develop` existe en GitHub, un `develop` local que diverge del remoto confunde a
las sesiones y facilita un push equivocado. La integradora tiene otro nombre y no tiene upstream.
