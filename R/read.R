#' PRISMA2rast
#'
#' @param filepath
#'
#' @return raster brick object
#' @export
#'
#' @examples
#' filepath<-"/archivio/shared/geodati/raster/OPTICAL/PRISMA/PRS_L2D_STD_20200418101701_20200418101706_0001.he5"
#' fn <- read.h5(filepath)
PRISMA2rast<-function(filepath, overwrite=F){

  if(!file.exists(filepath)){
    warning("File does not exist")
    return(NULL)
  }

  op<-hdf5r::H5File$new(filepath)
  tp <- op$get_obj_type()

  pp <- op$ls(recursive=TRUE)

  geocod.lat<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Geolocation Fields/Latitude")
  geocod.lng<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Geolocation Fields/Longitude")
  lat<-geocod.lat$read()
  lng<-geocod.lng$read()


  swir.cube<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Data Fields/SWIR_Cube")
  vnir.cube<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Data Fields/VNIR_Cube")
  swir.img<-swir.cube$read()
  vnir.img<-vnir.cube$read()

  nl<-dim(vnir.img)[[2]]

  pb <- progress::progress_bar$new(format = "[:bar] :current/:total (:percent)",
                                   total = nl+2 )
  r<-list()
  for(i in 1:nl){
    pb$tick()
    r[[as.character(i)]]<- raster::raster(
                       xmn=min(lng), xmx=max(lng),
                       ymn=min(lat), ymx=max(lat),
                       t(vnir.img[,i,]),
                       crs=4326)
    #raster::plot(r)

  }

  dn<-dirname(filepath)
  bn<-basename(filepath)
  raster::extension(bn)<-""

  vnir.out<-file.path(dn, paste(bn, "_VNIR.tif", sep=""))
  swir.out<-file.path(dn, paste(bn, "_SWIR.tif", sep=""))

  pb$tick()
  pb$message("Adding to stack object....")

  vnir.brick<-raster::brick(r)

  pb$tick()
  pb$message("Saving VNIR to GeoTIFF....")
  raster::writeRaster(vnir.brick, vnir.out, overwrite=overwrite)
  pb$terminate()


  # replace with correct coordinates
  ##raster::extent(r) <- c(0, 1, 0, 1)


  plot(img)


  op$close_all()
}
