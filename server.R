#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(sp)
library(leaflet)
library(rgdal)
library(htmlTable)

partier = c("MP","S","V","SD","M","C","FP","KD")
valen = c("Riksdag","Landsting","Kommun")
upplosningar = c("Kommun","Valdistrikt")


shinyServer(function(input, output) {
   
  
  #
  geofilename = reactive({
    if(input$upplosning == "Kommun") {
      "Data/geodataKommun.rds"
    } else if(input$upplosning == "Valdistrikt") {
      "Data/geodataValdistrikt.rds"
    }
  })
  
  geodata = reactive({
    readRDS(geofilename())
  })
  
  electionfilename = reactive({
    if(input$upplosning == "Kommun") {
      
      if(input$val == "Riksdag") "Data/riksdagsvalperkommun.rds"
      else if(input$val == "Landsting") "Data/landstingsvalperkommun.rds"
      else if(input$val == "Kommun") "Data/kommunvalperkommun.rds"
      
    } else if(input$upplosning == "Valdistrikt") {
      
      if(input$val == "Riksdag") "Data/riksdagsvalpervaldistrikt.rds"
      else if(input$val == "Landsting") "Data/landstingsvalpervaldistrikt.rds"
      else if(input$val == "Kommun") "Data/kommunvalpervaldistrikt.rds"
      
    }
  })
  
  electiondata = reactive({
    df = readRDS(electionfilename())
  })
  
  
  polydata = reactive({
    sp::merge(x = geodata(), y = electiondata(), 
                             all.x = FALSE, all.y = FALSE, 
                             by.x = 'KEY', by.y = 'KEY', 
                             duplicateGeoms = FALSE)
  })
  
  mapToDraw = reactive({
    str = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0";
    pd = spTransform(polydata(),CRS(str))
    d = as.data.frame(pd)
    values = d[[input$parti]];
    
    pal <- colorNumeric(
      palette = "magma",
      #domain = c(0,max(d[,pind])))
    domain = values)
    
    tempnamn = as.character(d$NAMN)
    Encoding(tempnamn) = "latin1"
    
    
    labels <- sprintf(
      "<head><meta charset='UTF-8'></head>
      <strong>%s</strong><br/>%g &#37",
      tempnamn, values
    ) %>% lapply(htmltools::HTML)
    
    leaflet() %>% 
      addTiles() %>% 
      addPolygons(data = pd, 
                  weight=1, 
                  color = ~pal(values),
                  fillOpacity = 0.5,
                  highlight = highlightOptions(
                    weight = 3,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.8,
                    bringToFront = TRUE),
                  label = labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto"),
                  smoothFactor = 1
      ) %>% 
      addLegend("bottomright", 
                pal = pal, 
                values = values,
                title = "Valresultat",
                labFormat = labelFormat(suffix = " %"),
                opacity = 1)
      
      
  })
  
  output$map <- renderLeaflet({
    mTmp=mapToDraw()
  })
  
  
  observeEvent(input$map_shape_click, {
    #Not working
    #return()   
    click <- input$map_shape_click
    
    if(is.null(click))
      return()   
    
    str = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0";
    pd = spTransform(polydata(),CRS(str))
    
    #pulls lat and lon from shiyn click event
    lat <- click$lat
    lon <- click$lng
    
    #puts lat and lon for click point into its own data frame
    coords <- as.data.frame(cbind(lon, lat))
    
    #converts click point coordinate data frame into SP object, sets CRS
    point <- SpatialPoints(coords)
    proj4string(point) <- CRS(str)
    
    #retrieves country in which the click point resides, set CRS for country
    selected <- pd[point,]
    dselected = as.data.frame(selected)
    proj4string(selected) <- CRS(str)
    
    parti = gsub(".proc","",partier)
    resultat = as.vector(dselected[c(3:length(dselected))],mode='numeric')
    df = data.frame(resultat
                    )
    names(df) = as.character(dselected$NAMN)
    rownames(df) = parti
    
    content = htmlTable(df)
    content = HTML(content)
    
    proxy <- leafletProxy("map")
    proxy %>% addPopups(lat=lat, lng=lon, popup = content,
              options = popupOptions(closeButton = TRUE)
    )
  })
  
  
})
