#' PRISMA2geotiff
#'
#' Exports PRISMA data cube to two geotiff files.
#'
#' @param input character or list: if *character* it is the filepath to HDF PRISMA
#' dataset, if it is a *list* it is the output of the PRISMA2rast function, and
#' should contain
#' @param output character (optional): the filepath and file name to save to.
#' Defaults to a geotiff file with the same basename. E.g. /path/XXX.he5 will be
#' /path/XXX_VNIR.tif and /path/XXX_SWIR.tif.
#' @param overwrite logical: do you want to overwrite automatically any existing
#' Geotiff file with the same name?
#' @param verbose logical: lot's of messages if True. Defaults to False.
#'
#' @return logical: TRUE on success or FALSE on error.
#' @export
#'
#' @examples
#' filepath<-"/archivio/shared/geodati/raster/OPTICAL/PRISMA/"
#' filename<-"PRS_L2D_STD_20200418101701_20200418101706_0001.he5"
#' # PRISMA2geotiff( input=file.path(filepath, filename), verbose=TRUE)
PRISMA2geotiff<-function(input, output= NA, overwrite=F, verbose=F){

  if(is.character(input)){
    dn<-dirname(input)
    bn<-basename(input)
    bn<-tools::file_path_sans_ext(bn)

    bricks<-PRISMA2rast(input, verbose=verbose)
  } else if(is.list(input)){
    dn<-input$filepath
    bn<-input$filename
    bricks<- input
  } else {
    stop("Input is " , class(input), " only character or list classes can be used...")
  }
  # browser()
  vnir.out<-file.path(dn, paste(bn, "_VNIR.tif", sep=""))
  swir.out<-file.path(dn, paste(bn, "_SWIR.tif", sep=""))
  message("Writing ", vnir.out)
  terra::writeRaster(bricks[["vnir"]], vnir.out, overwrite=overwrite)
  message("Writing ", swir.out)
  terra::writeRaster(bricks[["swir"]], swir.out, overwrite=overwrite)
}



#' PRISMA2rast
#'
#' Reads PRISMA data and returns a terra::rast object
#' @param input character: text of the filepath to HDF PRISMA dataset
#' @param verbose logical: lot's of messages if True. Defaults to False.
#'
#' @return A list of terra::rast objects
#' \itemize{
#'   \item swir data cube
#'   \item vnir data cube
#' }
#'
#' @export
#'
#' @examples
#' ### filepath<-"/archivio/shared/geodati/raster/OPTICAL/PRISMA/"
#' ### filename<-"PRS_L2D_STD_20200418101701_20200418101706_0001.he5"
#' ### fn <- PRISMA2rast( input=file.path(filepath, filename), verbose=TRUE)
PRISMA2rast<-function(input, verbose=F){

  if(!file.exists(input)){
    warning("File does not exist")
    return(NULL)
  }

  ext<-substr(input, nchar(input)-3+1, nchar(input))
  if(tolower(ext)!="he5") {

    warning("File does not have he5 extension, will try to proceed anyway")
  }

  dn<-dirname(input)
  bn<-basename(input)
  bn<-tools::file_path_sans_ext(bn)

  bricks<-list()
  bricks[['filepath']]<-dn
  bricks[['filename']]<-bn

  op<-hdf5r::H5File$new(input)

  pp <- op$ls(recursive=TRUE)
  if(nrow(pp)==0){
    warning("HDF file seems empty... is the file corrupt?")
    return(NULL)
  }

  geocod.lat<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Geolocation Fields/Latitude")
  geocod.lng<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Geolocation Fields/Longitude")
  lat<-geocod.lat$read()
  lng<-geocod.lng$read()


  cube<-list()
  cube[["swir"]]<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Data Fields/SWIR_Cube")
  cube[["vnir"]]<-op$open("HDFEOS/SWATHS/PRS_L2D_HCO/Data Fields/VNIR_Cube")
  cube[["pan"]]<-op$open("HDFEOS/SWATHS/PRS_L2D_PCO/Data Fields/Cube")

  pb <- progress::progress_bar$new(format = "[:bar] :current/:total (:percent)",
                                   total = cube[["swir"]]$dims[[2]] +
                                     cube[["vnir"]]$dims[[2]]  + 10 )

  pb$tick()

  img<-list()
  if(verbose) pb$message("Reading Panchromatic cube....")
  img[["pan"]] <- cube[["pan"]]$read()

  bricks[['panchromatic']] <- terra::rast(
    t(img[["pan"]])
  )

  terra::crs(bricks[['panchromatic']]) <- "epsg:4326"
  terra::ext(bricks[['panchromatic']]) <- c(min(lng), max(lng), min(lat), max(lat) )

  for(n in c("swir", "vnir")){

    if(verbose) pb$message(paste("Reading ", toupper(n) , " cube...."))
    img[[n]]<-cube[[n]]$read()

    pb$tick()

    nl<-dim(img[[n]])[[2]]

    if(verbose) pb$message(paste("Writing ", nl, " bands from ", toupper(n), " cube to raster..."))


    r<-terra::rast()
    for(i in 1:nl){
      pb$tick()
      r <- c(r, terra::rast(
        t(img[[n]][,i,])
        ), warn=FALSE )

    }

    if(verbose) pb$message(paste("Adding", toupper(n), " to stack object"))

    terra::crs(r) <- "epsg:4326"
    terra::ext(r) <- c(min(lng), max(lng), min(lat), max(lat) )
    bricks[[n]]<-r

}

  pb$terminate()

  op$close_all()
  bricks
}
