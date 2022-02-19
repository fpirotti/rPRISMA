#' PRISMA2Dos1cor
#'
#' Atmospheric correction of PRISMA data using DOS1 method (see Chavez 1996)
#' @param rastList  list: output from PRISMA2rast function
#' @param verbose logical: lot's of messages if True. Defaults to False.
#'
#' @return A list of terra::rast objects with values from 0 to 1 representing
#' corrected digital numbers of surface reflectance.
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
#' ### fn <- PRISMA2rast( file.path(filepath, filename), verbose=T)
PRISMA2Dos1cor<-function(rastList, verbose=F){

}
