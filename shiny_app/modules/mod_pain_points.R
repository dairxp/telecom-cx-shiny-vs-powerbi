# mod_pain_points.R - Módulo 4: Puntos de Dolor, Cobertura y Tabla Exportable
mod_pain_points_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Fila Superior: Gráfico de Fallas Geográficas & Problemas
    layout_column_wrap(
      width = 1/2,
      fill = FALSE,
      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          span("Incidencia de Fallas por Entorno Geográfico"),
          bsicons::bs_icon("geo-alt-fill")
        ),
        card_body(
          plotlyOutput(ns("plot_geo_issues"), height = "360px")
        )
      ),
      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          span("Principal Problema Experimentado por Operador"),
          bsicons::bs_icon("tools")
        ),
        card_body(
          plotlyOutput(ns("plot_main_issues"), height = "360px")
        )
      )
    ),
    
    br(),
    
    # Fila Inferior: Tabla de Datos Interactiva y Exportable
    card(
      card_header(
        class = "d-flex justify-content-between align-items-center",
        div(
          span("Explorador de Datos Detallado (Dataset Curado N=109)"),
          span(" - Filtros y descarga en tiempo real", class = "text-muted small")
        ),
        bsicons::bs_icon("table")
      ),
      card_body(
        DTOutput(ns("table_raw_data"))
      )
    )
  )
}

mod_pain_points_server <- function(id, r_data) {
  moduleServer(id, function(input, output, session) {
    
    # --- Gráfico 1: Fallas por Zona Territorial ---
    output$plot_geo_issues <- renderPlotly({
      req(r_data())
      
      df_geo <- r_data() %>%
        group_by(operador_actual) %>%
        summarise(
          `Campus UNA` = sum(falla_universidad, na.rm = TRUE),
          `En Casa` = sum(falla_casa, na.rm = TRUE),
          `Centro Puno` = sum(falla_centro_puno, na.rm = TRUE),
          `Zonas Rurales` = sum(falla_rural, na.rm = TRUE),
          `Sin Problemas` = sum(sin_fallas, na.rm = TRUE),
          .groups = "drop"
        ) %>%
        pivot_longer(
          cols = c(`Campus UNA`, `En Casa`, `Centro Puno`, `Zonas Rurales`, `Sin Problemas`),
          names_to = "Ubicación",
          values_to = "Casos"
        )
      
      if (nrow(df_geo) == 0) return(NULL)
      
      plot_ly(
        df_geo,
        x = ~Ubicación,
        y = ~Casos,
        color = ~operador_actual,
        colors = OPERATOR_COLORS,
        type = "bar"
      ) %>%
        layout(
          barmode = "group",
          xaxis = list(title = "Entorno Territorial"),
          yaxis = list(title = "N° Reportes de Fallas"),
          legend = list(orientation = "h", x = 0.1, y = -0.2),
          margin = list(t = 20, b = 50, l = 40, r = 20)
        ) %>%
        config(displayModeBar = FALSE)
    })
    
    # --- Gráfico 2: Problema Principal Experimentado ---
    output$plot_main_issues <- renderPlotly({
      req(r_data())
      
      df_prob <- r_data() %>%
        count(problema_principal, operador_actual) %>%
        group_by(problema_principal) %>%
        mutate(total = sum(n)) %>%
        ungroup() %>%
        arrange(desc(total))
      
      if (nrow(df_prob) == 0) return(NULL)
      
      plot_ly(
        df_prob,
        x = ~n,
        y = ~reorder(problema_principal, total),
        color = ~operador_actual,
        colors = OPERATOR_COLORS,
        type = "bar",
        orientation = "h"
      ) %>%
        layout(
          barmode = "stack",
          xaxis = list(title = "Cantidad de Estudiantes"),
          yaxis = list(title = ""),
          legend = list(orientation = "h", x = 0.1, y = -0.2),
          margin = list(t = 20, b = 40, l = 160, r = 20)
        ) %>%
        config(displayModeBar = FALSE)
    })
    
    # --- Tabla Interactiva con DT ---
    output$table_raw_data <- renderDT({
      req(r_data())
      
      df_display <- r_data() %>%
        select(
          ID = id_estudiante,
          Operador = operador_actual,
          Área = area_academica,
          Edad = edad,
          `CSAT Prom.` = csat_promedio,
          `NPS Categ.` = nps_category,
          `Riesgo Churn` = riesgo_churn,
          `Problema Principal` = problema_principal,
          `Factor Decisivo` = factor_importante
        )
      
      datatable(
        df_display,
        filter = "top",
        rownames = FALSE,
        extensions = c("Buttons"),
        options = list(
          pageLength = 8,
          lengthMenu = c(8, 15, 25, 50),
          dom = "Bfrtip",
          buttons = c("copy", "csv", "excel"),
          scrollX = TRUE,
          language = list(
            search = "Buscar en tabla:",
            lengthMenu = "Mostrar _MENU_ registros",
            info = "Mostrando _START_ a _END_ de _TOTAL_ registros",
            paginate = list(previous = "Anterior", `next` = "Siguiente")
          )
        ),
        class = "stripe hover compact table-bordered"
      ) %>%
        formatStyle(
          "Riesgo Churn",
          fontWeight = "bold",
          backgroundColor = styleEqual(c("Alto", "Medio", "Bajo"), c("#FEE2E2", "#FEF3C7", "#D1FAE5")),
          color = styleEqual(c("Alto", "Medio", "Bajo"), c("#991B1B", "#92400E", "#065F46"))
        ) %>%
        formatStyle(
          "NPS Categ.",
          fontWeight = "bold",
          color = styleEqual(c("Promotor", "Pasivo", "Detractor"), c("#059669", "#64748B", "#DC2626"))
        )
    })
    
  })
}
