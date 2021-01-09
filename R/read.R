#' PRISMA2geotiff
#'
#' @param filepath the filepath to HDF PRISMA dataset
#' @param overwrite Do you want to overwrite automatically any existing Geotiff file?
#'
#' @return logical TRUE on success or FALSE on error. Writes a geotiff file with the same basename. E.g.
#'  XXX.he5 will be  XXX_VNIR.tif and XXX_SWIR.tif
#' @export
#'
#' @examples
#' ### filepath<-"/archivio/shared/geodati/raster/OPTICAL/PRISMA/
#' ### PRS_L2D_STD_20200418101701_20200418101706_0001.he5"
#' ### fn <- PRISMA2geotiff(filepath)
PRISMA2geotiff<-function(filepath, overwrite=F){
  dn<-dirname(filepath)
  bn<-basename(filepath)
  raster::extension(bn)<-""

  bricks<-PRISMA2rast(filepath)

  vnir.out<-file.path(dn, paste(bn, "_VNIR.tif", sep=""))
  swir.out<-file.path(dn, paste(bn, "_SWIR.tif", sep=""))
  message("Writing ", vnir.out)
  raster::writeRaster(bricks[["vnir"]], vnir.out, overwrite=overwrite)
  message("Writing ", swir.out)
  raster::writeRaster(bricks[["swir"]], swir.out, overwrite=overwrite)
}



#' PRISMA2rast
#'
#' @param filepath the filepath to HDF PRISMA dataset
#'
#' @return A list object with
#' \itemize{
#'   \item swir - raster::brick object
#'   \item vnir - raster::brick object
#' }
#'
#' @export
#'
#' @examples
#' ### filepath<-"/archivio/shared/geodati/raster/
#' ## OPTICAL/PRISMA/PRS_L2D_STD_20200418101701_20200418101706_0001.he5"
#' ### fn <- PRISMA2rast(filepath)
PRISMA2rast<-function(filepath){

  if(!file.exists(filepath)){
    warning("File does not exist")
    return(NULL)
  }

  if(!tolower(raster::extension(filepath))!="he5") {
    warning("File does not have he5 extension, will try to proceed anyway")
  }

  op<-hdf5r::H5File$new(filepath)

  pp <- op$ls(recursive=TRUE)
  if(nrow(pp)==0){
    warning("HDF file seems empty... is the file corrupt?")
    return(NULL)
  }

  geocod.lat<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Geolocation Fields/Latitude")
  geocod.lng<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Geolocation Fields/Longitude")
  lat<-geocod.lat$read()
  lng<-geocod.lng$read()


  swir.cube<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Data Fields/SWIR_Cube")
  vnir.cube<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Data Fields/VNIR_Cube")

  pb <- progress::progress_bar$new(format = "[:bar] :current/:total (:percent)",
                                   total = swir.cube$dims[[2]] + vnir.cube$dims[[2]]  + 10 )


  pb$tick()
  pb$message("Reading file's SWIR cube....")

  img<-list()
  img[["swir"]]<-swir.cube$read()

  pb$tick()
  pb$message("Reading file's VNIR cube....")
  img[["vnir"]]<-vnir.cube$read()


  bricks<-list()
  for(n in names(img)){
    pb$message(paste("Writing", toupper(n), " cube to rasters..."))
    nl<-dim(img[[n]])[[2]]

    pb$tick()

    r<-list()
    for(i in 1:nl){
      pb$tick()
      r[[as.character(i)]]<- raster::raster(
        xmn=min(lng), xmx=max(lng),
        ymn=min(lat), ymx=max(lat),
        t(img[[n]][,i,]),
        crs=4326)
    }


    pb$tick()
    pb$message(paste("Adding", toupper(n), "to stack object (can...."))

    bricks[[n]]<-raster::brick(r)

}

  pb$terminate()

  op$close_all()
  bricks
}
