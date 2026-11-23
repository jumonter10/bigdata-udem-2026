USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE SCHEMA CURSO.T1;

-- A1: ingresos y viajes por empresa y mes.
CREATE OR REPLACE VIEW A1 AS
SELECT D.MES_INICIO AS MES, E.EMPRESA,
       SUM(F.VIAJES) AS VIAJES,
       ROUND(SUM(F.INGRESO_TOTAL), 2) AS INGRESOS
FROM FACT_VIAJES_DIA F
JOIN DIM_FECHA D ON F.FECHA = D.FECHA
JOIN DIM_EMPRESA E ON F.EMPRESA_KEY = E.EMPRESA_KEY
GROUP BY D.MES_INICIO, E.EMPRESA;

SELECT * FROM A1 ORDER BY MES, EMPRESA;
-- Interpretación: Uber suma 44440688 viajes y 1383046448.43
-- de ingreso total; Lyft, 15827778 y 474649141.57.
-- Marzo tiene más viajes que enero: Uber +8.24 %, Lyft +8.32 %.
-- Son totales mensuales, no tasas diarias ajustadas por duración del mes.

-- A2: propina promedio ponderada por viajes.
CREATE OR REPLACE VIEW A2 AS
SELECT E.EMPRESA, SUM(F.VIAJES) AS VIAJES,
       ROUND(SUM(F.PROPINA_TOTAL_ESTIMADA)
             / NULLIF(SUM(F.VIAJES), 0), 2)
             AS PROPINA_PROMEDIO_PONDERADA
FROM FACT_VIAJES_DIA F
JOIN DIM_EMPRESA E ON F.EMPRESA_KEY = E.EMPRESA_KEY
GROUP BY E.EMPRESA;

SELECT * FROM A2 ORDER BY EMPRESA;
-- Interpretación: Lyft 1.18 y Uber 1.06 por viaje.
-- Se pondera por viajes; no se promedian grupos con igual peso.
-- Es una aproximación porque los promedios del origen están redondeados.

-- A3: tres zonas con más viajes por empresa.
CREATE OR REPLACE VIEW A3 AS
SELECT E.EMPRESA, Z.ZONA, SUM(F.VIAJES) AS VIAJES,
       RANK() OVER (
           PARTITION BY E.EMPRESA ORDER BY SUM(F.VIAJES) DESC
       ) AS PUESTO
FROM FACT_VIAJES_DIA F
JOIN DIM_EMPRESA E ON F.EMPRESA_KEY = E.EMPRESA_KEY
JOIN DIM_ZONA Z ON F.ZONA_KEY = Z.ZONA_KEY
GROUP BY E.EMPRESA, Z.ZONA
QUALIFY PUESTO <= 3;

SELECT * FROM A3 ORDER BY EMPRESA, PUESTO, ZONA;
-- Interpretación:
-- Uber: JFK 810070, LaGuardia 773675, East Village 614619.
-- Lyft: LaGuardia 295689, JFK 247170, East Village 227918.
-- RANK conserva empates: puede devolver más de tres filas por empresa.

-- Base mensual completa para A4 y A5.
CREATE OR REPLACE VIEW CUOTAS_MENSUALES AS
WITH meses AS (
    SELECT DISTINCT MES_INICIO AS MES FROM DIM_FECHA
),
zonas_observadas AS (
    SELECT DISTINCT ZONA_KEY FROM FACT_VIAJES_DIA
),
mensual AS (
    SELECT DATE_TRUNC('month', FECHA)::DATE AS MES,
           ZONA_KEY, EMPRESA_KEY, SUM(VIAJES) AS VIAJES
    FROM FACT_VIAJES_DIA
    GROUP BY 1, 2, 3
),
serie AS (
    SELECT M.MES, Z.ZONA_KEY, E.EMPRESA_KEY,
           COALESCE(V.VIAJES, 0) AS VIAJES
    FROM meses M
    CROSS JOIN zonas_observadas Z
    CROSS JOIN DIM_EMPRESA E
    LEFT JOIN mensual V
      ON V.MES = M.MES AND V.ZONA_KEY = Z.ZONA_KEY
     AND V.EMPRESA_KEY = E.EMPRESA_KEY
),
totales AS (
    SELECT *, SUM(VIAJES) OVER (
        PARTITION BY ZONA_KEY, MES
    ) AS VIAJES_ZONA_MES
    FROM serie
)
SELECT MES, ZONA_KEY, EMPRESA_KEY, VIAJES, VIAJES_ZONA_MES,
       100.0 * VIAJES / NULLIF(VIAJES_ZONA_MES, 0) AS CUOTA_PCT
FROM totales;

-- A4: cuota por empresa, zona y mes.
CREATE OR REPLACE VIEW A4 AS
SELECT C.MES, Z.ZONA, E.EMPRESA, C.VIAJES, C.VIAJES_ZONA_MES,
       ROUND(C.CUOTA_PCT, 4) AS CUOTA_PCT
FROM CUOTAS_MENSUALES C
JOIN DIM_ZONA Z ON C.ZONA_KEY = Z.ZONA_KEY
JOIN DIM_EMPRESA E ON C.EMPRESA_KEY = E.EMPRESA_KEY;

SELECT * FROM A4 ORDER BY ZONA, MES, EMPRESA;
-- Interpretación: el denominador es el total de viajes de cada zona y mes.
-- El resultado contiene 1566 combinaciones (261 zonas x 3 meses x 2 empresas).
-- En el trimestre completo, la cuota global ponderada por viajes es
-- Uber 73.74 % y Lyft 26.26 %; no es el promedio simple de cuotas zonales.
-- Una zona-mes sin viajes tiene cuota NULL, no cero.

-- A5: variación mensual y cruces por encima de 70 %.
CREATE OR REPLACE VIEW A5 AS
WITH cambios AS (
    SELECT *, LAG(CUOTA_PCT) OVER (
        PARTITION BY ZONA_KEY, EMPRESA_KEY ORDER BY MES
    ) AS CUOTA_ANTERIOR
    FROM CUOTAS_MENSUALES
)
SELECT C.MES, Z.ZONA, E.EMPRESA,
       ROUND(C.CUOTA_PCT, 4) AS CUOTA_PCT,
       ROUND(C.CUOTA_ANTERIOR, 4) AS CUOTA_ANTERIOR_PCT,
       ROUND(C.CUOTA_PCT - C.CUOTA_ANTERIOR, 4) AS VARIACION_PP,
       CASE
         WHEN C.CUOTA_PCT IS NULL THEN 'SIN VIAJES EN LA ZONA'
         WHEN C.CUOTA_ANTERIOR IS NULL THEN 'SIN BASE COMPARABLE'
         WHEN C.CUOTA_ANTERIOR <= 70 AND C.CUOTA_PCT > 70 THEN 'SI'
         ELSE 'NO'
       END AS CRUZA_70
FROM cambios C
JOIN DIM_ZONA Z ON C.ZONA_KEY = Z.ZONA_KEY
JOIN DIM_EMPRESA E ON C.EMPRESA_KEY = E.EMPRESA_KEY;

SELECT * FROM A5 ORDER BY ZONA, EMPRESA, MES;
SELECT * FROM A5 WHERE CRUZA_70 = 'SI' ORDER BY MES, ZONA;
-- Interpretación: se observan 34 cruces zona-mes, todos de Uber.
-- Astoria Park pasa de 67.0379 % a 75.4491 % en febrero:
-- +8.4112 puntos porcentuales.
-- Enero carece de mes anterior dentro del paquete.
-- Completar meses evita que LAG salte silenciosamente un mes ausente.
-- 70 % es un umbral descriptivo, no una conclusión legal de monopolio.
