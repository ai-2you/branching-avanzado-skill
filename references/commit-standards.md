# Estándares de commits

## Formato: Conventional Commits

```
{tipo}({scope}): {descripción en imperativo}

[cuerpo opcional — explica el POR QUÉ, no el qué]

[footer opcional — referencias, breaking changes]
```

## Tipos de commit

| Tipo | Cuándo usar |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `chore` | Mantenimiento, configuración, dependencias |
| `refactor` | Refactorización sin cambio de comportamiento |
| `docs` | Solo documentación |
| `test` | Agregar o corregir tests |
| `style` | Formato, espacios (sin cambio de lógica) |
| `perf` | Mejora de rendimiento |
| `ci` | Cambios en CI/CD |

## Scope

El scope es opcional pero recomendado. Usa el módulo, componente o área afectada:
- `feat(auth):`
- `fix(api):`
- `chore(deps):`
- `docs(readme):`

## Ejemplos correctos

```bash
# Feature con scope
feat(auth): agregar endpoint POST /login con JWT

# Fix con descripción
fix(auth): corregir expiración de token cuando timezone es UTC+

# Breaking change (!) — incrementa MAJOR
feat(api)!: cambiar formato de respuesta de /users a camelCase

BREAKING CHANGE: los campos user_id y created_at ahora son userId y createdAt

# Chore sin scope
chore: actualizar dependencias a versiones LTS

# Con cuerpo explicativo
refactor(auth): extraer lógica de validación a AuthService

La validación estaba duplicada en tres endpoints. Centralizar en
AuthService permite testearla de forma aislada y reutilizarla.
```

## Reglas

1. **Imperativo en descripción:** "agregar", no "agregué" ni "agrega"
2. **Sin punto final** en la descripción
3. **Máximo 72 caracteres** en la primera línea
4. **Commits atómicos:** un commit = un cambio lógico
5. **Sin secrets:** nunca incluir API keys, passwords, tokens
6. **Sin archivos generados:** no commitear `node_modules/`, `__pycache__/`, `.env`
7. **Sin referencias a herramientas de AI** en los mensajes
8. **Sin números de fase ni códigos del plan** en los mensajes: describe el comportamiento o el
   invariante, no «fase 3» ni «A1»
9. **Commits de integración con mensaje fijo:** el de versión es `chore(release): bump version to X.Y.Z`
   y el merge de `develop` en la principal es `chore(release): vX.Y.Z`; el merge de una fase en
   `develop` es `--no-ff` con el mensaje por defecto o uno descriptivo

## Commits a evitar

```bash
# ❌ Demasiado vago
git commit -m "fix stuff"
git commit -m "wip"
git commit -m "changes"

# ❌ Con referencias al plan en lugar del comportamiento
git commit -m "feat: fase 3 del plan"

# ❌ Con punto final
git commit -m "feat(auth): agregar login."

# ❌ En pasado
git commit -m "feat(auth): agregué el login"

# ❌ Mezclando cambios
git commit -m "feat: login y fix: corregir bug de registro"
```

## Verificar antes de commit

```bash
# Ver qué se va a commitear
git diff --staged

# Verificar que no hay secrets
git diff --staged | grep -iE "(password|secret|api_key|token)" || echo "OK"
```
