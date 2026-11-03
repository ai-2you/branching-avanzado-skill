# branching-avanzado — Skill para Claude Code

![Version](https://img.shields.io/github/v/tag/yosnap/branching-avanzado-skill?label=version&color=blue)
![License](https://img.shields.io/badge/license-MIT-green)

Skill de Claude Code que implementa un flujo Git/GitHub avanzado de tres niveles:
**feature → develop → rama principal** (`main` o `master`), con versionado semántico por fase,
seguimiento del plan en cada transición y tag por versión.

## Instalación rápida

```bash
curl -sSL https://raw.githubusercontent.com/yosnap/branching-avanzado-skill/main/scripts/install.sh | bash
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
git clone https://github.com/yosnap/branching-avanzado-skill \
  ~/.claude/skills/branching-avanzado
```

### Por proyecto

```bash
mkdir -p .claude/skills
git clone https://github.com/yosnap/branching-avanzado-skill \
  .claude/skills/branching-avanzado
```

### Con script de instalación

```bash
# Global (por defecto)
curl -sSL https://raw.githubusercontent.com/yosnap/branching-avanzado-skill/main/scripts/install.sh | bash

# Por proyecto
curl -sSL https://raw.githubusercontent.com/yosnap/branching-avanzado-skill/main/scripts/install.sh | bash -s -- --local

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

## Requisitos

- Claude Code (CLI o extensión VSCode)
- `git` instalado y configurado
- Un repositorio git; GitHub y `gh` CLI autenticado solo si se acordó trabajar con pull requests,
  protección de ramas o releases

## Licencia

MIT
