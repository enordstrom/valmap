#Download, unzip, generate data frame, simplify polygons, clean, save to disk

library(downloader)
library(rgdal)
library(sp)
library(rmapshaper)

dir.create("tmp")
dir.create("Data")
dir.create("Data/Leaflet")

#Geodata
#-Kommun
url = "http://www.val.se/val/val2014/statistik/gis/valgeografi_kommun.zip"
download(url, dest="tmp/valgeografi_kommun.zip", mode="wb")
unzip ("tmp/valgeografi_kommun.zip", exdir = "./tmp/valgeografi_kommun")
kommunShp <- readOGR("tmp/valgeografi_kommun","valgeografi_kommun")
kommunShp <- ms_simplify(kommunShp,keep_shapes=TRUE,keep=0.05)
kommunShp$KEY = as.numeric(as.character(kommunShp$KOM))
keep = c("KEY")
kommunShp = kommunShp[keep]
saveRDS(kommunShp,"Data/geodataKommun.rds")

#-Valdistrikt
url = "http://www.val.se/val/val2014/statistik/gis/valgeografi_valdistrikt.zip"
download(url, dest="tmp/valgeografi_valdistrikt.zip", mode="wb")
unzip ("tmp/valgeografi_valdistrikt.zip", exdir = "./tmp/valgeografi_valdistrikt")
valdistShp <- readOGR("tmp/valgeografi_valdistrikt","valgeografi_valdistrikt")
valdistShp <- ms_simplify(valdistShp,keep_shapes=TRUE,keep=0.015)
valdistShp$KEY = as.numeric(as.character(valdistShp$VD))
keep = c("KEY")
valdistShp = valdistShp[keep]
saveRDS(valdistShp,"Data/geodataValdistrikt.rds")

#Election results
partier = c("MP.proc","S.proc","V.proc","SD.proc","M.proc","C.proc","FP.proc","KD.proc")
#-Kommunval
#--Kommun
url = "http://www.val.se/val/val2014/statistik/2014_kommunval_per_kommun.skv"
download(url, dest="tmp/2014_kommunval_per_kommun.skv", mode="wb") 
kkRes <- read.csv("tmp/2014_kommunval_per_kommun.skv", sep=';')
kkRes$KEY = kkRes$LÄN*1e2 + kkRes$KOM
kkRes$NAMN = kkRes$KOMMUN;
kkRes = kkRes[union(c("KEY","NAMN"),partier)]
kkRes[partier] = as.data.frame(lapply(kkRes[partier], function(y) gsub(",", ".", y)))
kkRes[partier] <- sapply( kkRes[partier], as.character )
kkRes[partier] <- sapply( kkRes[partier], as.numeric )
names(kkRes) = gsub(".proc","",names(kkRes))
saveRDS(kkRes,"Data/kommunvalperkommun.rds")
rm(kkRes)

#--Valdistrikt
url = "http://www.val.se/val/val2014/statistik/2014_kommunval_per_valdistrikt.skv"
download(url, dest="tmp/2014_kommunval_per_valdistrikt.skv", mode="wb") 
kvRes <- read.csv("tmp/2014_kommunval_per_valdistrikt.skv", sep=';')
kvRes$VALDISTRIKT.1 <- as.character(kvRes$VALDISTRIKT.1)
kvRes = kvRes[!kvRes$VALDISTRIKT.1=="Uppsamlingsdistrikt", ]
kvRes$KEY <- kvRes$LÄN*1e6 + kvRes$KOM*1e4 + kvRes$VALDISTRIKT 
kvRes$NAMN = kvRes$VALDISTRIKT.1
kvRes = kvRes[union(c("KEY","NAMN"),partier)]
kvRes[partier] = as.data.frame(lapply(kvRes[partier], function(y) gsub(",", ".", y)))
kvRes[partier] <- sapply( kvRes[partier], as.character )
kvRes[partier] <- sapply( kvRes[partier], as.numeric )
names(kvRes) = gsub(".proc","",names(kvRes))
saveRDS(kvRes,"Data/kommunvalpervaldistrikt.rds")
rm(kvRes)

#-Landstingsval
#--Kommun
url = "http://www.val.se/val/val2014/statistik/2014_landstingsval_per_kommun.skv"
download(url, dest="tmp/2014_landstingsval_per_kommun.skv", mode="wb") 
lkRes <- read.csv("tmp/2014_landstingsval_per_kommun.skv", sep=';')
lkRes$KEY = lkRes$LÄN*1e2 + lkRes$KOM
lkRes$NAMN = lkRes$KOMMUN
lkRes = lkRes[union(c("KEY","NAMN"),partier)]
lkRes[partier] = as.data.frame(lapply(lkRes[partier], function(y) gsub(",", ".", y)))
lkRes[partier] <- sapply( lkRes[partier], as.character )
lkRes[partier] <- sapply( lkRes[partier], as.numeric )
names(lkRes) = gsub(".proc","",names(lkRes))
saveRDS(lkRes,"Data/landstingsvalperkommun.rds")
rm(lkRes)

#--Valdistrikt
url = "http://www.val.se/val/val2014/statistik/2014_kommunval_per_valdistrikt.skv"
download(url, dest="tmp/2014_kommunval_per_valdistrikt.skv", mode="wb") 
lvRes <- read.csv("tmp/2014_kommunval_per_valdistrikt.skv", sep=';')
lvRes$VALDISTRIKT.1 <- as.character(lvRes$VALDISTRIKT.1)
lvRes = lvRes[!lvRes$VALDISTRIKT.1=="Uppsamlingsdistrikt", ]
lvRes$KEY <- lvRes$LÄN*1e6 + lvRes$KOM*1e4 + lvRes$VALDISTRIKT 
lvRes$NAMN = lvRes$VALDISTRIKT.1;
lvRes = lvRes[union(c("KEY","NAMN"),partier)]
lvRes[partier] = as.data.frame(lapply(lvRes[partier], function(y) gsub(",", ".", y)))
lvRes[partier] <- sapply( lvRes[partier], as.character )
lvRes[partier] <- sapply( lvRes[partier], as.numeric )
names(lvRes) = gsub(".proc","",names(lvRes))
saveRDS(lvRes,"Data/landstingsvalpervaldistrikt.rds")
rm(lvRes)

#-Riksdagssval
#--Kommun
url = "http://www.val.se/val/val2014/statistik/2014_riksdagsval_per_kommun.skv"
download(url, dest="tmp/2014_riksdagsval_per_kommun.skv", mode="wb") 
rkRes <- read.csv("tmp/2014_riksdagsval_per_kommun.skv", sep=';')
rkRes$KEY = rkRes$LAN*1e2 + rkRes$KOM
rkRes$NAMN = rkRes$KOMMUN
rkRes = rkRes[union(c("KEY","NAMN"),partier)]
rkRes[partier] = as.data.frame(lapply(rkRes[partier], function(y) gsub(",", ".", y)))
rkRes[partier] <- sapply( rkRes[partier], as.character )
rkRes[partier] <- sapply( rkRes[partier], as.numeric )
names(rkRes) = gsub(".proc","",names(rkRes))
saveRDS(rkRes,"Data/riksdagsvalperkommun.rds")
rm(rkRes)

#--Valdistrikt
url = "http://www.val.se/val/val2014/statistik/2014_riksdagsval_per_valdistrikt.skv"
download(url, dest="tmp/2014_riksdagsval_per_valdistrikt.skv", mode="wb") 
rvRes <- read.csv("tmp/2014_riksdagsval_per_valdistrikt.skv", sep=';')
rvRes$Valdistrikt <- as.character(rvRes$Valdistrikt)
rvRes = rvRes[!rvRes$Valdistrikt=="Uppsamlingsdistrikt", ]
rvRes$KEY <- rvRes$LAN*1e6 + rvRes$KOM*1e4 + rvRes$VALDIST
rvRes$NAMN = rvRes$Valdistrikt
rvRes = rvRes[union(c("KEY","NAMN"),partier)]
rvRes[partier] = as.data.frame(lapply(rvRes[partier], function(y) gsub(",", ".", y)))
rvRes[partier] <- sapply( rvRes[partier], as.character )
rvRes[partier] <- sapply( rvRes[partier], as.numeric )
names(rvRes) = gsub(".proc","",names(rvRes))
saveRDS(rvRes,"Data/riksdagsvalpervaldistrikt.rds")


  



