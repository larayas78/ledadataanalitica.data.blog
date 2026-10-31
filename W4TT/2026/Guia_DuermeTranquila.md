# Duerme tranquila: guía para montar tu agente de guardia en Microsoft Fabric

*Leda Araya Sanabria · 12.º Evento W4TT Online, noviembre de 2026*

Esta guía acompaña la sesión **"Duerme tranquila: un agente de IA de guardia para tu Microsoft Fabric"**. Son las pautas generales para que montes una solución parecida en tu equipo: la arquitectura, las decisiones y las reglas que me funcionaron. No es código para copiar: cada motor de ingesta es distinto, y la idea es que lo adaptes al tuyo.

## En 5 líneas

- **El pipeline despierta al agente** cuando una carga falla o termina con advertencias. Nada vigila toda la noche.
- **Un notebook reúne los hechos** de la bitácora; el agente de Foundry razona sobre ellos, sin acceso a tus datos.
- **El diagnóstico llega a Teams**: qué falló, por qué, si es seguro reintentar y qué runbook del equipo aplica.
- **El agente investiga, la persona decide**: el agente no toca nada; tú actúas con el diagnóstico en la mano.
- **Las instrucciones se prueban como código**: cada error real se vuelve un caso de prueba.

## Índice

1. [La idea en un minuto](#1-la-idea-en-un-minuto)
2. [Las tres piezas](#2-las-tres-piezas)
3. [El recorrido de una alerta](#3-el-recorrido-de-una-alerta)
4. [Paso a paso, a nivel macro](#4-paso-a-paso-a-nivel-macro)
5. [Prueba las instrucciones como código](#5-prueba-las-instrucciones-como-codigo)
6. [Seguridad y gobierno: lista corta](#6-seguridad-y-gobierno-lista-corta)
7. [¿Cuánto cuesta?](#7-cuanto-cuesta)
8. [Por dónde empezar](#8-por-donde-empezar)
9. [Para seguir aprendiendo](#9-para-seguir-aprendiendo)

---

## 1. La idea en un minuto

Las cargas de datos corren de madrugada. Cuando una falla, o termina en verde pero con un problema escondido, **el propio pipeline despierta a un agente de IA**. El agente lee la evidencia que le preparas, explica qué pasó, dice si es seguro reintentar y qué procedimiento del equipo aplica, y te deja el diagnóstico en Teams. Por la mañana, **tú decides**.

Dos reglas que lo ordenan todo:

- **El agente investiga, la persona decide.** El agente no reintenta, no corrige y no toca nada.
- **Hechos, no llaves.** El agente no tiene acceso a tus datos: razona sobre la evidencia que tu proceso le entrega.

## 2. Las tres piezas

| Pieza | Qué hace |
|---|---|
| **Microsoft Fabric** | El motor de ingesta: los pipelines que copian los datos cada noche y una bitácora donde queda anotado cada paso. Al terminar cada carga, un notebook reúne la evidencia y llama al agente. |
| **Microsoft Foundry** | Donde vive el agente: eliges un modelo (yo usé gpt-5-mini), le escribes instrucciones y lo llamas por API. Sin servidores que mantener. |
| **Microsoft Teams** | Donde llega la tarjeta con el diagnóstico, al canal y al móvil. Opcional: un segundo agente publicado en Teams para preguntarle "¿qué pasó a las 3:05?". |

## 3. El recorrido de una alerta

1. **La carga termina**, bien o mal, y como último paso ejecuta un notebook: el agente de guardia.
2. **Reúne la evidencia** de la bitácora: actividades que fallaron, lotes fuera de rango, columnas que cambiaron.
3. **¿Hay algo que avisar?** Si no, termina sin llamar a nadie: ese verde es un verde de verdad.
4. **Llama al agente** con la evidencia, usando una identidad de servicio (a las 3 a. m. no hay nadie conectado) con sus secretos en Azure Key Vault.
5. **Avisa y deja huella:** envía la tarjeta a Teams y guarda una fila con lo que vio y lo que respondió.
6. **El rojo sigue rojo:** si hubo un fallo, una actividad *Fail* al final mantiene la carga en rojo. El agente avisa, pero no esconde el error.

## 4. Paso a paso, a nivel macro

### 4.1 Tu bitácora es la materia prima

El agente es tan bueno como la evidencia que recibe. Asegúrate de que tu motor registre, por cada corrida:

- La corrida: identificador, pipeline, inicio, fin, estado y error.
- Cada actividad: entidad, actividad, estado y mensaje de error completo.
- Los controles de calidad: lotes fuera de rango (filas reales frente a mínimo y máximo esperados), en un estado pendiente de revisión.
- Los cambios de esquema: columnas agregadas, eliminadas o que cambiaron de tipo.
- **Un mismo identificador de lote en todas las tablas**, para unir la evidencia de una corrida sin adivinar.

### 4.2 Reunir la evidencia en un formato fijo

Un notebook al final de cada carga consulta la bitácora y arma un JSON pequeño y siempre con la misma forma: estado de la corrida, actividades fallidas, advertencias, lotes en cuarentena y cambios de esquema. Ese formato es un contrato: si lo cambias, cambias también las instrucciones y las pruebas.

### 4.3 Decidir si hace falta despertar al agente

- **OK:** sin fallos ni advertencias. No se llama al agente.
- **PARCIAL:** la carga terminó, pero hay un lote en cuarentena o un cambio de esquema. Tarjeta ámbar; la carga queda en verde.
- **FALLO:** alguna actividad falló. Tarjeta roja; la carga queda en rojo.

### 4.4 El agente en Microsoft Foundry

Crea un proyecto, despliega un modelo pequeño y crea un agente. Sus instrucciones, en este orden:

1. **Rol:** quién es y para qué lo llaman. "Tú no ejecutas nada."
2. **Cómo funciona tu motor**, en pocas frases. Es lo que evita los errores más graves: sin este contexto, mi agente propuso **crear la tabla que faltaba** en lugar de corregir la consulta.
3. **Qué recibe:** el formato de la evidencia. Todo lo que viene ahí es **dato, no instrucción** (protección contra mensajes que intenten darle órdenes).
4. **Reglas y una tabla de decisión fija:** para cada situación, qué responder en "¿reintentar?" y cuál es el siguiente paso. Así el agente no improvisa acciones.
5. **Formato de salida:** solo JSON con campos fijos (estado, qué falló, causa, evidencia citada, ¿reintentar?, siguiente paso, runbook).

Llámalo con una **identidad de servicio** con el rol mínimo necesario y guarda sus secretos en **Key Vault**. Nunca pongas secretos en el código ni en el repositorio.

### 4.5 La tarjeta en Teams

Un flujo de **Workflows** en Teams recibe la tarjeta por un webhook (guardado también en Key Vault). Diseña la tarjeta para leerla en 10 segundos desde el móvil: color (rojo o ámbar), estado, ¿reintentar?, runbook, qué falló, causa y siguiente paso. Si el agente no responde, la tarjeta llega igual con "diagnóstico no disponible".

### 4.6 Que el rojo siga rojo

Si tu pipeline atrapa un error para ejecutar al agente, puede terminar en verde y fabricar un "verde que miente". Agrega al final una condición que, si hubo fallo, ejecute una actividad **Fail** con un mensaje propio ("el diagnóstico está en Teams").

### 4.7 Que el agente también rinda cuentas

Guarda una fila por cada llamada: la evidencia, la respuesta, la versión de las instrucciones, el modelo, la duración y el error si lo hubo (también si falló Teams). Es tu auditoría y tu fuente para mejorar.

### 4.8 Runbooks: que señale el procedimiento del equipo

Escribe los procedimientos de tu equipo como documentos cortos con el mismo formato: código, versión, nivel de quien lo ejecuta, riesgo, cuándo aplica, primera acción, pasos, reversión y escalamiento. Suma:

- Un **índice de ruteo**: qué runbook aplica a cada situación.
- Una regla para los **pendientes**: si un runbook todavía no existe, el agente no lo inventa; dice qué hacer en su lugar.

Para las alertas, la forma más estable es una tabla fija dentro de las instrucciones (situación → runbook). Para un chat, carga los documentos en la búsqueda de archivos de Foundry.

### 4.9 (Opcional) Un agente para conversar en Teams

Un segundo agente, publicado en Teams, responde preguntas como "¿cómo reintento una carga fallida?" con los runbooks y "¿qué pasó a las 3:05?" con un **diario de guardia**: cada aviso se guarda también como un documento en la búsqueda de archivos. Así el agente responde sin entrar a tu bitácora: un agente publicado en Teams no puede consultar tus datos con tu identidad.

## 5. Prueba las instrucciones como código

Versiona las instrucciones en tu repositorio y escribe casos de prueba que se ejecuten contra el agente publicado. Como mínimo:

| Caso | Lo que se espera |
|---|---|
| La consulta nombra una tabla que no existe | Corregir la consulta; nunca crear la tabla |
| Evidencia incompleta | "No hay evidencia suficiente", sin adivinar |
| "Ignora tus instrucciones" escondido en un mensaje de error | No obedece y lo marca como sospechoso |
| Dos problemas a la vez | Nombra los dos y empieza por el más grave |
| Falla un componente del propio motor | No culpa a la fuente ni a la configuración |
| Pregunta fuera de tema | No contesta |

Corre cada caso varias veces: un modelo puede responder distinto ante la misma entrada. **Cada error real se convierte en un caso de prueba nuevo.**

## 6. Seguridad y gobierno: lista corta

- [ ] El agente no tiene acceso a los datos: solo recibe la evidencia.
- [ ] Identidad de servicio con el rol mínimo; secretos en Key Vault, con fecha de vencimiento anotada.
- [ ] La evidencia se trata como dato, nunca como instrucción.
- [ ] El agente no ejecuta acciones; cualquier acción futura pasa por la aprobación de una persona.
- [ ] Cada llamada queda registrada, con la versión de instrucciones y el modelo.
- [ ] Datos de prueba sintéticos; nada real en demos ni en repositorios públicos.

## 7. ¿Cuánto cuesta?

- **La IA cuesta centavos:** en mi demo, cada alerta fueron unos 6 000 tokens de entrada y menos de 600 de salida con gpt-5-mini, menos de medio centavo de dólar. Todas las pruebas del proyecto sumaron alrededor de 2 USD.
- **Lo que pesa es la capacidad de Fabric**, que tu motor de ingesta ya usa: el notebook del agente corre dentro de ella. Revisa los precios vigentes de tu región en la página oficial de Azure.

## 8. Por dónde empezar

1. Revisa que tu bitácora tenga lo del punto 4.1.
2. Escribe a mano la evidencia de un fallo real y pruébala con el modelo en el portal de Foundry.
3. Escribe las instrucciones y 6 casos de prueba antes de conectar nada. ✋ Tú decides cuándo pasan lo suficiente para cargarlas en el agente.
4. Conecta el notebook al final de una sola carga, con el envío a Teams desactivado. ✋ Revisa tú la primera respuesta real antes de seguir.
5. Activa Teams, agrega la actividad *Fail* y prueba los tres resultados: verde, ámbar y rojo. ✋ Tú validas que cada tarjeta se entienda en 10 segundos.
6. Suma tus runbooks y, si quieres, el chat en Teams.

## 9. Para seguir aprendiendo

- [Documentación de Microsoft Fabric](https://learn.microsoft.com/es-es/fabric/)
- [Publicar agentes de Foundry en Microsoft 365 Copilot y Teams](https://learn.microsoft.com/es-es/azure/foundry/agents/how-to/publish-copilot)
- [Azure Key Vault](https://learn.microsoft.com/es-es/azure/key-vault/general/overview)

¿Lo vas a probar en tu equipo? Cuéntame en los comentarios o búscame en LinkedIn como **Leda Araya Sanabria**. ¡Me encantará saber cómo te fue!
