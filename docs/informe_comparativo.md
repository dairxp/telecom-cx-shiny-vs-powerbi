# INFORME ACADÉMICO COMPARATIVO: R SHINY VS. MICROSOFT POWER BI
## Análisis de Customer Experience (CX), Net Promoter Score (NPS) y Riesgo de Churn en Operadores Móviles
### Caso de Estudio: Comunidad Universitaria UNA - Puno ($N = 109$)

---

* **Curso:** Business Intelligence  
* **Docente Evaluador:** M.Sc. Fred Torres Cruz  
* **Fecha:** Octubre 2026  
* **Repositorio GitHub:** [github.com/dairxp/telecom-cx-shiny-vs-powerbi](https://github.com/dairxp/telecom-cx-shiny-vs-powerbi)  
* **Módulo Shiny en Producción (Cloud):** [https://dairdev.shinyapps.io/telecom-cx-una-puno/](https://dairdev.shinyapps.io/telecom-cx-una-puno/)  

---

## 1. INTRODUCCIÓN

Este informe compara dos enfoques de analítica: **R Shiny** (código reactivo y estadística) y **Microsoft Power BI** (Business Intelligence visual). La evaluación se realizó con un dataset local de 109 estudiantes de la Universidad Nacional del Altiplano (UNA Puno) para medir la experiencia de cliente (Telecom CX: satisfacción CSAT, recomendación NPS y riesgo de fuga Churn) en Claro, Entel, Bitel y Movistar.

---

## 2. HALLAZGOS DEL MERCADO LOCAL (UNA PUNO)

El análisis exploratorio de los 109 casos revela un mercado estudiantil polarizado entre calidad de servicio y costo:

| Operador | Muestra ($n$) | Cuota (%) | CSAT Promedio (1-5) | NPS Score | Riesgo Churn Alto | Diagnóstico |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Entel** | 28 | 25.7% | **3.86** | **+21.4** | 21.4% | Líder en satisfacción; mejor velocidad y cobertura universitaria. |
| **Claro** | 34 | **31.2%** | 3.58 | +5.9 | **20.6%** | Mayor cuota de mercado y menor tasa de abandono. |
| **Bitel** | 33 | 30.3% | 3.35 | -6.1 | 30.3% | Fuerte en datos y precio, pero penalizado en zonas rurales. |
| **Movistar** | 14 | 12.8% | 3.01 | **-42.9** | **50.0%** | Situación crítica: la mitad de sus usuarios planea cambiar de operador. |

A nivel global, la muestra presenta un CSAT promedio de **3.51 / 5.0**, un NPS de **0.0** y un riesgo de fuga alto del **27.5%**. Una prueba ANOVA unidireccional confirma diferencias significativas de satisfacción entre operadoras ($F = 4.333, p = 0.0064$), y la correlación de Spearman ($r_s = -0.38$) identifica a la velocidad lenta de internet como el principal detonante del cambio de compañía.

---

## 3. MÓDULO EXPLORATORIO EN R SHINY

Módulo analítico interactivo desarrollado en código R y desplegado en la nube pública de Posit:

> **Aplicación en Vivo:** [https://dairdev.shinyapps.io/telecom-cx-una-puno/](https://dairdev.shinyapps.io/telecom-cx-una-puno/)

![Dashboard R Shiny](imagenes/shiny.png)

* **Interfaz:** Maquetación con `bslib` (Bootstrap 5), tarjetas KPI en tonos pastel y barra de filtros compacta para operadoras, área académica, género y antigüedad.
* **Visualizaciones:** Gráficos vectoriales en Plotly (cuota de mercado, desglose de NPS, distribución por facultades y fuga por permanencia).
* **Estadística:** Gráfico de radar polar de satisfacción, boxplots de dispersión, matriz de correlación de Spearman y cálculo de ANOVA en tiempo real.

---

## 4. MÓDULO EXPLORATORIO EN POWER BI

Módulo de Business Intelligence construido sobre un modelo dimensional en estrella (`Dim_Estudiante`, `Dim_Operador`, `Fact_Respuestas`, `Fact_PercepcionOperadores`, `Fact_FallasLugar`).

> **Nota de Despliegue:** Power BI requiere licencia Pro de pago para publicarse en la web; por ello se entrega como proyecto local (`.pbip` / `.pbix`) ejecutable en Power BI Desktop.

![Dashboard Power BI](imagenes/powerbi.png)

* **Medidas DAX Principales:**
  * `Total Encuestados = COUNTROWS(Fact_Respuestas)`
  * `CSAT Promedio = AVERAGE(Fact_Respuestas[csat_promedio])`
  * `NPS Score = ([% Promotores] - [% Detractores]) * 100`
  * `% Churn Alto = DIVIDE(CALCULATE(COUNTROWS(Fact_Respuestas), Fact_Respuestas[riesgo_churn] = "Alto"), [Total Encuestados], 0)`
* **Visualizaciones:** Tarjetas KPI, matriz comparativa, gráfico de anillos, barras apiladas y segmentadores sincronizados.
* **Interactividad:** Filtrado cruzado nativo (*cross-filtering*) en todo el lienzo con un solo clic.

---

## 5. COMPARATIVA TÉCNICA: SHINY VS. POWER BI

| Dimensión | R Shiny (Code-First) | Microsoft Power BI (Low-Code) | Veredicto |
| :--- | :--- | :--- | :--- |
| **KPIs Básicos** | Tarjetas `value_box` personalizables con HTML/CSS. | Tarjetas visuales nativas con formato condicional. | **Empate:** Ambas muestran los indicadores con claridad. |
| **Interactividad** | Filtros controlados por eventos `reactive()` en R. | **Filtrado cruzado nativo:** Selección con recálculo automático sin programar. | **Power BI:** Más ágil para exploración de negocio. |
| **Modelado ETL** | Scripts estructurados en Tidyverse (`dplyr`, `tidyr`). | **Power Query y VertiPaq:** Modelado visual en estrella con compresión columnar. | **Power BI:** Superior en diseño dimensional. |
| **Estadística** | **Avanzada:** ANOVA, correlación de Spearman y radar polar. | **Limitada:** DAX solo calcula agregaciones tabulares básicas. | **R Shiny:** Insuperable para investigación científica. |
| **Diseño UI** | **Total:** Control directo de CSS3, Bootstrap 5 y temas a medida. | **Rígida:** Limitada a la cuadrícula fija de Power BI. | **R Shiny:** Permite crear aplicaciones web personalizadas. |
| **Costos / Nube** | **Open Source:** Despliegue gratuito en shinyapps.io o Linux. | **Comercial:** Publicación web segura exige licencias Pro de pago. | **R Shiny:** Gran ventaja en costos para entornos educativos. |
| **Control de Versiones** | Archivos de texto plano (`.R`, `.css`) ideales para Git. | Mejorado recientemente con `.pbip` y metadatos TMDL. | **R Shiny:** Mayor compatibilidad nativa con flujos DevOps. |

---

## 6. CONCLUSIONES

El estudio empírico en la UNA Puno demostró que ambas plataformas representan con exactitud la dinámica del mercado móvil local: el liderazgo en calidad de Entel, la solidez comercial de Claro, la penetración económica de Bitel y la crítica intención de fuga en Movistar.

Power BI se consolida como la herramienta más eficiente para la reportería ejecutiva de Business Intelligence. Su modelado en estrella con Power Query y su filtrado cruzado automático permiten explorar datos de forma rápida e intuitiva sin escribir código reactivo.

Por su parte, R Shiny es insustituible cuando se requiere rigor estadístico, flexibilidad de diseño y despliegue web sin costos de licencia. La integración directa de pruebas inferenciales (ANOVA, Spearman) y la libertad visual de Bootstrap convierten a Shiny en la plataforma ideal para ciencia de datos y proyectos a medida. En un entorno profesional, ambas herramientas se complementan: Power BI para el seguimiento operativo diario y R Shiny para la analítica avanzada.

---

*Estudio desarrollado para la asignatura de Business Intelligence.*  
*Docente: Fred Torres Cruz · UNA Puno · Octubre 2026*
