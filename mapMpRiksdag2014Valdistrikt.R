library(downloader)
library(rgdal)
library(rgeos)
library(sp)

#Spatial data
url = "http://www.val.se/val/val2014/statistik/gis/valgeografi_valdistrikt.zip"
download(url, dest="valgeografi_valdistrikt.zip", mode="wb") 
unzip ("valgeografi_valdistrikt.zip", exdir = "./valgeografi_valdistrikt")
myshp <- readOGR("valgeografi_valdistrikt","valgeografi_valdistrikt")
#some cleaning
myshp$VD_NAMN <- as.character(myshp$VD_NAMN)
myshp$VD_NAMN <- gsub("Ã¶","ö",myshp$VD_NAMN)
myshp$VD_NAMN <- gsub("Ã¤","ä",myshp$VD_NAMN)
myshp$VD_NAMN <- gsub("Ã¥","å",myshp$VD_NAMN)
myshp$VD_NAMN <- gsub("Ã–","Ö",myshp$VD_NAMN)
myshp$VD_NAMN <- gsub("Ã„","Ä",myshp$VD_NAMN)
myshp$VD_NAMN <- gsub("Ã…","Å",myshp$VD_NAMN)
myshp$VD_NAMN <- gsub("Ã¼","ü",myshp$VD_NAMN)
myshp$VD_NAMN <- gsub("Ã©","é",myshp$VD_NAMN)
myshp$VD = as.numeric(as.character(myshp$VD))

#Reducing resolution
#myshpRed = gSimplify(myshp,tol=200)
#Restoring SpatialPolygonsDataFrame
#pid <- sapply(slot(myshpRed, "polygons"), function(x) slot(x, "ID")) 
#myshpRed.df <- data.frame( myshp, row.names = pid)
#myshpRed = SpatialPolygonsDataFrame(myshpRed, myshpRed.df)
myshpRed = myshp

#Election data
url = "http://www.val.se/val/val2014/statistik/2014_riksdagsval_per_valdistrikt.skv"
download(url, dest="2014_riksdagsval_per_valdistrikt.skv", mode="wb") 
val_data <- read.csv("2014_riksdagsval_per_valdistrikt.skv", sep=';')
#Cleaning
val_data$MP.proc = gsub(",",".",val_data$MP.proc)
val_data$MP.proc = as.numeric(as.character(val_data$MP.proc))
val_data$Valdistrikt <- as.character(val_data$Valdistrikt)
val_data = val_data[!val_data$Valdistrikt=="Uppsamlingsdistrikt", ]
val_data$VD <- val_data$LAN*1e6 + val_data$KOM*1e4 + val_data$VALDIST 

#Joining spatial and election data
merged_data <- sp::merge(x = myshpRed, y = val_data, all.x = FALSE, all.y = FALSE, by.x = 'VD', by.y = 'VD', duplicateGeoms = FALSE)




library(mapview)
#mapview(merged_data, zcol = "MP.proc", legend = TRUE, label=merged_data$Valdistrikt, map.types="Esri.WorldStreetMap")
m = mapview(merged_data, zcol = "MP.proc", 
            legend = TRUE, label=merged_data$Valdistrikt, 
            map.types="OpenStreetMap.BlackAndWhite")

mapshot(m, url = paste0(getwd(), "/shapes.html"), selfcontained = FALSE)

#Maybe raster is less heavy
library(raster)
library(rasterVis)
library(gdalUtils)
#Sweden raster
r <- raster(ncol=1e3, nrow=3*1e3)
extent(r) <- extent(merged_data)
rp <- rasterize(merged_data, r, 'MP.proc')
mraster = mapview(rp, legend = TRUE, map.types="OpenStreetMap.BlackAndWhite", maxpixels=3*1e6)
mapshot(mraster, url = paste0(getwd(), "/mapMpRiksdag2014Valdistrikt_rasterSverige.html"), selfcontained = FALSE)
#Stockolms kommun
merged_data_stockholm = merged_data[merged_data$LAN == 1 & merged_data$KOM == 80, ]
r <- raster(ncol=2e3, nrow=2e3)
extent(r) <- extent(merged_data_stockholm)
rp_stockholm <- rasterize(merged_data_stockholm, r, 'MP.proc')
mraster_stockholm = mapview(rp_stockholm, legend = TRUE, map.types="OpenStreetMap.BlackAndWhite", maxpixels=4*1e6)
mapshot(mraster_stockholm, url = paste0(getwd(), "/mapMpRiksdag2014Valdistrikt_rasterStockholm.html"), selfcontained = FALSE)

#?gdalUtils::gdal_rasterize

#dst_filename_original  <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
# Back up the file, since we are going to burn stuff into it.
#dst_filename <- paste(tempfile(),".tiff",sep="")
#file.copy(dst_filename_original,dst_filename,overwrite=TRUE)

#src_dataset <- system.file("D:/test\test.shp", package="gdalUtils")
#tahoe_burned <- gdal_rasterize("D:/test/test.shp",dst_filename,
#                               b=c(1,2,3),burn=c(0,255,0),l="tahoe_highrez_training",verbose=TRUE,output_Raster=TRUE)










