# Modelo estrella

Grano: una fila por fecha, zona y empresa.

```mermaid
erDiagram
    DIM_FECHA ||--o{ FACT_VIAJES_DIA : FECHA
    DIM_ZONA ||--o{ FACT_VIAJES_DIA : ZONA_KEY
    DIM_EMPRESA ||--o{ FACT_VIAJES_DIA : EMPRESA_KEY

    DIM_FECHA {
        DATE FECHA PK
        DATE MES_INICIO
        NUMBER DIA_SEMANA
        BOOLEAN ES_FIN_SEMANA
        BOOLEAN ES_FESTIVO
        FLOAT LLUVIA_MM
    }
    DIM_ZONA {
        NUMBER ZONA_KEY PK
        VARCHAR ZONA
        VARCHAR BOROUGH
        VARCHAR SERVICE_ZONE
    }
    DIM_EMPRESA {
        NUMBER EMPRESA_KEY PK
        VARCHAR EMPRESA
    }
    FACT_VIAJES_DIA {
        DATE FECHA FK
        NUMBER ZONA_KEY FK
        NUMBER EMPRESA_KEY FK
        NUMBER VIAJES
        FLOAT INGRESO_TOTAL
        FLOAT PROPINA_TOTAL_ESTIMADA
        FLOAT DISTANCIA_TOTAL_ESTIMADA
    }

```

Las claves del diagrama son lógicas y se comprueban mediante SQL.
La clave compuesta del hecho es (FECHA, ZONA_KEY, EMPRESA_KEY).
DIM_ZONA conserva una fila por nombre, distrito y tipo de servicio.
Las dimensiones y el hecho se reconstruyen juntos para mantener
la correspondencia de las claves.
