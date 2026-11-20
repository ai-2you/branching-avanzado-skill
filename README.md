# branching-avanzado — Skill para Claude Code

![Version](https://img.shields.io/github/v/tag/ai-2you/branching-avanzado-skill?label=version&color=blue)
![License](https://img.shields.io/badge/license-MIT-green)

Skill de Claude Code que implementa un flujo Git/GitHub avanzado de tres niveles:
**feature → develop → rama principal** (`main` o `master`), con versionado semántico por fase,
seguimiento del plan en cada transición y tag por versión.

> **Versión personalizada** de [yosnap/branching-avanzado-skill](https://github.com/yosnap/branching-avanzado-skill)
> (MIT, autor original: Paulo). Cambios de este fork:
>
> - **Integración Local para varios worktrees en paralelo:** cada worktree terminado hace su «PR local»
>   (code review + verificación local + `merge --no-ff`) en la rama local `integracion-local`, y los lotes
>   se promocionan juntos a `develop`/la principal con una sola PR y un solo CI. Skill complementaria en
>   [`companion-skills/integracion-local/`](companion-skills/integracion-local/SKILL.md).
> - **Versión solo al promocionar un lote**, subiendo el último número (`0.0.n`); las fases no suben versión.
> - Las decisiones se preguntan «al usuario» (no a una persona concreta).
> - **Guía de pruebas por worktree:** cada fusión deja en `docs/pruebas-integracion/` qué probar a mano;
>   el usuario prueba el lote en local (`/integracion-local probar`) y no se promociona con pruebas pendientes.
> - **La sesión de la integradora orquesta:** es la única que fusiona (con cerrojo) y la que concede turnos
>   de push, PR y despliegue; doble revisión (la del worktree y la de la integradora) antes de cada fusión.

## Instalación rápida

```bash
curl -sSL https://raw.githubusercontent.com/ai-2you/branching-avanzado-skill/main/scripts/install.sh | bash
```

> Instala el skill globalmente en `~/.claude/skills/branching-avanzado` — disponible en todos tus proyectos.

| Comando | Efecto |
|---------|--------|
| `... \| bash` | Instala globalmente |
| `... \| bash -s -- --local` | Instala solo en el proyecto actual |
| `bash install.sh --update` | Actualiza a la última versión |
| `bash install.sh --version` | Muestra versión instalada |
| `bash install.sh --uninstall` | Desinstala |

## ¿Qué hace este skill?

- Crea una rama por cada tarea o fase del plan de desarrollo, con la versión en el nombre
- Asigna versión semántica a cada fase según el plan activo
- Mantiene al día una tabla de seguimiento por fase (versión, rama, estado, commits, informes,
  revisión y pendientes) y la tabla resumen del plan, con commit en cada transición
- Pregunta al usuario toda decisión de producto, diseño, alcance o versión, con opciones
- Exige revisión de código por fase antes de integrar, con sus correcciones aplicadas
- Integra con merges locales `--no-ff`: features → `develop` → rama principal (`main` o `master`)
- Crea el tag por versión; el push, los pull requests, la protección de ramas y la release de GitHub
  solo si se acordaron en la planificación

## Instalación

### Global (todos los proyectos)

```bash
git clone https://github.com/ai-2you/branching-avanzado-skill \
  ~/.claude/skills/branching-avanzado
```

### Por proyecto

```bash
mkdir -p .claude/skills
git clone https://github.com/ai-2you/branching-avanzado-skill \
  .claude/skills/branching-avanzado
```

### Con script de instalación

```bash
# Global (por defecto)
curl -sSL https://raw.githubusercontent.com/ai-2you/branching-avanzado-skill/main/scripts/install.sh | bash

# Por proyecto
curl -sSL https://raw.githubusercontent.com/ai-2you/branching-avanzado-skill/main/scripts/install.sh | bash -s -- --local

# Actualizar
bash install.sh --update

# Desinstalar
bash install.sh --uninstall
```

## Uso

En cualquier conversación de Claude Code, activa el skill con:

```
/branching-avanzado
```

Claude te mostrará el árbol de decisión y te guiará en el flujo que necesitas.

## Flujo de trabajo

```
feat/0.2.0-mi-feature  (verificación local + revisión de código)
        │
        └──→ develop (merge --no-ff)
                        │
                        └──→ main o master (merge --no-ff + tag v0.2.0; push y release si se acordaron)
```

En paralelo, cada fase del plan (`phase-NN-*.md`) lleva su tabla de seguimiento y `plan.md` la tabla
resumen; se actualizan al crear la rama, al pasar a revisión, al corregir, al integrar y al bloquearse.

## Estructura del skill

```
branching-avanzado/
├── SKILL.md                              ← Instrucciones principales
├── assets/
│   └── branch-protection.json            ← Cuerpo para proteger la principal (opcional, con PR)
├── scripts/
│   └── install.sh                        ← Script de instalación
└── references/
    ├── seguimiento-fases.md              ← Obligatorio: seguimiento por fase y decisiones
    ├── setup-flujo.md                    ← Configuración inicial
    ├── workflow-rama-fase.md             ← Crear ramas por fase
    ├── workflow-merge-develop.md         ← Merge a develop
    ├── workflow-release.md               ← Release a la rama principal
    ├── commit-standards.md              ← Convenciones de commits
    ├── versionado-semantico.md          ← Reglas de versiones
    └── instalacion.md                   ← Guía de instalación detallada
```

## Skill complementaria: integracion-local

```bash
cp -r companion-skills/integracion-local ~/.claude/skills/integracion-local
```

Uso: `/integracion-local` al terminar un worktree, `/integracion-local probar` para probar el lote en local,
`/integracion-local promocionar` para subirlo,
`/integracion-local iniciar` para montar el flujo en un proyecto. Configuración opcional por proyecto en
`.claude/integracion-local.json` (plantilla en `companion-skills/integracion-local/assets/`).

## Requisitos

- Claude Code (CLI o extensión VSCode)
- `git` instalado y configurado
- Un repositorio git; GitHub y `gh` CLI autenticado solo si se acordó trabajar con pull requests,
  protección de ramas o releases

## Licencia

MIT
