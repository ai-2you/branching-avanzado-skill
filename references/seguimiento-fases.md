# Seguimiento de fases y decisiones (obligatorio)

Norma de Paulo: **cada fase de un plan lleva su propio seguimiento, siempre al día**, y **toda decisión
de producto o de diseño se le pregunta a él**. Se aplica siempre que se use esta skill para desarrollar
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

Los planes no necesitan rama: si viven en un repositorio aparte (por ejemplo `captaru-team`), se hace
commit en su `main` en cada transición.

**Push:** todo se integra en local. El push (de ramas, del plan o de la integradora) solo se hace si se
acordó con Paulo durante la planificación —por ejemplo, push al terminar cada fase verificada y
testeada—, y esa decisión se anota en el `plan.md`. Si no se acordó, no se hace push.

## 3. Decisiones: preguntar siempre

- **Antes de decidir algo de producto, de diseño, de alcance, de seguridad con contrapartidas o de
  versión, pregunta a Paulo.** Presenta 2 a 4 opciones con la recomendada en primer lugar y su motivo,
  y espera su respuesta. No elijas por tu cuenta y lo cuentes después.
- Si un subagente propone una decisión, o la toma, súbela a Paulo antes de integrarla.
- Las preguntas abiertas de cada fase van en «Pendiente» hasta que Paulo las responda. Después se
  anota la decisión, con su fecha, en el archivo de la fase.
- No se pregunta lo que se puede averiguar leyendo el repositorio, ni las convenciones ya acordadas
  (formato de ramas, commits o versiones).

## 4. Flujo con rama integradora (opcional)

Si Paulo pide probar un conjunto de fases antes de llevarlas a `develop`:

```
develop ──▶ feat/<integradora>
              ├──▶ {tipo}/<versión>-<slug>  (cada fase sale de la integradora actualizada)
              └──  code review → merge --no-ff a la integradora → subir versión y changelog
feat/<integradora> ──(todo probado)──▶ develop ──▶ PR a main ──▶ tag
```

- La versión se sube en el merge a la integradora, no en la rama de la fase, para que las fases
  paralelas no choquen en `package.json`.
- Se hace una revisión de código por fase antes de integrarla, y se aplican sus correcciones.
- La rama de la fase se borra al integrarla.
- Todos estos merges son locales; nada se sube sin el acuerdo de push tomado en la planificación.
