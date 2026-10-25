# Plan Maestro de Implementación: Comparativa Shiny vs. Power BI (Nivel Maestría)

> **Proyecto:** Análisis de Customer Experience (CX), Net Promoter Score (NPS) y Riesgo de Churn en Operadores de Telefonía Móvil (Caso: Comunidad Universitaria UNA - Puno)  
> **Curso:** Analítica y Visualización de Datos / Business Intelligence  
> **Docente:** Fred Torres Cruz  
> **Ponderación:** 20 puntos  

---

## 1. Identidad del Proyecto en GitHub

### 1.1. Nombre del Repositorio
```text
telecom-cx-shiny-vs-powerbi
```
*(Alternativa formal: `telco-analytics-shiny-vs-powerbi`)*

### 1.2. Descripción del Repositorio
> *Estudio analítico y comparativo de herramientas de Business Intelligence y reporting (R Shiny vs. Microsoft Power BI): Análisis de Customer Experience (CX), NPS y Riesgo de Churn en telefonía móvil para la comunidad universitaria de la UNA Puno.*

### 1.3. Topics / Tags
`r-shiny` `power-bi` `customer-experience` `churn-analysis` `nps` `eda` `business-intelligence` `telecom-analytics` `data-visualization`

---

## 2. Estructura Arquitectónica del Repositorio

```text
telecom-cx-shiny-vs-powerbi/
├── data/
│   ├── raw/
│   │   └── respuestas_encuesta_raw.csv      # Data original (101 respuestas)
│   └── processed/
│       ├── dataset_curado.csv               # Data limpia y tipada para Shiny
│       └── data_model_powerbi/              # Tablas del modelo estrella para PBI
│           ├── Fact_Respuestas.csv
│           ├── Fact_PercepcionOperadores.csv
│           ├── Dim_Estudiante.csv
│           └── Dim_Operador.csv
├── shiny_app/
│   ├── app.R                                # Entrada principal Shiny (o ui.R / server.R)
│   ├── global.R                             # Carga de librerías, datos y funciones globales
│   ├── modules/
│   │   ├── mod_kpis.R                       # Módulo de tarjetas ejecutivas y NPS
│   │   ├── mod_satisfaction.R               # Módulo CSAT y radar chart
│   │   ├── mod_churn_correlations.R         # Módulo estadístico y matriz de correlaciones
│   │   └── mod_pain_points.R                # Módulo de fallas y ubicaciones
│   └── www/
│       └── custom.css                       # Estilos premium (bslib / CSS personalizado)
├── powerbi/
│   ├── telecom_cx_dashboard.pbix            # Archivo de Power BI Desktop
│   ├── dax_measures.md                      # Documentación formal de medidas DAX
│   └── data_model_diagram.png               # Diagrama del modelo estrella
├── docs/
│   ├── imagenes/                            # Capturas de pantalla de ambas plataformas
│   │   ├── shiny/
│   │   └── powerbi/
│   └── informe_comparativo.pdf              # Informe final académico para entrega
├── README.md                                # Presentación ejecutiva del proyecto
└── LICENSE
```

---

## 3. Diccionario y Curación de Datos ($N = 101$)

### 3.1. Dimensiones y Métricas Derivadas Clave
A partir de las 13 preguntas, se estructuran las siguientes variables sintéticas:

1. **CSAT General Ponderado ($CSAT_{score}$):**  
   Promedio de las 5 dimensiones evaluadas en la escala Likert (Cobertura, Velocidad, Soporte, Precio, Datos).
2. **Clasificación NPS (Net Promoter Score) - Pregunta 12:**  
   * *Promotores:* "Definitivamente sí"
   * *Pasivos:* "Probablemente sí", "No estoy seguro"
   * *Detractores:* "Probablemente no", "Definitivamente no"  
   $$\text{NPS} = \% \text{Promotores} - \% \text{Detractores}$$
3. **Riesgo de Churn (Fuga de clientes) - Pregunta 13 combinada con CSAT:**  
   * *Alto:* Considera cambiar en $\le$ 6 meses y CSAT $< 3$.
   * *Medio:* Dudoso ("Tal vez") o insatisfecho en precio/cobertura.
   * *Bajo:* Fidelizado ("Definitivamente no").
4. **Desagregación de Fallas Geográficas (Pregunta 9):**  
   One-hot encoding / Dummies para variables múltiples: `falla_universidad`, `falla_casa`, `falla_centro_puno`, `falla_rural`.

---

## 4. Fases de Implementación Paso a Paso

### FASE 1: Limpieza, Modelado y Feature Engineering (R / Python)
* **Objetivo:** Tomar el archivo original de Google Forms / Excel y generar datasets listos para análisis.
* **Actividades:**
  1. Renombrar columnas a formato normalizado `snake_case`.
  2. Tipar variables ordinales (factores ordenados para escalas Likert del 1 al 5).
  3. Crear columnas calculadas: `nps_category`, `csat_promedio`, `riesgo_churn`.
  4. Generar dataset largo (*tidy*) para la matriz de percepción competitiva (Pregunta 11: Bitel, Claro, Entel, Movistar).
  5. Exportar datasets a `data/processed/`.

---

### FASE 2: Módulo EDA en R Shiny (Enfoque Estadístico e Inferencia)
* **Objetivo:** Construir una aplicación web analítica interactiva y reactiva que destaque la potencia computacional de R.
* **Stack sugerido:** `shiny`, `bslib` (diseño temático moderno), `plotly`, `DT`, `ggcorrplot`, `fmsb` (radar chart).
* **Vistas del Dashboard:**
  * **Tab 1: Resumen Ejecutivo & KPIs Reactivos:**
    * Tarjetas de valor: Muestra total ($N$), NPS General, CSAT Promedio, % Riesgo Churn.
    * Filtros dinámicos reactivos: Por Área Académica (Ingenierías, Biomédicas, Sociales), Género y Tiempo de uso.
    * Distribución de cuota de mercado (*Market Share*) por operador.
  * **Tab 2: Diagnóstico Multidimensional CSAT (Satisfacción):**
    * Gráfico de Radar / Telaraña (*Spider Plot*) comparando el rendimiento de los 4 operadores en las 5 dimensiones.
    * Distribución de satisfacción con *Boxplots* interactivos para identificar dispersión y asimetría.
  * **Tab 3: Inferencia Estadística y Análisis de Churn:**
    * Matriz de Correlación de Spearman interactiva: ¿Qué dimensión correlaciona más con la intención de cambio de operador?
    * Prueba de independencia Chi-cuadrado / ANOVA reactivo: Evaluar si el nivel de satisfacción varía significativamente según el área académica.
  * **Tab 4: Puntos de Dolor y Cobertura Territorial:**
    * Gráfico de barras de fallas críticas según entorno geográfico (Campus UNA vs Casa vs Centro de Puno vs Zonas rurales).
    * Tabla de datos interactiva (`DT`) con opción de exportación a CSV/Excel.

---

### FASE 3: Módulo EDA en Power BI (Enfoque Business Intelligence Corporativo)
* **Objetivo:** Diseñar un reporte de nivel empresarial aplicando buenas prácticas de modelado dimensional (Star Schema), DAX y UX/UI.
* **Modelo de Datos:**
  * Relación de tablas `Dim_Estudiante`, `Dim_Operador` hacia `Fact_Respuestas` (1 a muchos).
  * Tabla puente para preguntas de selección múltiple (Ubicación de problemas).
* **Medidas DAX Clave a implementar:**
  ```dax
  // Total de Respuestas
  Total Encuestados = COUNTROWS(Fact_Respuestas)

  // Promedio CSAT
  CSAT Promedio = AVERAGE(Fact_Respuestas[csat_promedio])

  // Cálculo de NPS
  % Promotores = DIVIDE(CALCULATE(COUNTROWS(Fact_Respuestas), Fact_Respuestas[nps_category] = "Promotor"), [Total Encuestados], 0)
  % Detractores = DIVIDE(CALCULATE(COUNTROWS(Fact_Respuestas), Fact_Respuestas[nps_category] = "Detractor"), [Total Encuestados], 0)
  NPS Score = ([% Promotores] - [% Detractores]) * 100

  // Tasa de Riesgo de Fuga
  Tasa Churn Alto = DIVIDE(CALCULATE(COUNTROWS(Fact_Respuestas), Fact_Respuestas[riesgo_churn] = "Alto"), [Total Encuestados], 0)
  ```
* **Páginas del Reporte Power BI:**
  * **Página 1: Executive Dashboard (CX & Market Overview):**
    * Tarjetas KPI con formato condicional (NPS con semáforo según benchmarks de la industria).
    * Gráfico de barras horizontales de satisfacción por operador.
    * *Slicers* modernos sincronizados entre páginas.
  * **Página 2: Churn & Pain Points Diagnostics:**
    * Diagrama de árbol (*Decomposition Tree*) explicando las causas raíz del riesgo de churn (Factor determinante $\rightarrow$ Problema principal $\rightarrow$ Operador).
    * Gráfico de dispersión (Cuadrante: Importancia vs Satisfacción).
  * **Página 3: Benchmark de Percepción de Marca:**
    * Matriz comparativa de imagen de marca (Bitel, Claro, Entel, Movistar) valorada por clientes propios vs no-clientes.

---

### FASE 4: Elaboración del Informe Comparativo (Núcleo de la Rúbrica)
* **Objetivo:** Redactar un documento formal de posgrado sustentando la comparativa técnica entre ambas herramientas.
* **Estructura del Informe:**
  1. **Resumen Ejecutivo.**
  2. **Metodología y Ficha Técnica del Estudio:** Población, instrumento de 13 ítems, tamaño muestral ($N = 101$).
  3. **Hallazgos Clave del EDA:** Principales insights descubiertos sobre Claro, Movistar, Entel y Bitel en la UNA Puno.
  4. **Matriz de Evaluación Comparativa (Shiny vs. Power BI):**
     * *Capacidad de Inferencia Estadística y Análisis Avanzado.*
     * *Facilidad de Modelado de Datos (Power Query / DAX vs. Tidyverse / R).*
     * *Experiencia de Usuario (UI/UX) y Diseño Visual.*
     * *Curva de Aprendizaje y Desarrollo (Low-Code vs. Code-First).*
     * *Despliegue, Infraestructura y Costos de Licenciamiento (Open Source vs. Power BI Pro/Premium).*
     * *Gobierno de Datos y Seguridad.*
  5. **Evidencias Gráficas:** Capturas pareadas demostrando la misma métrica resuelta en Shiny y en Power BI.
  6. **Conclusiones y Recomendaciones Estratégicas:** Cuándo adoptar cada herramienta según el caso de uso organizacional.

---

### FASE 5: Empaquetado y Entrega en GitHub
1. Inicializar repositorio local y conectar con GitHub remoto (`telecom-cx-shiny-vs-powerbi`).
2. Redactar `README.md` exhaustivo con:
   * Insignias (*badges*) de R, Shiny y Power BI.
   * GIFs o capturas en carrusel de ambos dashboards.
   * Pasos de reproducción para levantar Shiny localmente (`runApp()`).
   * Enlace de descarga del archivo `.pbix` y vista previa del PDF del informe.
3. Subir el código fuente limpio y documentado.
