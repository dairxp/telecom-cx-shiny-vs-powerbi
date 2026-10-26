# ==============================================================================
# mod_kpis.R - Módulo 1: Resumen Ejecutivo y KPIs (Estilo AdminLTE Limpio)
# ==============================================================================

mod_kpis_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Fila de Tarjetas KPI: Color Completo Pastel, Sin Lineas Superiores
    layout_column_wrap(
      width = 1/4,
      fill = FALSE,
      div(
        class = "kpi-card kpi-card-blue",
        div(class = "kpi-title", "Muestra Filtrada"),
        div(class = "kpi-value", textOutput(ns("vb_sample"))),
        p(class = "kpi-subtext", textOutput(ns("vb_sample_sub")))
      ),
      div(
        class = "kpi-card kpi-card-cyan",
        div(class = "kpi-title", "CSAT Promedio"),
        div(class = "kpi-value", textOutput(ns("vb_csat"))),
        p(class = "kpi-subtext", textOutput(ns("vb_csat_sub")))
      ),
      div(
        class = "kpi-card kpi-card-green",
        div(class = "kpi-title", "Net Promoter Score (NPS)"),
        div(class = "kpi-value", textOutput(ns("vb_nps"))),
        p(class = "kpi-subtext", textOutput(ns("vb_nps_sub")))
      ),
      div(
        class = "kpi-card kpi-card-red",
        div(class = "kpi-title", "Riesgo de Churn Alto"),
        div(class = "kpi-value", textOutput(ns("vb_churn"))),
        p(class = "kpi-subtext", textOutput(ns("vb_churn_sub")))
      )
    ),
    
    br(),
    
    # Fila de Gráficos de Visión General
    layout_column_wrap(
      width = 1/2,
      fill = FALSE,
      card(
        card_header("Cuota de Mercado en Muestra (Market Share)"),
        card_body(
          plotlyOutput(ns("plot_market_share"), height = "340px")
        )
      ),
      card(
        card_header("Desglose NPS por Operador (% Promotores vs Detractores)"),
        card_body(
          plotlyOutput(ns("plot_nps_breakdown"), height = "340px")
        )
      )
    ),
    
    br(),
    
    # Fila Demográfica (Con leyendas arriba y sin choque con eje X)
    layout_column_wrap(
      width = 1/2,
      fill = FALSE,
      card(
        card_header("Distribución por Área Académica (UNA Puno)"),
        card_body(
          plotlyOutput(ns("plot_area_dist"), height = "340px")
        )
      ),
      card(
        card_header("Intención de Fuga (Churn) según Antigüedad de Uso"),
        card_body(
          plotlyOutput(ns("plot_churn_tenure"), height = "340px")
        )
      )
    )
  )
}

mod_kpis_server <- function(id, r_data) {
  moduleServer(id, function(input, output, session) {
    
    # --- Value Boxes ---
    output$vb_sample <- renderText({
      req(r_data())
      n <- nrow(r_data())
      paste0(n, " Estudiantes")
    })
    
    output$vb_sample_sub <- renderText({
      req(r_data())
      pct <- round((nrow(r_data()) / nrow(df_curado)) * 100, 1)
      paste0(pct, "% del total (N=109)")
    })
    
    output$vb_csat <- renderText({
      req(r_data())
      if (nrow(r_data()) == 0) return("0.0 / 5.0")
      score <- round(mean(r_data()$csat_promedio, na.rm = TRUE), 2)
      paste0(score, " / 5.0")
    })
    
    output$vb_csat_sub <- renderText({
      req(r_data())
      if (nrow(r_data()) == 0) return("Sin registros")
      score <- mean(r_data()$csat_promedio, na.rm = TRUE)
      if (score >= 3.7) "Nivel Favorable"
      else if (score >= 3.2) "Nivel Regular"
      else "Nivel Crítico"
    })
    
    output$vb_nps <- renderText({
      req(r_data())
      res <- calc_nps(r_data())
      sign <- if (res$nps > 0) "+" else ""
      paste0(sign, res$nps)
    })
    
    output$vb_nps_sub <- renderText({
      req(r_data())
      res <- calc_nps(r_data())
      paste0("Promotores: ", res$pct_prom, "% | Detractores: ", res$pct_det, "%")
    })
    
    output$vb_churn <- renderText({
      req(r_data())
      if (nrow(r_data()) == 0) return("0.0%")
      n_alto <- sum(r_data()$riesgo_churn == "Alto", na.rm = TRUE)
      pct <- round((n_alto / nrow(r_data())) * 100, 1)
      paste0(pct, "%")
    })
    
    output$vb_churn_sub <- renderText({
      req(r_data())
      if (nrow(r_data()) == 0) return("0 casos")
      n_alto <- sum(r_data()$riesgo_churn == "Alto", na.rm = TRUE)
      paste0(n_alto, " estudiantes en riesgo de abandono")
    })
    
    # --- Gráfico 1: Market Share (Donut Chart) ---
    output$plot_market_share <- renderPlotly({
      req(r_data())
      df <- r_data() %>%
        count(operador_actual) %>%
        rename(Operador = operador_actual, Cantidad = n)
      
      if (nrow(df) == 0) return(NULL)
      
      colors_vec <- OPERATOR_COLORS[as.character(df$Operador)]
      
      plot_ly(
        df,
        labels = ~Operador,
        values = ~Cantidad,
        type = "pie",
        hole = 0.55,
        marker = list(colors = colors_vec, line = list(color = "#FFFFFF", width = 2)),
        textinfo = "label+percent",
        hoverinfo = "label+value+percent"
      ) %>%
        layout(
          showlegend = TRUE,
          legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 1.12),
          margin = list(t = 30, b = 20, l = 20, r = 20)
        ) %>%
        config(displayModeBar = FALSE)
    })
    
    # --- Gráfico 2: Desglose NPS por Operador ---
    output$plot_nps_breakdown <- renderPlotly({
      req(r_data())
      df <- r_data() %>%
        group_by(operador_actual, nps_category) %>%
        summarise(n = n(), .groups = "drop_last") %>%
        mutate(pct = round((n / sum(n)) * 100, 1))
      
      if (nrow(df) == 0) return(NULL)
      
      plot_ly(
        df,
        x = ~operador_actual,
        y = ~pct,
        color = ~nps_category,
        colors = NPS_COLORS,
        type = "bar",
        text = ~paste0(pct, "%"),
        textposition = "inside",
        hoverinfo = "x+name+text"
      ) %>%
        layout(
          barmode = "stack",
          xaxis = list(title = "", tickangle = 0),
          yaxis = list(title = "Porcentaje (%)", range = c(0, 100)),
          legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 1.14),
          margin = list(t = 40, b = 30, l = 45, r = 20)
        ) %>%
        config(displayModeBar = FALSE)
    })
    
    # --- Gráfico 3: Distribución por Área Académica (Sin choque de leyenda) ---
    output$plot_area_dist <- renderPlotly({
      req(r_data())
      df <- r_data() %>%
        count(area_academica, operador_actual)
      
      if (nrow(df) == 0) return(NULL)
      
      plot_ly(
        df,
        x = ~area_academica,
        y = ~n,
        color = ~operador_actual,
        colors = OPERATOR_COLORS,
        type = "bar"
      ) %>%
        layout(
          barmode = "group",
          xaxis = list(title = "", tickangle = 0),
          yaxis = list(title = "N° Estudiantes"),
          legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 1.15),
          margin = list(t = 45, b = 30, l = 45, r = 20)
        ) %>%
        config(displayModeBar = FALSE)
    })
    
    # --- Gráfico 4: Churn según Antigüedad (Sin choque de leyenda) ---
    output$plot_churn_tenure <- renderPlotly({
      req(r_data())
      df <- r_data() %>%
        count(antiguedad_uso, riesgo_churn) %>%
        group_by(antiguedad_uso) %>%
        mutate(pct = round((n / sum(n)) * 100, 1))
      
      if (nrow(df) == 0) return(NULL)
      
      plot_ly(
        df,
        x = ~antiguedad_uso,
        y = ~pct,
        color = ~riesgo_churn,
        colors = CHURN_COLORS,
        type = "bar",
        text = ~paste0(pct, "%"),
        textposition = "inside"
      ) %>%
        layout(
          barmode = "stack",
          xaxis = list(title = "", tickangle = 0),
          yaxis = list(title = "Porcentaje (%)", range = c(0, 100)),
          legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 1.15),
          margin = list(t = 45, b = 30, l = 45, r = 20)
        ) %>%
        config(displayModeBar = FALSE)
    })
    
  })
}
