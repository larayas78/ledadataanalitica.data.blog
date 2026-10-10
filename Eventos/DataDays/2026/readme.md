# Menos pipelines, más gobierno

**El patrón dinámico con metadata DAMA en Microsoft Fabric**

Material de la charla de **Leda Araya** (Primus Data) en **Data Day Colombia 2026**, sábado 10 de octubre de 2026.

---

## De qué se trata

Un pipeline por tabla funciona con tres tablas. Con cincuenta, cada cambio se repite cincuenta veces y nadie sabe con
certeza qué se cargó, cuándo ni de quién es cada dato.

La propuesta: **un solo motor y un archivo de configuración por fuente**. Agregar una fuente es agregar un archivo, el
pipeline no se toca, y cada tabla llega a la plataforma con su dueño y su clasificación. El motor deja su propia bitácora
en cada corrida, y cuatro áreas de DAMA-DMBOK (metadatos, integración, calidad y gobierno) se vuelven visibles.

## Qué hay aquí

| Archivo | Qué es |
|---|---|
| [`Guia_Motor_Metadata_Fabric.md`](Guia_Motor_Metadata_Fabric.md) | La guía del patrón: cuándo conviene, la convención de nombre, el contrato YAML, los componentes del motor, la bitácora y su relación con DAMA |

## Para llevártelo hoy

1. **Define una convención de nombre:** `dominio_fuente`.
2. **Escribe un YAML por fuente:** de dónde vienen los datos, qué entidades y a dónde van, con su dueño y su sensibilidad.
3. **Haz que el motor deje su bitácora:** inicio, fin, estado y filas.

El detalle de cada paso está en la [guía](Guia_Motor_Metadata_Fabric.md).

## Para seguir leyendo

La charla se apoya en la serie de **Javier Loria** en Primus Data:

1. [*Bronze debería ser aburrido*](https://www.primusdata.net/2026/04/21/bronze-deberia-ser-aburrido/)
2. [*Metadatos hasta el fondo*](https://www.primusdata.net/2026/04/25/metadatos-hasta-el-fondo/)
3. [*Cicatrices de producción*](https://www.primusdata.net/2026/05/11/cicatrices-de-produccion/)
4. [*Actuamos sobre los metadatos*](https://www.primusdata.net/2026/05/25/actuamos-sobre-los-metadatos/)
5. [*Demos que hablan tu idioma*](https://www.primusdata.net/2026/07/14/demos-que-hablan-tu-idioma-datos-sinteticos-para-fabric-y-power-bi/)

Los datos de la demo son 100 % sintéticos, generados con su
[Generador de Datos Sintéticos para Fabric](https://github.com/JavierSQL/GeneradorDatosSinteticos) (licencia MIT).

## ¿Quieres implementarlo en tu organización?

En [Primus Data](https://www.primusdata.net/contacto) lo hacemos.

---

© 2026 Leda Araya · Primus Data. Todos los derechos reservados
