# mod_satisfaction.R - Módulo 2: Diagnóstico Multidimensional CSAT (Satisfacción)

mod_satisfaction_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Fila Superior: Radar Chart & Ranking
    layout_column_wrap(
      width = 1/2,
      fill = FALSE,
      card(
        card_header("Benchmark Competitivo: Gráfico de Radar (5 Dimensiones)"),
        card_body(
          plotlyOutput(ns("plot_radar"), height = "420px")
        )
      ),
      card(
        card_header("Tabla Resumen de Promedios por Dimensión (Escala 1 al 5)"),
        card_body(
          DTOutput(ns("table_csat_summary")),
          br(),
          div(
            class = "alert alert-light border small text-muted",
            strong("Dimensiones evaluadas:"), " Cobertura, Velocidad, Atención, Precio y Datos.",
            " Puntuación máxima: 5.0 (Muy Satisfecho)."
          )
        )
      )
    ),
    
    br(),
    
    # Fila Inferior: Boxplots de Dispersión y Asimetría
    card(
      card_header(
        class = "d-flex justify-content-between align-items-center",
        div(
          span("Distribución y Dispersión de la Satisfacción (Boxplots Interactivos)"),
          span(" - Análisis de variabilidad y valores atípicos", class = "text-muted small")
        ),
        div(
          selectInput(
            ns("select_box_dim"),
            label = NULL,
            choices = c(
              "CSAT General Ponderado" = "csat_promedio",
              "Cobertura de Señal" = "sat_cobertura",
              "Velocidad de Internet" = "sat_velocidad",
              "Atención al Cliente" = "sat_atencion",
              "Precio del Servicio" = "sat_precio",
              "Cantidad de Datos (GB)" = "sat_datos"
            ),
            selected = "csat_promedio",
            width = "260px"
          )
        )
      ),
      card_body(
        plotlyOutput(ns("plot_boxplots"), height = "360px")
      )
    )
  )
}

mod_satisfaction_server <- function(id, r_data) {
  moduleServer(id, function(input, output, session) {
    
    # --- Gráfico de Radar en Plotly (Scatterpolar) ---
    output$plot_radar <- renderPlotly({
      req(r_data())
      
      dims <- c("sat_cobertura", "sat_velocidad", "sat_atencion", "sat_precio", "sat_datos")
      dim_labels <- c("Cobertura", "Velocidad", "Atención", "Precio", "Datos")
      
      # Calcular promedios por operador
      df_radar <- r_data() %>%
        group_by(operador_actual) %>%
        summarise(
          Cobertura = round(mean(sat_cobertura, na.rm = TRUE), 2),
          Velocidad = round(mean(sat_velocidad, na.rm = TRUE), 2),
          Atención  = round(mean(sat_atencion, na.rm = TRUE), 2),
          Precio    = round(mean(sat_precio, na.rm = TRUE), 2),
          Datos     = round(mean(sat_datos, na.rm = TRUE), 2),
          .groups   = "drop"
        )
      
      if (nrow(df_radar) == 0) return(NULL)
      
      p <- plot_ly(type = "scatterpolar", mode = "lines+markers")
      
      for (i in 1:nrow(df_radar)) {
        op <- as.character(df_radar$operador_actual[i])
        vals <- c(
          df_radar$Cobertura[i],
          df_radar$Velocidad[i],
          df_radar$Atención[i],
          df_radar$Precio[i],
          df_radar$Datos[i],
          df_radar$Cobertura[i] # Cerrar el polígono
        )
        theta_labels <- c(dim_labels, dim_labels[1])
        col_op <- unname(OPERATOR_COLORS[op])
        if (is.na(col_op)) col_op <- "#333333"
        
        p <- p %>% add_trace(
          r = vals,
          theta = theta_labels,
          name = op,
          fill = "toself",
          fillcolor = paste0(col_op, "22"), # color con transparencia
          line = list(color = col_op, width = 2.5),
          marker = list(color = col_op, size = 6)
        )
      }
      
      p %>% layout(
        polar = list(
          radialaxis = list(
            visible = TRUE,
            range = c(1, 5),
            tickfont = list(size = 10)
          )
        ),
        legend = list(orientation = "h", x = 0.1, y = -0.15),
        margin = list(t = 25, b = 40, l = 35, r = 35)
      ) %>%
        config(displayModeBar = FALSE)
    })
    
    # --- Tabla Resumen DT ---
    output$table_csat_summary <- renderDT({
      req(r_data())
      
      df_summary <- r_data() %>%
        group_by(Operador = operador_actual) %>%
        summarise(
          `N° Muestra` = n(),
          `Cobertura`  = round(mean(sat_cobertura, na.rm = TRUE), 2),
          `Velocidad`  = round(mean(sat_velocidad, na.rm = TRUE), 2),
          `Atención`   = round(mean(sat_atencion, na.rm = TRUE), 2),
          `Precio`     = round(mean(sat_precio, na.rm = TRUE), 2),
          `Datos`      = round(mean(sat_datos, na.rm = TRUE), 2),
          `CSAT Global` = round(mean(csat_promedio, na.rm = TRUE), 2),
          .groups      = "drop"
        ) %>%
        arrange(desc(`CSAT Global`))
      
      datatable(
        df_summary,
        rownames = FALSE,
        options = list(
          dom = "t",
          pageLength = 10,
          ordering = FALSE
        ),
        class = "stripe hover compact table-bordered"
      ) %>%
        formatStyle(
          "CSAT Global",
          fontWeight = "bold",
          backgroundColor = styleInterval(c(3.2, 3.7), c("#FEE2E2", "#FEF3C7", "#D1FAE5")),
          color = styleInterval(c(3.2, 3.7), c("#991B1B", "#92400E", "#065F46"))
        )
    })
    
    # --- Boxplots de Satisfacción ---
    output$plot_boxplots <- renderPlotly({
      req(r_data(), input$select_box_dim)
      
      var_name <- input$select_box_dim
      df <- r_data()
      
      # Mapeo de nombres limpios para eje Y
      labels_dict <- c(
        "csat_promedio" = "CSAT Promedio Ponderado",
        "sat_cobertura" = "Satisfacción Cobertura",
        "sat_velocidad" = "Satisfacción Velocidad",
        "sat_atencion"  = "Satisfacción Atención",
        "sat_precio"    = "Satisfacción Precio",
        "sat_datos"     = "Satisfacción Datos"
      )
      
      y_title <- labels_dict[[var_name]]
      
      plot_ly(
        df,
        x = ~operador_actual,
        y = as.formula(paste0("~", var_name)),
        color = ~operador_actual,
        colors = OPERATOR_COLORS,
        type = "box",
        boxpoints = "outliers"
      ) %>%
        layout(
          xaxis = list(title = ""),
          yaxis = list(title = y_title, range = c(0.8, 5.2)),
          showlegend = FALSE,
          margin = list(t = 20, b = 30, l = 45, r = 20)
        ) %>%
        config(displayModeBar = FALSE)
    })
    
  })
}
