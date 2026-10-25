# INFORME ACADÉMICO COMPARATIVO: R SHINY VS. MICROSOFT POWER BI
## Análisis de Customer Experience (CX), Net Promoter Score (NPS) y Riesgo de Churn en Operadores de Telefonía Móvil
### Caso de Estudio: Comunidad Universitaria UNA - Puno ($N = 109$)

---

**Curso:** Analítica y Visualización de Datos / Business Intelligence  
**Docente Evaluador:** M.Sc. Fred Torres Cruz  
**Ponderación:** 20 Puntos  
**Fecha:** Octubre 2026  
**Repositorio GitHub:** [telecom-cx-shiny-vs-powerbi](https://github.com/dairxp/telecom-cx-shiny-vs-powerbi)  

---

## 1. RESUMEN EJECUTIVO

El presente informe expone un estudio comparativo formal entre dos de las plataformas más representativas de la analítica de datos moderna: **R Shiny** (paradigma *Code-First* reactivo y de computación estadística) y **Microsoft Power BI** (paradigma *Low-Code* de Business Intelligence corporativo). 

Para evaluar ambas herramientas en condiciones reales de producción analítica, se recolectó y curó un dataset empírico primario ($N = 109$ respuestas válidas) correspondiente a estudiantes de la **Universidad Nacional del Altiplano (UNA Puno)**. La investigación analiza la calidad de servicio percibida, el índice de recomendación neta (**NPS**), la satisfacción del cliente (**CSAT** ponderado) y la tasa de riesgo de fuga (**Churn**) de los cuatro principales operadores de telecomunicaciones del Perú: **Claro**, **Entel**, **Bitel** y **Movistar**.

Ambas plataformas fueron sometidas a los mismos requerimientos de negocio, implementando un pipeline de datos estructurado en formato **Star Schema** y visualizaciones analíticas avanzadas. El análisis demuestra que mientras **Power BI** destaca por su rapidez de modelado multidimensional, gobernanza nativa y facilidades de filtrado cruzado empresarial, **R Shiny** ofrece una superioridad categórica e insustituible en inferencia estadística avanzada (pruebas ANOVA, correlaciones no paramétricas de Spearman, distribuciones asimétricas) y personalización visual sin restricciones de licenciamiento propietario.

---

## 2. METODOLOGÍA Y FICHA TÉCNICA DEL ESTUDIO

### 2.1. Ficha Metodológica de la Investigación

| Parámetro | Detalle Metodológico |
| :--- | :--- |
| **Población Objetivo** | Estudiantes matriculados de pregrado y posgrado de la UNA Puno |
| **Instrumento de Medición** | Formulario psicométrico digital de 13 ítems estructurados |
| **Tamaño Muestral ($N$)** | $N = 109$ respuestas válidas y no duplicadas |
| **Áreas Académicas Representadas** | Ingenierías ($42.2\%$, $n=46$), Ciencias Sociales ($36.7\%$, $n=40$), Biomédicas ($21.1\%$, $n=23$) |
| **Escala Psicométrica** | Escala Likert de 5 puntos (1: Muy insatisfecho / Muy mala $\rightarrow$ 5: Muy satisfecho / Muy buena) |
| **Arquitectura de Almacenamiento** | Modelo Estrella (`Fact_Respuestas`, `Dim_Estudiante`, `Dim_Operador`, `Fact_PercepcionOperadores`, `Fact_FallasLugar`) |

### 2.2. Definición Operacional de Variables Sintéticas

1. **CSAT General Ponderado ($CSAT_{score}$):**  
   Promedio aritmético de las 5 dimensiones técnicas evaluadas: Cobertura de señal ($X_1$), Velocidad de internet ($X_2$), Atención al cliente ($X_3$), Precio del servicio ($X_4$) y Cantidad de datos ($X_5$):
   $$CSAT_{score} = \frac{\sum_{i=1}^{5} X_i}{5}$$

2. **Net Promoter Score (NPS):**  
   Basado en la intención declarada de recomendar el operador actual:
   * *Promotores:* Aquellos que responden "Definitivamente sí" ($20.18\%$).
   * *Pasivos:* "Probablemente sí" y "No estoy seguro" ($59.63\%$).
   * *Detractores:* "Probablemente no" y "Definitivamente no" ($20.18\%$).
   $$NPS = \% \text{Promotores} - \% \text{Detractores}$$

3. **Riesgo de Churn (Fuga de Clientes):**  
   Variable ordinal multivariable que cruza la intención de cambio en 6 meses con el índice de satisfacción CSAT, segmentando a los usuarios en **Bajo** (fidelizado), **Medio** (en observación) y **Alto** (en peligro crítico de migración).

---

## 3. HALLAZGOS CLAVE DEL ANÁLISIS EXPLORATORIO (EDA)

A partir del procesamiento de los 109 estudiantes, se determinaron los siguientes resultados empíricos:

### Tabla 1: Diagnóstico Comparativo de Operadores en la UNA Puno

| Operador | Muestra ($n$) | Market Share | CSAT Promedio | NPS Score | Riesgo Churn Alto | Diagnóstico de Mercado |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Entel** | 28 | $25.7\%$ | **3.86** | **+21.4** | 21.4% | **Líder en Satisfacción:** Máxima valoración en velocidad y cobertura universitaria. |
| **Claro** | 34 | **31.2%** | **3.58** | **+5.9** | 20.6% | **Líder de Cuota:** Mayor preferencia estudiantil y menor riesgo de churn. |
| **Bitel** | 33 | $30.3\%$ | **3.35** | **-6.1** | 30.3% | **Económico pero Polarizado:** Fuerte en datos/precio, penalizado en señal rural. |
| **Movistar** | 14 | $12.8\%$ | **3.01** | **-42.9** | **50.0%** | **Crisis de Fuga:** Puntuación crítica; la mitad de sus usuarios planea retirarse. |

### Hallazgos Estadísticos Inferenciales
* **Prueba ANOVA Unidireccional ($F = 4.333, p = 0.0064$):**  
  Existe una diferencia estadísticamente significativa en el nivel de satisfacción CSAT entre los operadores con un nivel de confianza del $99\%$ ($\alpha = 0.01$). Entel se distancia cuantitativamente de Movistar y Bitel.
* **Correlación de Rangos de Spearman:**  
  La insatisfacción en *Velocidad de Internet* ($r_s = -0.38$) y *Cobertura* ($r_s = -0.34$) son los mayores detonantes correlacionados con la fuga de clientes hacia otros operadores.
* **Homogeneidad Inter-Facultades ($p = 0.335$):**  
  La prueba ANOVA por área académica demostró que no existen diferencias significativas entre estudiantes de Ingenierías, Biomédicas y Sociales respecto a su nivel de satisfacción, evidenciando que las limitaciones de conectividad en Puno afectan transversalmente a toda la comunidad.

---

## 4. MATRIZ DE EVALUACIÓN COMPARATIVA FORMAL: SHINY VS. POWER BI

A continuación se desarrolla la comparativa técnica multidimensional, contrastando la arquitectura de ejecución, costes, modelado y usabilidad.

| Criterio de Evaluación | R Shiny (Code-First) | Microsoft Power BI (Low-Code) | Ganador / Justificación Técnica |
| :--- | :--- | :--- | :--- |
| **1. Inferencia Estadística y Análisis Avanzado** | **Sobresaliente.** Soporte nativo para pruebas paramétricas/no paramétricas (ANOVA, Chi-cuadrado, Spearman, regresión, clustering) con paquetes de CRAN (`stats`, `fmsb`). | **Básico/Limitado.** DAX es un lenguaje de álgebra relacional de tablas, no un motor estadístico. Requiere scripts embebidos de R/Python que son lentos y bloquean interactividad. | 🏆 **R Shiny.** Insuperable para análisis inferencial, bioestadística y econometría. |
| **2. Modelado Dimensional y ETL** | **Código puro (Tidyverse).** Requiere pipelines manuales en scripts (`dplyr`, `tidyr`, Python). No posee interfaz gráfica visual para relaciones. | **Sobresaliente.** Power Query (M) y motor VertiPaq tabular permiten diseñar esquemas en estrella, tablas puente y relaciones 1 a muchos visualmente. | 🏆 **Power BI.** El modelado dimensional corporativo es sumamente ágil e intuitivo. |
| **3. UI/UX y Personalización Visual** | **Libertad absoluta.** Control al 100% mediante HTML5, CSS3 personalizado (`custom.css`), Bootstrap 5 (`bslib`) y gráficos dinámicos con Plotly. | **Estandarizada y Rígida.** Depende de paneles fijos, temas JSON preconfigurados y visuales de la tienda AppSource (muchos de pago). | 🏆 **R Shiny.** Estética moderna tipo aplicación web profesional sin limitaciones corporativas. |
| **4. Interactividad y Filtros Cruzados** | **Explícita.** Requiere definir reactivos (`reactive`, `observeEvent`) y módulos Shiny (`moduleServer`) para propagar cambios entre gráficos. | **Nativa y Automática.** El motor DAX propaga filtros contextuales (*cross-filtering*) entre todas las visuales de la página con un solo clic. | 🏆 **Power BI.** Experiencia analítica de exploración rápida sin escribir lógica reactiva. |
| **5. Curva de Aprendizaje y Velocidad** | **Alta.** Exige dominar R, programación reactiva cliente-servidor, manipulación de datos y maquetación web. | **Baja/Media.** Perfil accesible para analistas de negocio, usuarios de Excel y administradores con nociones básicas de DAX. | 🏆 **Power BI.** Reducción dramática del *Time-to-Market* para dashboards estándar. |
| **6. Infraestructura, Despliegue y Costes** | **Código Abierto (Open Source).** Se puede desplegar sin coste de licencias en servidores Linux (Shiny Server, Docker, Posit Cloud). | **Propietario.** Requiere suscripciones por usuario (Power BI Pro: ~$10/mes/usuario) o licencias Premium/Fabric de miles de dólares mensuales. | 🏆 **R Shiny.** Ideal para universidades y organizaciones públicas con presupuesto restringido. |
| **7. Control de Versiones y Trabajo en Equipo** | **Excelente.** Todo es código fuente plano (`.R`, `.css`), integrándose perfectamente con ramas de Git, Pull Requests y CI/CD. | **Mejorado con `.pbip`.** El nuevo formato PBIP y TMDL permite versionar metadatos en Git, pero el visor visual sigue atado a Power BI Desktop en Windows. | 🏆 **R Shiny.** Mayor compatibilidad nativa con entornos DevOps y desarrollo colaborativo. |

---

## 5. EVIDENCIAS GRÁFICAS DE IMPLEMENTACIÓN PAREADA

Para evidenciar la implementación simultánea del caso de estudio, se estructuraron las siguientes equivalencias analíticas en ambas herramientas:

### 5.1. Métrica 1: Resumen Ejecutivo y Tarjetas KPI
* **En R Shiny:** Construido con tarjetas reactivas `bslib::value_box` alimentadas por la función modular `calc_nps()`, incorporando iconografía vectorial Bootstrap y semáforos condicionales en tiempo real según los filtros del Sidebar.
* **En Power BI:** Implementado con el objeto visual *Nueva Tarjeta (New Card Visual)* vinculado a las medidas DAX `[NPS Score]`, `[CSAT Promedio]` y `[% Tasa Churn Alto]`, aplicando reglas de formato condicional con valores hexadecimales.

### 5.2. Métrica 2: Diagnóstico CSAT y Percepción Competitiva
* **En R Shiny:** Gráfico de telaraña / radar dinámico mediante `plotly::plot_ly(type = "scatterpolar")` que compara a los 4 operadores en las 5 dimensiones simultáneamente, complementado con Boxplots interactivos para estudiar la asimetría y varianza de los datos.
* **En Power BI:** Resuelto mediante matrices cruzadas multidimensionales y gráficos de barras horizontales agrupadas por dimensión, complementado con visuales tipo matriz de fallas.

### 5.3. Métrica 3: Análisis de Causa Raíz de Fuga (Churn)
* **En R Shiny:** Matriz interactiva de correlación de Spearman generada dinámicamente con mapa de calor de calor divergente y pruebas ANOVA reactivas que devuelven el valor $F$ y $p$-valor exactos.
* **En Power BI:** Árbol de Descomposición (*Decomposition Tree*) de Power BI impulsado por Inteligencia Artificial para ramificar el Churn: *Factor decisivo $\rightarrow$ Principal problema $\rightarrow$ Operador*.

---

## 6. CONCLUSIONES Y RECOMENDACIONES ESTRATÉGICAS

1. **Complementariedad sobre Competencia:** R Shiny y Power BI no son tecnologías excluyentes, sino complementarias en una arquitectura de datos corporativa moderna. 
2. **Cuándo adoptar Power BI:**
   - Para reportes operacionales diarios de Business Intelligence empresarial.
   - Cuando los usuarios finales requieren autoservicio (*Self-Service BI*) y exploración mediante filtros cruzados inmediatos.
   - En empresas con ecosistema Microsoft preexistente (Office 365, Teams, Azure).
3. **Cuándo adoptar R Shiny:**
   - En proyectos científicos, académicos, bioestadísticos o financieros que exijan inferencia estadística rigurosa, modelos de machine learning en producción o algoritmos personalizados.
   - En organizaciones que buscan eliminar costes recurrentes de licenciamiento por usuario mediante infraestructura de código abierto.
   - Cuando se requiere una aplicación web personalizada con flujos interactivos que van más allá de un simple lienzo de reportería.

---

**Firma del Investigador:**  
*Estudiante del Programa de Posgrado / Analítica de Datos*  
*Universidad Nacional del Altiplano - Puno*
