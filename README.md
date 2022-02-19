# rPRISMA  
  <!-- badges: start -->
  [![R-CMD-check](https://github.com/fpirotti/rPRISMA/workflows/R-CMD-check/badge.svg)](https://github.com/fpirotti/rPRISMA/actions)
  <!-- badges: end -->

## Supports access and classification of [PRISMA](https://earth.esa.int/web/eoportal/satellite-missions/p/prisma-hyperspectral)  hyperspectral image data cubes

[PRISMA](https://earth.esa.int/web/eoportal/satellite-missions/p/prisma-hyperspectral) provides hyperspectral imagery at 30 m resolution from satellite orbiting vector.  

[PRISMA](https://earth.esa.int/web/eoportal/satellite-missions/p/prisma-hyperspectral) is a mission from Agenzia Spaziale Italiana (ASI) and is also the name of the sensor providing the imagery. 

[PRISMA](https://earth.esa.int/web/eoportal/satellite-missions/p/prisma-hyperspectral) imagery can be downloaded prior to registration, see HERE and HERE for more info.

[PRISMA](https://earth.esa.int/web/eoportal/satellite-missions/p/prisma-hyperspectral) data are provided in HDF5 format, which is not immediate to use. To foster its usage by the research community, rPRISMA provides function to convert easily to the more common GeoTIFF format. It also provides a streamlined workflow for classification via random forest machine learning algorithm. 

You are welcome to beta-test!

NB: terra library version >1.5 is required

## Usage

    PRISMA2geotiff("path-to-HDF5-file.he5", overwrite=T/F) 

will write two files, one for the VNIR cube and SWIR  cube, repsectively with the same basename as the original file, substituting .he5 extension with _VNIR.tif and _SWIR.tif.   

    PRISMA2rast("path-to-HDF5-file.he5")  
    
will provide you with a list with 2 elements of terra::rast type

## Installation    

NOT YET IN CRAN: ---

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fpirotti/rPRISMA")
```
