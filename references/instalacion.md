# Instalación del skill branching-avanzado

## Requisito previo: repositorio del skill

El skill se distribuye como repositorio Git. Para poder instalarlo desde un repo:

```
https://github.com/yosnap/branching-avanzado-skill
```

El repositorio debe contener la carpeta del skill directamente en su raíz:
```
branching-avanzado-skill/          ← repo
├── SKILL.md
├── assets/
│   └── branch-protection.json
├── references/
│   ├── seguimiento-fases.md
│   ├── setup-flujo.md
│   ├── workflow-rama-fase.md
│   └── ...
└── scripts/
    └── install.sh
```

---

## Instalación global (todos los proyectos)

El skill queda disponible en cualquier proyecto que use Claude Code.

```bash
# Clonar directamente en el directorio de skills global
git clone https://github.com/yosnap/branching-avanzado-skill \
  ~/.claude/skills/branching-avanzado
```

**Verificar instalación:**
```bash
ls ~/.claude/skills/branching-avanzado/SKILL.md
# debe mostrar el archivo
```

**Actualizar a la última versión:**
```bash
cd ~/.claude/skills/branching-avanzado
git pull origin main
```

Requiere que la carpeta sea un clon de git. Si se copió a mano, borrarla y clonar de nuevo
(`git diff --no-index` contra el clon muestra antes si había cambios locales que conservar).

---

## Instalación por proyecto

El skill solo aplica al proyecto actual. Útil para equipos con configuración específica.

```bash
# Desde la raíz del proyecto
mkdir -p .claude/skills
git clone https://github.com/yosnap/branching-avanzado-skill \
  .claude/skills/branching-avanzado
```

**Agregar al .gitignore del proyecto** (opcional, si no quieres trackear el skill):
```bash
echo ".claude/skills/" >> .gitignore
```

O si el equipo debe compartir el skill, commitear `.claude/skills/branching-avanzado/`.

---

## Script de instalación automática

El skill incluye un script para simplificar la instalación:

```bash
# Descargar y ejecutar directamente
curl -sSL https://raw.githubusercontent.com/yosnap/branching-avanzado-skill/main/scripts/install.sh | bash

# O con opciones:
# Instalación global (por defecto)
./install.sh

# Instalación por proyecto
./install.sh --local
```

---

## Verificar que Claude Code lo reconoce

Tras la instalación, en cualquier conversación de Claude Code:
```
/branching-avanzado
```

Claude debe activar el skill y mostrar el árbol de decisión.

---

## Desinstalar

**Global:**
```bash
rm -rf ~/.claude/skills/branching-avanzado
```

**Por proyecto:**
```bash
rm -rf .claude/skills/branching-avanzado
```

---

## Mantener el skill actualizado con submódulo git (avanzado)

Si quieres trackear el skill como submódulo en tu proyecto:

```bash
git submodule add https://github.com/yosnap/branching-avanzado-skill \
  .claude/skills/branching-avanzado

# Actualizar submódulo
git submodule update --remote .claude/skills/branching-avanzado
```
