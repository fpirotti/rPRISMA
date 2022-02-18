#' PRISMA2geotiff
#'
#' @param filepath the filepath to HDF PRISMA dataset
#' @param overwrite Do you want to overwrite automatically any existing Geotiff file?
#' @param verbose boolean - lot's of messages if True
#'
#' @return logical TRUE on success or FALSE on error. Writes a geotiff file with the same basename. E.g.
#'  XXX.he5 will be  XXX_VNIR.tif and XXX_SWIR.tif
#' @export
#'
#' @examples
#' ### filepath<-"/archivio/shared/geodati/raster/OPTICAL/PRISMA/"
#' ### PRS_L2D_STD_20200418101701_20200418101706_0001.he5"
#' ### fn <- PRISMA2geotiff(filepath)
PRISMA2geotiff<-function(filepath, overwrite=F, verbose=F){
  dn<-dirname(filepath)
  bn<-basename(filepath)
  bn<-tools::file_path_sans_ext(bn)

  bricks<-PRISMA2rast(filepath, verbose=verbose)

  vnir.out<-file.path(dn, paste(bn, "_VNIR.tif", sep=""))
  swir.out<-file.path(dn, paste(bn, "_SWIR.tif", sep=""))
  message("Writing ", vnir.out)
  terra::writeRaster(bricks[["vnir"]], vnir.out, overwrite=overwrite)
  message("Writing ", swir.out)
  terra::writeRaster(bricks[["swir"]], swir.out, overwrite=overwrite)
}



#' PRISMA2rast
#' Reads PRISMA data and saves to a terra::rast object
#' @param filepath text of the filepath to HDF PRISMA dataset
#' @param verbose boolean - lot's of messages if True
#'
#' @return A list object with
#' \itemize{
#'   \item swir - terra::rast object
#'   \item vnir - terra::rast object
#' }
#'
#' @export
#'
#' @examples
#' ### filepath<-"/archivio/shared/geodati/raster/OPTICAL/PRISMA/
#' PRS_L2D_STD_20200418101701_20200418101706_0001.he5"
#' ### fn <- PRISMA2rast(filepath, verbose=T)
PRISMA2rast<-function(filepath, verbose=F){

  if(!file.exists(filepath)){
    warning("File does not exist")
    return(NULL)
  }
  ext<-substr(filepath, nchar(filepath)-3+1, nchar(filepath))
  if(!tolower(ext)!="he5") {
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
  if(verbose) pb$message("Reading SWIR cube....")

  img<-list()
  img[["swir"]]<-swir.cube$read()

  pb$tick()
  if(verbose) pb$message("Reading VNIR cube....")
  img[["vnir"]]<-vnir.cube$read()


  bricks<-list()
  for(n in names(img)){
    nl<-dim(img[[n]])[[2]]
    if(verbose) pb$message(paste("Writing ", nl, " bands from ", toupper(n), " cube to raster..."))

    pb$tick()

    r<-terra::rast()
    r2 <- terra::rast( nrows=dim(img[[n]])[[1]], ncols=dim(img[[n]])[[3]], nlyrs=nl,
       xmin=min(lng), xmax=max(lng),
       ymin=min(lat), ymax=max(lat)
    )
    for(i in 1:nl){
      pb$tick()

      # browser()
      # terra::values(r2[[1]]) <- 1:terra::ncell(r2) #as.vector(img[[n]][,i,])
      r <- c(r, terra::rast(
        t(img[[n]][,i,])
        ) )
      if(i>10) break
    }


    pb$tick()
    if(verbose) pb$message(paste("Adding", toupper(n), "to stack object"))

    terra::crs(r) <- "epsg:4326"
    terra::ext(r) <- c(min(lng), max(lng), min(lat), max(lat) )
    bricks[[n]]<-r

}

  pb$terminate()

  op$close_all()
  bricks
}
