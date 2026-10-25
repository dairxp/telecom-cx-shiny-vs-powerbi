# Script para ejecutar la aplicacion Shiny localmente
library(shiny)
options(shiny.port = 8888, shiny.host = "127.0.0.1")
runApp("shiny_app")
