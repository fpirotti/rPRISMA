% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{PRISMA2geotiff}
\alias{PRISMA2geotiff}
\title{PRISMA2geotiff}
\usage{
PRISMA2geotiff(filepath, overwrite = F)
}
\arguments{
\item{filepath}{the filepath to HDF PRISMA dataset}

\item{overwrite}{Do you want to overwrite automatically any existing Geotiff file?}
}
\value{
logical TRUE on success or FALSE on error. Writes a geotiff file with the same basename. E.g.
XXX.he5 will be  XXX_VNIR.tif and XXX_SWIR.tif
}
\description{
PRISMA2geotiff
}
\examples{
### filepath<-"/archivio/shared/geodati/raster/OPTICAL/PRISMA/
### PRS_L2D_STD_20200418101701_20200418101706_0001.he5"
### fn <- PRISMA2geotiff(filepath)
}
