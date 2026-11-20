# Seguimiento de fases y decisiones (obligatorio)

Norma del flujo (definida por Paulo): **cada fase de un plan lleva su propio seguimiento, siempre al día**, y **toda decisión
de producto o de diseño se le pregunta al usuario**. Se aplica siempre que se use esta skill para desarrollar
por fases. No hay que esperar a que lo pida.

## 1. Tabla de seguimiento en cada fase

Cada `phase-NN-*.md` empieza, justo debajo del título, con esta tabla:

```markdown
## Seguimiento

| Campo | Valor |
|---|---|
| Versión | X.Y.Z (se sube al integrar en `<rama integradora o develop>`) |
| Rama | `{tipo}/{versión}-{slug}` |
| Estado | ⚪ Pendiente · 🟡 En curso: <detalle> · 🔴 Bloqueada: <motivo> · ✅ Terminada e integrada |
| Inicio | AAAA-MM-DD |
| Fin | AAAA-MM-DD o — |
| Commits | hashes cortos de los commits, del merge y del commit de versión |
| Informes | nombres de los reports de `plans/reports/` de esta fase |
| Revisión de código | ⏳ en marcha · ✅ <report> (N puntos corregidos) · — |
| Pendiente | lo que queda: pruebas, decisiones o migraciones por aplicar |
```

Y `plan.md` tiene una tabla resumen de fases, con las columnas `# | Fase | Versión | Rama | Estado | Depende de`.

## 2. Cuándo se actualiza (las DOS tablas, con commit local del plan)

| Momento | Estado | Qué más se rellena |
|---|---|---|
| Al crear la rama de la fase | 🟡 En curso: implementando | Rama e inicio |
| Al terminar la implementación | 🟡 En curso: en revisión de código | Informes y «Revisión: ⏳» |
| Al corregir la revisión | 🟡 En curso: correcciones aplicadas | Revisión: ✅ con el report y el número de puntos |
| Al integrar (merge y versión) | ✅ Terminada e integrada | Fin, commits y pendientes reales |
| Si algo la para | 🔴 Bloqueada: motivo | Pendiente con lo que hace falta |
| Cuando cambie lo pendiente | (sin cambio) | Pendiente |

Los planes no necesitan rama: si viven en un repositorio aparte (por ejemplo uno con el nombre del
cliente), se hace commit en su rama principal en cada transición y, si se acordó publicar, también se
sube. Si ese repositorio está clonado dentro del proyecto, su carpeta va en el `.gitignore` del proyecto.

**Push:** todo se integra en local. El push (de ramas, del plan o de la integradora) solo se hace si se
acordó con el usuario durante la planificación —por ejemplo, push al terminar cada fase verificada y
testeada—, y esa decisión se anota en el `plan.md`. Si no se acordó, no se hace push.

## 3. Decisiones: preguntar siempre

- **Antes de decidir algo de producto, de diseño, de alcance, de seguridad con contrapartidas o de
  versión, pregunta al usuario.** Presenta 2 a 4 opciones con la recomendada en primer lugar y su motivo,
  y espera su respuesta. No elijas por tu cuenta y lo cuentes después.
- Si un subagente propone una decisión, o la toma, súbela al usuario antes de integrarla.
- Las preguntas abiertas de cada fase van en «Pendiente» hasta que el usuario las responda. Después se
  anota la decisión, con su fecha, en una sección «## Decisiones» al final del archivo de la fase.
- La versión de cada fase y si una fase lleva código o solo documentos se fijan en la planificación,
  en la tabla resumen; no se improvisan al crear la rama.
- No se pregunta lo que se puede averiguar leyendo el repositorio, ni las convenciones ya acordadas
  (formato de ramas, commits o versiones).

## 4. Flujo con rama integradora (por defecto desde 20-11-2026)

La integradora es la rama local `integracion-local`, con su propio worktree. El procedimiento completo
(cerrojo, mensaje del merge, verificación del resultado, promoción por lotes) está en la skill
`integracion-local`.

```
develop ──▶ integracion-local
              ├──▶ {tipo}/<slug>  (cada fase o worktree sale de la integradora actualizada)
              └──  code review → verificación local → merge --no-ff a la integradora
integracion-local ──(lote probado: versión + changelog)──▶ develop ──▶ principal ──▶ tag
```

- La versión NO se sube en la rama de la fase ni en cada merge: se sube una vez por lote, al
  promocionar, para que los trabajos paralelos no choquen en `package.json` ni en el CHANGELOG.
- Se hace una revisión de código por fase antes de integrarla, y se aplican sus correcciones.
- La rama de la fase se borra al integrarla.
- Todos estos merges son locales; nada se sube sin el acuerdo de push tomado en la planificación.
