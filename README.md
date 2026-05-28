# branching-avanzado — Skill para Claude Code

Skill de Claude Code que implementa un flujo Git/GitHub avanzado de tres niveles:
**feature → develop → main**, con versionado semántico por fase y releases automáticas.

## ¿Qué hace este skill?

- Crea una rama por cada tarea o fase del plan de desarrollo
- Asigna versión semántica a cada rama según el plan activo
- Guía el merge de features → `develop` (nunca directo a `main`)
- Cuando `develop` está verificado, hace merge a `main` + crea tag + GitHub Release

## Instalación

### Global (todos los proyectos)

```bash
git clone https://github.com/{usuario}/branching-avanzado-skill \
  ~/.claude/skills/branching-avanzado
```

### Por proyecto

```bash
mkdir -p .claude/skills
git clone https://github.com/{usuario}/branching-avanzado-skill \
  .claude/skills/branching-avanzado
```

### Con script de instalación

```bash
# Global (por defecto)
curl -sSL https://raw.githubusercontent.com/{usuario}/branching-avanzado-skill/main/scripts/install.sh | bash

# Por proyecto
curl -sSL https://raw.githubusercontent.com/{usuario}/branching-avanzado-skill/main/scripts/install.sh | bash -s -- --local

# Actualizar
bash scripts/install.sh --update

# Desinstalar
bash scripts/install.sh --uninstall
```

## Uso

En cualquier conversación de Claude Code, activa el skill con:

```
/branching-avanzado
```

Claude te mostrará el árbol de decisión y te guiará en el flujo que necesitas.

## Flujo de trabajo

```
feature/0.2.0-mi-feature
        │
        └──→ develop (integración + pruebas)
                        │
                        └──→ main (release + tag v0.2.0)
```

## Estructura del skill

```
branching-avanzado/
├── SKILL.md                              ← Instrucciones principales
├── scripts/
│   └── install.sh                        ← Script de instalación
└── references/
    ├── setup-flujo.md                    ← Configuración inicial
    ├── workflow-rama-fase.md             ← Crear ramas por fase
    ├── workflow-merge-develop.md         ← Merge a develop
    ├── workflow-release.md               ← Release a main
    ├── commit-standards.md              ← Convenciones de commits
    ├── versionado-semantico.md          ← Reglas de versiones
    └── instalacion.md                   ← Guía de instalación detallada
```

## Requisitos

- Claude Code (CLI o extensión VSCode)
- `git` instalado y configurado
- `gh` CLI instalado y autenticado (`gh auth login`)
- Repositorio en GitHub

## Licencia

MIT
