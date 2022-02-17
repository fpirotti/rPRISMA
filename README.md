# rPRISMA  

Converts [PRISMA](https://earth.esa.int/web/eoportal/satellite-missions/p/prisma-hyperspectral){target=_blank} hyperspectral satellite dataset, which is provided in HDF5 format, in GeoTIFF images.

**NOT YET TESTED**

## Usage

    PRISMA2geotiff("path-to-HDF5-file.he5", overwrite=T/F) 

will write two files, one for the VNIR cube and SWIR  cube, repsectively with the same basename as the original file, substituting .he5 extension with _VNIR.tif and _SWIR.tif.   

    PRISMA2rast("path-to-HDF5-file.he5")  
    
will provide you with a list with 2 elements of raster::brick type

## Installation    

NOT YET IN CRAN: ---

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fpirotti/rPRISMA")
```
