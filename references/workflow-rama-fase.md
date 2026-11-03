# Workflow: Crear y gestionar rama por fase/tarea

## Paso 1 — Leer versión del plan activo

Busca la versión en este orden:
1. Fase activa `phase-XX-*.md` → tabla «## Seguimiento» (campos Versión y Rama)
2. `plan.md` del plan activo → tabla resumen de fases o sección de la fase actual
3. Si no hay plan: preguntar al usuario qué versión corresponde

**Ejemplo en phase-02-autenticacion.md:**
```markdown
## Seguimiento

| Campo | Valor |
|---|---|
| Versión | 0.2.0 (se sube al integrar en `develop`) |
| Rama | `feat/0.2.0-autenticacion-usuario` |
| Estado | ⚪ Pendiente |
```

## Paso 2 — Determinar tipo de cambio

| Tipo | Cuándo usar |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `chore` | Mantenimiento, dependencias, CI |
| `refactor` | Refactorización sin cambio de comportamiento |
| `docs` | Solo documentación |

## Paso 3 — Construir el nombre de la rama

**Patrón:** `{tipo}/{version}-{slug-descriptivo}`

**Reglas del slug:**
- Solo minúsculas, guiones, sin espacios
- Máximo 40 caracteres
- Describe el contenido, no la tarea (ej: `autenticacion-usuario`, no `fase-2`)

**Ejemplos:**
```
feat/0.2.0-autenticacion-usuario
feat/0.2.0-sistema-pagos
fix/0.1.1-validacion-email
fix/0.1.2-crash-al-cerrar-sesion
chore/0.3.0-configurar-ci-cd
refactor/0.2.1-extraer-servicio-auth
docs/0.2.0-api-reference
```

## Paso 4 — Crear la rama

```bash
# Siempre partir desde develop actualizado (pull solo si develop tiene remoto)
git checkout develop
git pull origin develop

# Crear la rama
git checkout -b feat/0.2.0-autenticacion-usuario

# Confirmar al usuario
echo "Rama 'feat/0.2.0-autenticacion-usuario' creada desde develop"
```

Justo después, actualizar las dos tablas de seguimiento: la fase pasa a 🟡 «En curso: implementando»
con su rama y la fecha de inicio, y se hace commit del plan (ver `seguimiento-fases.md`).

## Paso 5 — Trabajar en la rama

Durante el desarrollo en la rama:
- Commits frecuentes y atómicos (ver `commit-standards.md`)
- No mergear otras features directamente en esta rama
- Si develop avanza, rebase periódicamente:

```bash
git fetch origin      # solo si hay remoto
git rebase develop
```

## Ciclo de vida de la rama

```
develop (actualizado)
    │
    └── git checkout -b feat/0.2.0-autenticacion-usuario
            │
            ├── commit: feat(auth): agregar modelo de usuario
            ├── commit: feat(auth): endpoint POST /login
            ├── commit: test(auth): tests de integración login
            │
            └── → [workflow-merge-develop.md]
```

## Convenciones adicionales

- Una rama por fase/tarea — nunca mezclar dos fases en una rama
- La rama incluye la versión para trazabilidad en el historial
- Si una fase se divide en sub-tareas, crear ramas separadas con el mismo prefijo de versión
