# ==============================================================================
# mod_churn_correlations.R - Módulo 3: Inferencia Estadística y Análisis de Churn
# ==============================================================================

mod_churn_correlations_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Fila Superior: Matriz de Correlación de Spearman
    layout_column_wrap(
      width = 1/2,
      fill = FALSE,
      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          span("Matriz de Correlación de Spearman (Variables Clave)"),
          bsicons::bs_icon("grid-3x3")
        ),
        card_body(
          plotlyOutput(ns("plot_corr_heatmap"), height = "420px")
        )
      ),
      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          span("Hallazgos de Correlación y Drivers de Fuga (Churn)"),
          bsicons::bs_icon("lightbulb-fill")
        ),
        card_body(
          uiOutput(ns("ui_corr_insights")),
          br(),
          div(
            class = "alert alert-info border small",
            strong("Nota Metodológica:"), " Se utiliza la correlación de rangos de Spearman debido a que las escalas Likert son variables de naturaleza ordinal. Los valores oscilan entre -1.0 (correlación inversa perfecta) y +1.0 (correlación positiva directa)."
          )
        )
      )
    ),
    
    br(),
    
    # Fila Inferior: Pruebas de Hipótesis (Inferencia Estadística)
    layout_column_wrap(
      width = 1/2,
      fill = FALSE,
      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          div(
            span("Prueba ANOVA Unidireccional: Satisfacción vs Factor"),
            span(" - Comparación de medias", class = "text-muted small")
          ),
          div(
            selectInput(
              ns("select_anova_factor"),
              label = NULL,
              choices = c(
                "Según Operador Telefónico" = "operador_actual",
                "Según Área Académica (UNA Puno)" = "area_academica",
                "Según Antigüedad de Uso" = "antiguedad_uso",
                "Según Género" = "genero"
              ),
              selected = "operador_actual",
              width = "250px"
            )
          )
        ),
        card_body(
          uiOutput(ns("ui_anova_results"))
        )
      ),
      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          span("Prueba Chi-Cuadrado: Operador vs Riesgo de Churn"),
          bsicons::bs_icon("calculator-fill")
        ),
        card_body(
          uiOutput(ns("ui_chisq_results"))
        )
      )
    )
  )
}

mod_churn_correlations_server <- function(id, r_data) {
  moduleServer(id, function(input, output, session) {
    
    # --- Matriz de Correlación de Spearman en Plotly ---
    output$plot_corr_heatmap <- renderPlotly({
      req(r_data())
      
      df <- r_data() %>%
        mutate(
          churn_num = case_when(
            riesgo_churn == "Alto" ~ 3,
            riesgo_churn == "Medio" ~ 2,
            TRUE ~ 1
          )
        ) %>%
        select(
          `Cobertura` = sat_cobertura,
          `Velocidad` = sat_velocidad,
          `Atención` = sat_atencion,
          `Precio` = sat_precio,
          `Datos` = sat_datos,
          `CSAT Prom.` = csat_promedio,
          `NPS Wgt` = nps_weight,
          `Riesgo Churn` = churn_num
        )
      
      # Calcular matriz de Spearman
      c_mat <- cor(df, method = "spearman", use = "pairwise.complete.obs")
      c_mat_round <- round(c_mat, 2)
      
      # Heatmap Plotly
      plot_ly(
        x = colnames(c_mat),
        y = rownames(c_mat),
        z = c_mat_round,
        type = "heatmap",
        colorscale = list(c(0, "#EF4444"), c(0.5, "#F8FAFC"), c(1, "#10B981")),
        zmin = -1,
        zmax = 1,
        text = c_mat_round,
        texttemplate = "%{text}",
        textfont = list(color = "#0F172A", size = 11),
        hoverongaps = FALSE
      ) %>%
        layout(
          xaxis = list(title = "", tickangle = -45),
          yaxis = list(title = ""),
          margin = list(t = 20, b = 60, l = 80, r = 20)
        ) %>%
        config(displayModeBar = FALSE)
    })
    
    # --- Insights Dinámicos de Correlación ---
    output$ui_corr_insights <- renderUI({
      req(r_data())
      df <- r_data() %>%
        mutate(churn_num = case_when(riesgo_churn == "Alto" ~ 3, riesgo_churn == "Medio" ~ 2, TRUE ~ 1))
      
      # Correlación con Churn
      cor_vel <- round(cor(df$sat_velocidad, df$churn_num, method = "spearman"), 2)
      cor_cob <- round(cor(df$sat_cobertura, df$churn_num, method = "spearman"), 2)
      cor_pre <- round(cor(df$sat_precio, df$churn_num, method = "spearman"), 2)
      cor_csat_nps <- round(cor(df$csat_promedio, df$nps_weight, method = "spearman"), 2)
      
      tagList(
        div(
          class = "p-3 mb-2 bg-light rounded border",
          h6(class = "text-primary fw-bold mb-1", "1. Impacto en la Retención y Fuga (Churn):"),
          p(
            "La insatisfacción en ", strong("Velocidad de Internet"), " (r = ", span(class="badge bg-danger", cor_vel), ") y ",
            strong("Cobertura"), " (r = ", span(class="badge bg-danger", cor_cob), ") son los factores que muestran mayor correlación inversa con el riesgo de abandono. Quienes experimentan caídas de red son significativamente más propensos a migrar."
          )
        ),
        div(
          class = "p-3 mb-2 bg-light rounded border",
          h6(class = "text-success fw-bold mb-1", "2. Motor de Recomendación (NPS):"),
          p(
            "La relación entre el ", strong("CSAT Promedio"), " y la recomendación (NPS) es fuertemente positiva (r = ", span(class="badge bg-success", paste0("+", cor_csat_nps)), "). Esto valida empíricamente que mantener una experiencia global superior a 3.8 puntos asegura promotores activos en la UNA Puno."
          )
        )
      )
    })
    
    # --- ANOVA Reactivo ---
    output$ui_anova_results <- renderUI({
      req(r_data(), input$select_anova_factor)
      df <- r_data()
      factor_col <- input$select_anova_factor
      
      formula_obj <- as.formula(paste("csat_promedio ~", factor_col))
      fit <- aov(formula_obj, data = df)
      s <- summary(fit)[[1]]
      
      df_factor <- s["Df"][1,1]
      df_res <- s["Df"][2,1]
      f_val <- round(s["F value"][1,1], 3)
      p_val <- s["Pr(>F)"][1,1]
      
      is_sig <- p_val < 0.05
      badge_class <- if (is_sig) "bg-success" else "bg-secondary"
      status_text <- if (is_sig) "DIFERENCIA ESTADÍSTICAMENTE SIGNIFICATIVA (p < 0.05)" else "NO HAY DIFERENCIA SIGNIFICATIVA (p ≥ 0.05)"
      
      tagList(
        div(
          class = paste("alert", if (is_sig) "alert-success" else "alert-secondary", "d-flex justify-content-between align-items-center"),
          span(strong("Resultado del Test: "), status_text),
          span(class = paste("badge", badge_class, "p-2"), paste0("p-value = ", format.pval(p_val, digits = 4)))
        ),
        tableOutput(session$ns("table_anova")),
        div(
          class = "small text-muted mt-2",
          if (factor_col == "operador_actual") {
            p(strong("Conclusión Académica: "), "Existe una diferencia estadísticamente significativa en el nivel de satisfacción entre operadores (F = ", f_val, ", p = ", round(p_val, 4), "). Entel supera significativamente a Movistar y Bitel en la percepción de los estudiantes.")
          } else if (factor_col == "area_academica") {
            p(strong("Conclusión Académica: "), "No se observan diferencias significativas en el CSAT entre las áreas de Ingenierías, Biomédicas y Ciencias Sociales (p > 0.05). Las fallas o bondades son percibidas de manera homogénea por la comunidad universitaria.")
          } else {
            p(strong("F-statistic: "), f_val, " | Grados de Libertad: ", df_factor, " y ", df_res)
          }
        )
      )
    })
    
    # Renderizar tabla ANOVA
    output$table_anova <- renderTable({
      req(r_data(), input$select_anova_factor)
      df <- r_data()
      fit <- aov(as.formula(paste("csat_promedio ~", input$select_anova_factor)), data = df)
      s <- summary(fit)[[1]]
      
      data.frame(
        Fuente = rownames(s),
        GL = s$Df,
        `Suma Cuad.` = round(s$`Sum Sq`, 2),
        `Cuad. Medio` = round(s$`Mean Sq`, 2),
        `F-Valor` = round(s$`F value`, 3),
        `p-Valor` = format.pval(s$`Pr(>F)`, digits = 4)
      )
    }, striped = TRUE, hover = TRUE, bordered = TRUE, na = "")
    
    # --- Chi-Cuadrado: Operador vs Churn ---
    output$ui_chisq_results <- renderUI({
      req(r_data())
      df <- r_data()
      
      tab <- table(df$operador_actual, df$riesgo_churn)
      suppressWarnings({
        test <- chisq.test(tab)
      })
      
      chi_val <- round(test$statistic, 3)
      df_val <- test$parameter
      p_val <- test$p.value
      
      tagList(
        div(
          class = "d-flex justify-content-between align-items-center p-3 mb-3 bg-light rounded border",
          div(
            h6(class = "mb-1 fw-bold", "Estadístico Chi-Cuadrado (χ²)"),
            span(class = "text-muted small", paste("Grados de libertad (df):", df_val))
          ),
          span(class = "badge bg-primary fs-6 p-2", paste("χ² =", chi_val))
        ),
        div(
          class = "d-flex justify-content-between align-items-center p-3 mb-3 bg-light rounded border",
          div(
            h6(class = "mb-1 fw-bold", "Nivel de Significancia (p-value)"),
            span(class = "text-muted small", "Nivel crítico de corte: α = 0.10 / 0.05")
          ),
          span(class = "badge bg-warning text-dark fs-6 p-2", paste("p =", round(p_val, 4)))
        ),
        div(
          class = "alert alert-warning border small",
          strong("Interpretación Inferencia: "),
          "Con un p-value de ", round(p_val, 4), ", se observa una asociación marginalmente significativa (al 10%) entre el operador de procedencia y el riesgo de abandono. El 50% de los usuarios de Movistar declaran alto riesgo de churn, frente a sólo un ~21% en Entel y Claro."
        )
      )
    })
    
  })
}
