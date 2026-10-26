# Instrucciones:
# 1. Copia tu token desde: https://www.shinyapps.io/admin/#/tokens
# 2. Descomenta y ejecuta la línea rsconnect::setAccountInfo(...) con tus credenciales.
# 3. Ejecuta la función deployApp().

library(rsconnect)

# PASO 1: Autorizar tu cuenta (Pega aquí la línea que copiaste de shinyapps.io)
# rsconnect::setAccountInfo(
#   name   = "<TU_CUENTA>",
#   token  = "<TU_TOKEN>",
#   secret = "<TU_SECRET>"
# )

# PASO 2: Resolver la ruta de la carpeta shiny_app (según dónde esté tu consola en Positron)
app_dir <- if (dir.exists("shiny_app")) {
  "shiny_app"
} else if (dir.exists("../shiny_app")) {
  "../shiny_app"
} else if (file.exists("app.R")) {
  "."
} else {
  "f:/dxp-projects/DevBasics/R y statistics/telecom-cx-shiny-vs-powerbi/shiny_app"
}

message("Publicando desde directorio: ", normalizePath(app_dir))

# PASO 3: Publicar la aplicación
deployApp(
  appDir = app_dir,
  appName = "telecom-cx-una-puno",
  appTitle = "Telecom CX Analytics - UNA Puno",
  forceUpdate = TRUE
)
