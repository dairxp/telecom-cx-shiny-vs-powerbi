suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(bsicons)
  library(plotly)
  library(DT)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(ggplot2)
})

# 1. Carga Inteligente de Datos Curados
# Detecta si se ejecuta desde la raíz o dentro de shiny_app/
data_path <- if (file.exists("data/processed/dataset_curado.csv")) {
  "data/processed/dataset_curado.csv"
} else if (file.exists("../data/processed/dataset_curado.csv")) {
  "../data/processed/dataset_curado.csv"
} else {
  stop("No se encontró dataset_curado.csv. Asegúrate de ejecutar fase1_data_prep.py.")
}

df_curado <- read_csv(data_path, show_col_types = FALSE)

# Asegurar orden y tipos de factores
df_curado <- df_curado %>%
  mutate(
    operador_actual = factor(operador_actual, levels = c("Entel", "Claro", "Bitel", "Movistar")),
    area_academica = factor(area_academica, levels = c("Ingenierías", "Ciencias Sociales", "Biomédicas")),
    nps_category = factor(nps_category, levels = c("Promotor", "Pasivo", "Detractor")),
    riesgo_churn = factor(riesgo_churn, levels = c("Bajo", "Medio", "Alto")),
    antiguedad_uso = factor(antiguedad_uso, levels = c("Menos de 6 meses", "6 meses a 1 año", "1 a 2 años", "Más de 2 años"))
  )

# 2. Paletas de Colores Corporativas Oficiales
OPERATOR_COLORS <- c(
  "Entel"    = "#0047AB", # Azul Real Entel
  "Claro"    = "#DA291C", # Rojo Claro
  "Bitel"    = "#E6A100", # Amarillo Cálido Bitel
  "Movistar" = "#00A9E0"  # Celeste Movistar
)

CHURN_COLORS <- c(
  "Bajo"  = "#10B981", # Verde esmeralda
  "Medio" = "#F59E0B", # Ámbar
  "Alto"  = "#EF4444"  # Rojo coral
)

NPS_COLORS <- c(
  "Promotor"  = "#10B981",
  "Pasivo"    = "#64748B",
  "Detractor" = "#EF4444"
)

# 3. Funciones Analíticas Globales
calc_nps <- function(data) {
  if (nrow(data) == 0) return(list(nps = 0, prom = 0, pas = 0, det = 0, n = 0))
  n <- nrow(data)
  prom <- sum(data$nps_category == "Promotor", na.rm = TRUE)
  pas  <- sum(data$nps_category == "Pasivo", na.rm = TRUE)
  det  <- sum(data$nps_category == "Detractor", na.rm = TRUE)
  
  pct_prom <- (prom / n) * 100
  pct_det  <- (det / n) * 100
  nps_score <- round(pct_prom - pct_det, 1)
  
  list(
    nps = nps_score,
    pct_prom = round(pct_prom, 1),
    pct_pas = round((pas / n) * 100, 1),
    pct_det = round(pct_det, 1),
    prom = prom,
    pas = pas,
    det = det,
    n = n
  )
}

# 4. Tema Visual Moderno con bslib (Bootstrap 5)
app_theme <- bs_theme(
  version = 5,
  bootswatch = "zephyr",
  primary = "#1E3A8A", # Azul corporativo profundo
  secondary = "#475569",
  success = "#10B981",
  warning = "#F59E0B",
  danger = "#EF4444",
  base_font = font_google("Inter"),
  heading_font = font_google("Inter", wght = 700),
  font_scale = 0.95
)
