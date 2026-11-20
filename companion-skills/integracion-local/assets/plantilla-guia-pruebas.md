# Pruebas: <qué aporta este worktree, en una línea>

| Campo   | Valor                                                                                   |
| ------- | --------------------------------------------------------------------------------------- |
| Rama    | `<rama-exacta>`                                                                         |
| Worktree | `<carpeta del worktree>`                                                               |
| Issues  | #<n> o —                                                                                |
| Estado  | ⏳ Pendiente de probar                                                                   |
| Lote    | (se rellena al promocionar: vX.Y.Z)                                                     |

<!-- Estados válidos: ⏳ Pendiente de probar · ✅ Probado DD-MM-YYYY · ❌ Falla: <motivo> · ➖ Sin prueba manual: <motivo> -->

## Qué aporta

Dos o tres frases para el usuario, sin jerga: qué cambia y dónde se ve.

## Preparación

- Migraciones nuevas: <ninguna | lista> (se aplican al levantar el entorno de la integradora).
- Datos o usuario necesarios: <sitio, rol, ficha concreta…>.
- Variables o servicios: <ninguno | cuál y dónde está en el baúl> (nunca el valor).

## Pruebas paso a paso

Enlaces sobre el entorno local de la integradora (los da `/integracion-local probar`). Cada paso con
lo que hay que hacer y lo que debe pasar.

1. Abre <enlace local> → <acción>. **Debe:** <resultado esperado>.
2. …

## Regresión: lo que NO debe haber cambiado

- <pantalla o flujo vecino que conviene mirar>

## Resultado

(Lo rellena la sesión con lo que diga el usuario al probar: fecha, qué pasó, capturas si las hay.)
