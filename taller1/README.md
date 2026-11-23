# Taller 1 · Competencia entre plataformas

Autor: Juan Monterrosa — GitHub: jumonter10.
Modalidad: individual, con autorización del profesor.
Caso A: competencia entre plataformas, enero–marzo de 2024.

## Modelo
Una fila del hecho representa una fecha, una zona y una empresa.
El modelo está en CURSO.T1 y parte del paquete oficial en CURSO.LAB4.

## Reproducción
Requisitos: COMPUTE_WH y las tablas del Lab 4:
DAILY_ZONE_METRICS, DIM_ZONA y FESTIVOS_2024.
El origen debe contener 46.715 filas y 60.268.466 viajes.

Ejecutar en orden:
1. 01_estrella.sql
2. 02_carga.sql
3. 03_preguntas.sql
4. 04_chequeos.sql
5. El verificador oficial curso/clase04/taller1/verificar_t1.sql.

Los dos primeros archivos reconstruyen CURSO.T1.
Repetir ambos en orden no acumula datos.

## Evidencias
- autoverificacion.txt: resultado del verificador oficial.
- chequeos_observados.csv: ocho controles ejecutados en Snowflake.
- query_profile.png: captura del perfil de A1.
- costos.md: mediciones y alcance.
- memo.md: resultados e interpretación.
- RETOS.md: reto implementado.

## Responsabilidades
Al trabajar individualmente, el autor asume análisis, modelado,
ingeniería de datos y calidad/costos.
