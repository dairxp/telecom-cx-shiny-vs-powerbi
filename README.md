# Telecom Customer Experience (CX): R Shiny vs. Microsoft Power BI

<div align="center">

![R](https://img.shields.io/badge/R-4.6.1-blue?logo=r&logoColor=white)
![Shiny](https://img.shields.io/badge/Shiny-1.14.0-3884ff?logo=rstudio&logoColor=white)
![Positron](https://img.shields.io/badge/Positron-IDE-4B32C3?logo=visualstudiocode&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-PBIP%20%7C%20TMDL-F2C811?logo=powerbi&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green)
![Study Sample](https://img.shields.io/badge/Muestra-N%20%3D%20109-informational)

**Estudio Analítico y Comparativo de Plataformas de Business Intelligence y Computación Estadística**  
*Análisis de Customer Experience (CX), Net Promoter Score (NPS) y Riesgo de Churn en telefonía móvil para la comunidad universitaria de la UNA Puno.*

[📊 Explorar Shiny App](#-cómo-ejecutar-la-aplicación-shiny) • [📈 Modelo Power BI](#-módulo-power-bi-formato-pbip) • [📑 Informe Académico (20 Puntos)](docs/informe_comparativo.md)

</div>

---

## 📌 Contexto del Proyecto

* **Asignatura:** Analítica y Visualización de Datos / Business Intelligence
* **Docente Evaluador:** M.Sc. Fred Torres Cruz
* **Caso de Estudio:** Calidad de servicio y fidelización en telefonía móvil (Claro, Entel, Bitel, Movistar) en estudiantes de la **Universidad Nacional del Altiplano (UNA Puno)**.
* **Muestra:** $N = 109$ respuestas válidas clasificadas en Ingenierías ($42.2\%$), Ciencias Sociales ($36.7\%$) y Biomédicas ($21.1\%$).

---

## 🏛️ Arquitectura del Repositorio

```text
telecom-cx-shiny-vs-powerbi/
├── data/
│   ├── raw/
│   │   └── respuestas_encuesta_raw.csv      # Data original íntegra (109 respuestas)
│   └── processed/
│       ├── dataset_curado.csv               # Data limpia y tipada para R Shiny
│       └── data_model_powerbi/              # Tablas del Modelo Estrella para Power BI
│           ├── Fact_Respuestas.csv
│           ├── Fact_PercepcionOperadores.csv
│           ├── Fact_FallasLugar.csv
│           ├── Dim_Estudiante.csv
│           └── Dim_Operador.csv
├── shiny_app/
│   ├── app.R                                # Entrada principal Shiny (bslib / navegación)
│   ├── global.R                             # Configuración, librerías y datos globales
│   ├── modules/
│   │   ├── mod_kpis.R                       # Módulo de tarjetas ejecutivas y NPS
│   │   ├── mod_satisfaction.R               # Módulo CSAT y gráfico de Radar
│   │   ├── mod_churn_correlations.R         # Inferencia estadística (ANOVA & Spearman)
│   │   └── mod_pain_points.R                # Incidencia de fallas territoriales y DT
│   └── www/
│       └── custom.css                       # Estilos premium y diseño responsivo
├── powerbi/
│   ├── telecom.pbip                         # Proyecto moderno Power BI Project (PBIP)
│   ├── telecom.SemanticModel/               # Modelo semántico y metadatos TMDL
│   ├── telecom.Report/                      # Layout y visualizaciones del reporte
│   └── dax_measures.md                      # Catálogo formal de fórmulas DAX
├── docs/
│   ├── imagenes/                            # Evidencias y capturas de pantalla
│   │   ├── shiny/
│   │   └── powerbi/
│   └── informe_comparativo.md               # Informe formal académico comparativo (20 pts)
├── scripts/
│   ├── fase1_data_prep.py                   # Pipeline ETL y generación de Modelo Estrella
│   └── run_shiny.R                          # Script de lanzamiento directo
├── base.md                                  # Especificación del plan maestro
└── README.md
```

---

## 🚀 Cómo Ejecutar la Aplicación Shiny

### Opción 1: En Positron / RStudio
1. Abre el proyecto en **Positron** o **RStudio**.
2. Abre el archivo [`shiny_app/app.R`](file:///f:/dxp-projects/DevBasics/R%20y%20statistics/telecom-cx-shiny-vs-powerbi/shiny_app/app.R).
3. Haz clic en el botón **"Run App"** en la barra superior.

### Opción 2: Desde la Consola de R
```r
# Instalar paquetes requeridos (si aún no los tienes)
install.packages(c("shiny", "bslib", "bsicons", "plotly", "DT", "dplyr", "tidyr", "readr", "ggplot2"))

# Ejecutar el dashboard
shiny::runApp("shiny_app")
```

---

## 📊 Módulo Power BI (Formato PBIP)

El reporte corporativo está implementado en formato **`.pbip` (Power BI Project)**, utilizando arquitectura dimensional (*Star Schema*):

* **Dimensiones:** `Dim_Estudiante` y `Dim_Operador`.
* **Hechos:** `Fact_Respuestas`, `Fact_PercepcionOperadores` y `Fact_FallasLugar`.
* **Catálogo de Medidas DAX:** Consulta las fórmulas documentadas en [`powerbi/dax_measures.md`](file:///f:/dxp-projects/DevBasics/R%20y%20statistics/telecom-cx-shiny-vs-powerbi/powerbi/dax_measures.md).

---

## 📈 Hallazgos Principales del Estudio ($N = 109$)

| Operador | Muestra ($n$) | Market Share | CSAT (1-5) | NPS Score | Churn Alto | Veredicto Analítico |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Entel** | 28 | $25.7\%$ | **3.86** | **+21.4** | 21.4% | **Líder en Satisfacción:** Calidad superior en velocidad y cobertura. |
| **Claro** | 34 | **31.2%** | **3.58** | **+5.9** | 20.6% | **Líder en Cuota:** Preferencia mayoritaria y retención estable. |
| **Bitel** | 33 | $30.3\%$ | **3.35** | **-6.1** | 30.3% | **Económico:** Fuerte en datos/precio, penalizado en zonas rurales. |
| **Movistar** | 14 | $12.8\%$ | **3.01** | **-42.9** | **50.0%** | **Crisis de Fuga:** El 50% de sus usuarios planea migrar de operador. |

### Inferencia Estadística Destacada
* **ANOVA ($F = 4.333, p = 0.0064$):** Diferencia estadísticamente significativa en satisfacción entre operadores al 99% de confianza.
* **Correlación de Spearman ($r_s = -0.38$):** Las deficiencias en velocidad de internet son el factor determinante de la fuga de clientes.

---

## 📑 Informe Formal Comparativo
El informe académico detallado con la matriz técnica de 6 ejes de evaluación (arquitectura, modelado, UI/UX, costos y gobernanza) está disponible en:  
👉 **[docs/informe_comparativo.md](docs/informe_comparativo.md)**

---

## 👥 Créditos y Autores
* **Investigador / Autor:** Estudiante de la Comunidad Universitaria UNA Puno.
* **Docente del Curso:** Fred Torres Cruz.
* **Año Académico:** 2026.
