# Cargar configuración global y módulos
source("global.R")
source("modules/mod_kpis.R")
source("modules/mod_satisfaction.R")
source("modules/mod_churn_correlations.R")
source("modules/mod_pain_points.R")

# --- INTERFAZ DE USUARIO (UI) ---
ui <- page_navbar(
  title = "Telecom CX Analytics UNA Puno",
  id = "nav_main",
  theme = app_theme,
  fillable = FALSE,
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  
  # Barra Lateral (Sidebar) Compacta Sin Scroll
  sidebar = sidebar(
    title = NULL,
    width = 250,
    open = "desktop",
    
    # Banner oficial de operadoras
    tags$div(
      class = "text-center mb-2",
      tags$img(
        src = "moviles.png",
        style = "max-height: 44px; width: 100%; object-fit: contain; border: 1px solid #e2e8f0; border-radius: 2px;",
        alt = "Bitel, Claro, Entel, Movistar"
      )
    ),
    
    # 1. Filtro Operador (Por defecto todas seleccionadas)
    checkboxGroupInput(
      inputId = "filtro_operador",
      label = "Operador Telefónico:",
      choices = c("Entel", "Claro", "Bitel", "Movistar"),
      selected = c("Entel", "Claro", "Bitel", "Movistar"),
      inline = TRUE
    ),
    
    # 2. Filtro Área Académica
    selectInput(
      inputId = "filtro_area",
      label = "Área Académica:",
      choices = c("Todas las Áreas", "Ingenierías", "Ciencias Sociales", "Biomédicas"),
      selected = "Todas las Áreas"
    ),
    
    # 3. Filtro Género (Por defecto todos seleccionados)
    checkboxGroupInput(
      inputId = "filtro_genero",
      label = "Género:",
      choices = c("Masculino", "Femenino"),
      selected = c("Masculino", "Femenino"),
      inline = TRUE
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
    
    # Botón Restablecer
    actionButton(
      inputId = "btn_reset",
      label = "Restablecer Filtros",
      class = "btn btn-outline-secondary btn-sm w-100 mt-1"
    ),
    
    # Metadatos del Estudio compactos
    div(
      class = "text-muted small text-center mt-2",
      style = "font-size: 0.74rem;",
      "Comunidad UNA Puno · N = 109"
    )
  ),
  
  # Pestaña 1: Resumen Ejecutivo y KPIs (Sin iconos)
  nav_panel(
    title = "Resumen Ejecutivo y KPIs",
    mod_kpis_ui("kpis")
  ),
  
  # Pestaña 2: Diagnóstico CSAT (Sin iconos)
  nav_panel(
    title = "Diagnóstico CSAT (Radar)",
    mod_satisfaction_ui("satisfaction")
  ),
  
  # Pestaña 3: Inferencia Estadística y Churn (Sin iconos)
  nav_panel(
    title = "Inferencia Estadística y Churn",
    mod_churn_correlations_ui("churn")
  ),
  
  # Pestaña 4: Puntos de Dolor y Datos (Sin iconos)
  nav_panel(
    title = "Puntos de Dolor y Datos",
    mod_pain_points_ui("pain_points")
  ),
  
  # Modo Oscuro / Claro
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
    
    # 1. Filtro Operador: si hay casillas marcadas, filtrar; si está vacío, mostrar todas
    if (!is.null(input$filtro_operador) && length(input$filtro_operador) > 0) {
      data <- data %>% filter(operador_actual %in% input$filtro_operador)
    }
    
    # 2. Filtro Área Académica
    if (!is.null(input$filtro_area) && input$filtro_area != "Todas las Áreas") {
      data <- data %>% filter(area_academica == input$filtro_area)
    }
    
    # 3. Filtro Género: si hay casillas marcadas, filtrar; si está vacío, mostrar ambos
    if (!is.null(input$filtro_genero) && length(input$filtro_genero) > 0) {
      data <- data %>% filter(genero %in% input$filtro_genero)
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
