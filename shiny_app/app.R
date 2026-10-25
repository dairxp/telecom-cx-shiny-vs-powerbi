# ==============================================================================
# app.R - Aplicación Central R Shiny
# Proyecto: Comparativa Shiny vs. Power BI (Analítica de Customer Experience CX)
# Docente: Fred Torres Cruz | Caso: Comunidad Universitaria UNA Puno (N = 109)
# ==============================================================================

# Cargar configuración global y módulos
source("global.R")
source("modules/mod_kpis.R")
source("modules/mod_satisfaction.R")
source("modules/mod_churn_correlations.R")
source("modules/mod_pain_points.R")

# --- INTERFAZ DE USUARIO (UI) ---
ui <- page_navbar(
  title = "Telecom CX Analytics | UNA Puno",
  id = "nav_main",
  theme = app_theme,
  fillable = FALSE,
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  
  # Barra Lateral (Sidebar) con Filtros Globales Reactivos
  sidebar = sidebar(
    title = "Filtros Analíticos",
    width = 280,
    open = "desktop",
    
    # 1. Filtro Operador
    checkboxGroupInput(
      inputId = "filtro_operador",
      label = "Operador Telefónico:",
      choices = c("Entel", "Claro", "Bitel", "Movistar"),
      selected = c("Entel", "Claro", "Bitel", "Movistar")
    ),
    
    hr(),
    
    # 2. Filtro Área Académica
    selectInput(
      inputId = "filtro_area",
      label = "Área Académica (UNA):",
      choices = c("Todas las Áreas", "Ingenierías", "Ciencias Sociales", "Biomédicas"),
      selected = "Todas las Áreas"
    ),
    
    # 3. Filtro Género
    checkboxGroupInput(
      inputId = "filtro_genero",
      label = "Género:",
      choices = c("Masculino", "Femenino"),
      selected = c("Masculino", "Femenino")
    ),
    
    # 4. Filtro Antigüedad
    selectInput(
      inputId = "filtro_antiguedad",
      label = "Tiempo de Uso:",
      choices = c(
        "Todas las Antigüedades",
        "Menos de 6 meses",
        "6 meses a 1 año",
        "1 a 2 años",
        "Más de 2 años"
      ),
      selected = "Todas las Antigüedades"
    ),
    
    br(),
    
    # Botón para restablecer filtros
    actionButton(
      inputId = "btn_reset",
      label = "Restablecer Filtros",
      icon = icon("rotate-left"),
      class = "btn btn-outline-secondary w-100"
    ),
    
    hr(),
    
    # Metadatos del Estudio
    div(
      class = "small text-muted",
      p(strong("Estudio:"), " CX & Riesgo Churn"),
      p(strong("Población:"), " Univ. UNA Puno"),
      p(strong("Muestra:"), " N = 109 encuestados"),
      p(strong("Semestre:"), " 2026-I")
    )
  ),
  
  # Pestaña 1: Resumen Ejecutivo & KPIs
  nav_panel(
    title = "Resumen Ejecutivo & KPIs",
    icon = bsicons::bs_icon("speedometer2"),
    mod_kpis_ui("kpis")
  ),
  
  # Pestaña 2: Diagnóstico CSAT (Radar & Boxplots)
  nav_panel(
    title = "Diagnóstico CSAT (Radar)",
    icon = bsicons::bs_icon("radar"),
    mod_satisfaction_ui("satisfaction")
  ),
  
  # Pestaña 3: Inferencia Estadística & Churn
  nav_panel(
    title = "Inferencia Estadística & Churn",
    icon = bsicons::bs_icon("graph-up"),
    mod_churn_correlations_ui("churn")
  ),
  
  # Pestaña 4: Puntos de Dolor & Datos
  nav_panel(
    title = "Puntos de Dolor & Datos",
    icon = bsicons::bs_icon("geo-alt-fill"),
    mod_pain_points_ui("pain_points")
  ),
  
  # Controles Adicionales en la barra superior (Modo Oscuro)
  nav_spacer(),
  nav_item(
    input_dark_mode(id = "dark_mode", mode = "light")
  )
)

# --- SERVIDOR (SERVER) ---
server <- function(input, output, session) {
  
  # Observador para Restablecer Filtros
  observeEvent(input$btn_reset, {
    updateCheckboxGroupInput(session, "filtro_operador", selected = c("Entel", "Claro", "Bitel", "Movistar"))
    updateSelectInput(session, "filtro_area", selected = "Todas las Áreas")
    updateCheckboxGroupInput(session, "filtro_genero", selected = c("Masculino", "Femenino"))
    updateSelectInput(session, "filtro_antiguedad", selected = "Todas las Antigüedades")
  })
  
  # Expresión Reactiva: Dataset Filtrado Globalmente
  r_data <- reactive({
    data <- df_curado
    
    # 1. Filtro Operador
    if (!is.null(input$filtro_operador) && length(input$filtro_operador) > 0) {
      data <- data %>% filter(operador_actual %in% input$filtro_operador)
    } else {
      # Si desmarcan todo, devolver dataframe vacío
      return(data[0, ])
    }
    
    # 2. Filtro Área Académica
    if (!is.null(input$filtro_area) && input$filtro_area != "Todas las Áreas") {
      data <- data %>% filter(area_academica == input$filtro_area)
    }
    
    # 3. Filtro Género
    if (!is.null(input$filtro_genero) && length(input$filtro_genero) > 0) {
      data <- data %>% filter(genero %in% input$filtro_genero)
    } else {
      return(data[0, ])
    }
    
    # 4. Filtro Antigüedad
    if (!is.null(input$filtro_antiguedad) && input$filtro_antiguedad != "Todas las Antigüedades") {
      data <- data %>% filter(antiguedad_uso == input$filtro_antiguedad)
    }
    
    data
  })
  
  # Invocar Módulos
  mod_kpis_server("kpis", r_data)
  mod_satisfaction_server("satisfaction", r_data)
  mod_churn_correlations_server("churn", r_data)
  mod_pain_points_server("pain_points", r_data)
}

# Iniciar Aplicación
shinyApp(ui = ui, server = server)
