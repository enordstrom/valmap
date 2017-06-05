#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)


partier = c("MP","S","V","SD","M","C","FP","KD")
valen = c("Riksdag","Landsting","Kommun")
upplosningar = c("Kommun","Valdistrikt")

header = dashboardHeader(title="Valresultat 2014")

sidebar = dashboardSidebar(
  selectInput('val', 'val', valen),
  selectInput('upplosning', 'upplosning', upplosningar),
  selectInput('parti', 'parti', partier)
)

body <- dashboardBody(
  tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
  leafletOutput("map")
  
  
)

shinyUI(dashboardPage(header, sidebar, body, skin="black"))
