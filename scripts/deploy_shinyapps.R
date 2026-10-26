# ==============================================================================
# Script de Despliegue a shinyapps.io
# ==============================================================================
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

# PASO 2: Publicar la aplicación
# Sube únicamente la carpeta shiny_app/ (que ya contiene datos, imágenes y módulos)
deployApp(
  appDir = "shiny_app",
  appName = "telecom-cx-una-puno",
  appTitle = "Telecom CX Analytics - UNA Puno",
  forceUpdate = TRUE
)
