# Catálogo Formal de Medidas DAX y Arquitectura del Modelo
## Proyecto: Telecom Customer Experience (CX) Analytics
### Docente: Fred Torres Cruz | Caso: Comunidad Universitaria UNA - Puno ($N = 109$)

---

## 1. Arquitectura del Modelo Dimensional (Star Schema)

El modelo de datos implementado en Power BI sigue las mejores prácticas de Ralph Kimball (Modelado Dimensional):

```
       +-----------------------+             +----------------------+
       |     Dim_Estudiante    |             |     Dim_Operador     |
       +-----------------------+             +----------------------+
       | PK: id_estudiante     |             | PK: id_operador      |
       |     edad              |             |     operador         |
       |     genero            |             |     color_hex        |
       |     area_academica    |             +----------+-----------+
       |     antiguedad_uso    |                        | 1
       +-----------+-----------+                        |
                   | 1                                  |
                   |                                    |
                   | *                                  | *
       +-----------+------------------------------------+-----------+
       |                       Fact_Respuestas                      |
       +------------------------------------------------------------+
       | PK: id_respuesta                                           |
       | FK: id_estudiante                                          |
       | FK: id_operador                                            |
       |     timestamp                                              |
       |     sat_cobertura, sat_velocidad, sat_atencion, sat_precio |
       |     sat_datos, csat_promedio                               |
       |     factor_importante, problema_principal                  |
       |     recomienda_texto, nps_category, nps_weight             |
       |     cambio_texto, riesgo_churn                             |
       |     falla_universidad, falla_casa, falla_rural, sin_fallas |
       +----------------------------+-------------------------------+
                                    | 1
                                    |
                 +------------------+------------------+
                 | *                                   | *
       +---------+------------------+        +---------+------------------+
       | Fact_PercepcionOperadores  |        |     Fact_FallasLugar       |
       +----------------------------+        +----------------------------+
       | FK: id_respuesta           |        | FK: id_respuesta           |
       | FK: id_operador_evaluado   |        |     lugar_falla            |
       |     score_percepcion (1-5) |        +----------------------------+
       |     es_cliente_actual (0/1)|
       +----------------------------+
```

---

## 2. Medidas DAX Fundamentales

### 2.1. Métricas de Volumen y Muestra
```dax
// Total de encuestados en el contexto de filtro actual
Total Encuestados = COUNTROWS(Fact_Respuestas)

// Total general sin filtros (para calcular porcentajes de participación)
Total Universo = CALCULATE(COUNTROWS(Fact_Respuestas), ALL(Fact_Respuestas))

// Cuota de Mercado en Muestra (% Market Share)
% Market Share = 
DIVIDE(
    [Total Encuestados],
    [Total Universo],
    0
)
```

---

### 2.2. Métricas de Satisfacción (CSAT)
```dax
// Promedio del Score CSAT (Escala 1 a 5)
CSAT Promedio = 
AVERAGE(Fact_Respuestas[csat_promedio])

// Satisfacción por Dimensiones Específicas
CSAT Cobertura = AVERAGE(Fact_Respuestas[sat_cobertura])
CSAT Velocidad = AVERAGE(Fact_Respuestas[sat_velocidad])
CSAT Atención  = AVERAGE(Fact_Respuestas[sat_atencion])
CSAT Precio    = AVERAGE(Fact_Respuestas[sat_precio])
CSAT Datos     = AVERAGE(Fact_Respuestas[sat_datos])

// Clasificación Semáforo CSAT
Estado CSAT = 
SWITCH(
    TRUE(),
    [CSAT Promedio] >= 3.7, "Favorable",
    [CSAT Promedio] >= 3.2, "Regular",
    "Crítico"
)
```

---

### 2.3. Métricas de Net Promoter Score (NPS)
```dax
// Total y Porcentaje de Promotores
Total Promotores = 
CALCULATE(
    COUNTROWS(Fact_Respuestas),
    Fact_Respuestas[nps_category] = "Promotor"
)

% Promotores = 
DIVIDE([Total Promotores], [Total Encuestados], 0)

// Total y Porcentaje de Pasivos
Total Pasivos = 
CALCULATE(
    COUNTROWS(Fact_Respuestas),
    Fact_Respuestas[nps_category] = "Pasivo"
)

% Pasivos = 
DIVIDE([Total Pasivos], [Total Encuestados], 0)

// Total y Porcentaje de Detractores
Total Detractores = 
CALCULATE(
    COUNTROWS(Fact_Respuestas),
    Fact_Respuestas[nps_category] = "Detractor"
)

% Detractores = 
DIVIDE([Total Detractores], [Total Encuestados], 0)

// Net Promoter Score Oficial (-100 a +100)
NPS Score = 
([% Promotores] - [% Detractores]) * 100

// Etiqueta Visual de Semáforo para NPS
NPS Status Color = 
SWITCH(
    TRUE(),
    [NPS Score] > 15, "#10B981", // Verde (Excelente)
    [NPS Score] >= 0, "#F59E0B", // Amarillo/Ámbar (Neutro/Alerta)
    "#EF4444"                    // Rojo (Zona Crítica)
)
```

---

### 2.4. Métricas de Riesgo de Churn (Fuga de Clientes)
```dax
// Total de Clientes con Riesgo Alto de Abandono
Total Churn Alto = 
CALCULATE(
    COUNTROWS(Fact_Respuestas),
    Fact_Respuestas[riesgo_churn] = "Alto"
)

// Tasa de Riesgo de Abandono (% Churn Rate)
% Tasa Churn Alto = 
DIVIDE([Total Churn Alto], [Total Encuestados], 0)

// Total de Clientes Fidelizados (Riesgo Bajo)
Total Churn Bajo = 
CALCULATE(
    COUNTROWS(Fact_Respuestas),
    Fact_Respuestas[riesgo_churn] = "Bajo"
)

% Tasa Churn Bajo = 
DIVIDE([Total Churn Bajo], [Total Encuestados], 0)
```

---

### 2.5. Métricas de Incidencia Territorial de Fallas
```dax
// Total de incidencias reportadas en el Campus UNA Puno
Fallas Campus UNA = 
CALCULATE(
    COUNTROWS(Fact_FallasLugar),
    Fact_FallasLugar[lugar_falla] = "En la universidad"
)

// Total de incidencias reportadas en el Domicilio
Fallas en Casa = 
CALCULATE(
    COUNTROWS(Fact_FallasLugar),
    Fact_FallasLugar[lugar_falla] = "En mi casa"
)

// Total de incidencias reportadas en Zonas Rurales
Fallas Zonas Rurales = 
CALCULATE(
    COUNTROWS(Fact_FallasLugar),
    Fact_FallasLugar[lugar_falla] = "En zonas rurales"
)

// Total de incidencias en el Centro de Puno
Fallas Centro Puno = 
CALCULATE(
    COUNTROWS(Fact_FallasLugar),
    Fact_FallasLugar[lugar_falla] = "En el centro de Puno"
)
```

---

### 2.6. Percepción Competitiva Cruzada
```dax
// Calificación promedio que otorgan clientes y no clientes a cada operador
Score Percepcion Marca = 
AVERAGE(Fact_PercepcionOperadores[score_percepcion])

// Percepción de clientes propios
Percepcion Clientes Propios = 
CALCULATE(
    AVERAGE(Fact_PercepcionOperadores[score_percepcion]),
    Fact_PercepcionOperadores[es_cliente_actual] = 1
)

// Percepción de la competencia (No Clientes)
Percepcion No Clientes = 
CALCULATE(
    AVERAGE(Fact_PercepcionOperadores[score_percepcion]),
    Fact_PercepcionOperadores[es_cliente_actual] = 0
)
```
