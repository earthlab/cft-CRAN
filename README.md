Climate Futures Toolbox
================

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/earthlab/cft-CRAN/branch/master/graph/badge.svg)](https://app.codecov.io/gh/earthlab/cft-CRAN?branch=master)
<!-- badges: end -->

# Welcome to the Climate Futures Toolbox

This is a package developed as a collaboration between Earth lab and the
North Central Climate Adaptation Science Center to help users gain
insights from available climate data. This package includes tools and
instructions for downloading climate data via a USGS API and then
organizing those data for visualization and analysis that drive insight.

This package is currently growing to include better functionality for
spatial analyses and more user-friendly features. Thank you for all the
wonderful beta tester groups that helped us get the software this far.
Please be patient as we update some of the functions and vignette to
accommodate more functionality.

# What you’ll find here

This vignette provides a walk-through of a common use case of the cft
package, which is, to help users download, organize, and visualize past
and future climate data.

1.  How to download and install the cft package
2.  How to see the menu of available data and choose items from that
    menu
3.  A description of both functions available in the cft package and
    their primary usage cases

## Why write the cft package?

The amount of data generated by downscaled GCMs can be quite large
(e.g., daily data at a few km spatial resolution). The Climate Futures
Toolbox was developed to help users access and use smaller subsets.

Data is acquired from the [Northwest Knowledge Server of the University
of
Idaho](http://thredds.northwestknowledge.net:8080/thredds/reacch_climate_CMIP5_macav2_catalog2.html).

### What you’ll need

To get the most out of this vignette, we assume you have:

- At least 500 MB of disk space
- Some familiarity with ggplot2
- Some familiarity with dplyr (e.g.,
  [`filter()`](https://www.rdocumentation.org/packages/dplyr/versions/0.7.8/topics/filter),
  [`group_by()`](https://www.rdocumentation.org/packages/dplyr/versions/0.7.8/topics/group_by),
  and
  [`summarise()`](https://www.rdocumentation.org/packages/dplyr/versions/0.7.8/topics/summarise))

## About the data

Global Circulation Models (GCMs) provide estimates of historical and
future climate conditions. The complexity of the climate system has lead
to a large number GCMs and it is common practice to examine outputs from
many different models, treating each as one plausible future.

Most GCMs are spatially coarse (often 1 degree), but downscaling
provides finer scale estimates. The cft package uses one downscaled
climate model called MACA (Multivariate Adaptive Climate Analog) Version
2 ([details here](https://www.climatologylab.org/maca.html)).

## Attach cft and check the list of available functions

``` r
library(cft)
```

    ## Loading required package: plyr

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:plyr':
    ## 
    ##     arrange, count, desc, failwith, id, mutate, rename, summarise,
    ##     summarize

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    ## Loading required package: osmdata

    ## Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright

    ## Loading required package: tidync

    ## Loading required package: future

    ## Loading required package: magrittr

    ## Loading required package: furrr

    ## Loading required package: sf

    ## Linking to GEOS 3.11.0, GDAL 3.5.1, PROJ 9.0.1; sf_use_s2() is TRUE

``` r
ls(pos="package:cft")
```

    ## [1] "available_data"        "single_point_firehose"

## Look at the documentation for those functions

``` r
?available_data
```

``` r
?single_point_firehose
```

# Use read-only mode to find available data without initiating a full download.

``` r
inputs <- cft::available_data()
```

    ## Trying to connect to the USGS.gov API

    ## not a file: 
    ## ' https://cida.usgs.gov/thredds/dodsC/macav2metdata_daily_future '
    ## 
    ## ... attempting remote connection

    ## Connection succeeded.

    ## Reading results

    ## Converting into an R data.table

# Donwloading Data

There are too many data available to download in a single download
request. You will need limit your requests to 500 MB. This is enough to
download a single variable for a single spatial point for the full
available time period, but not more than that. This means that we must
filter the results from available_data() to specify the data that we
want to actually download. If you want to pull multiple variables and/or
multiple spatial locations, you will need to submit multiple request for
data and merge those tables together after download. We provide examples
for both.

Notice that if you want to download multiple variables in their entirety
for several specific lat/long locations, single_point_firehose() will
provide better functionality than available_data(). The
single_point_firehose() function parallelizes the download requests,
which allows it to download a large quantity of data much faster than
the available_data() function. Additionally, the single_point_firehose()
function combines the data from the parallelized download requests into
a single sf spatial dataframe. A vignette walking through a common use
of the single_point_firehose() function can be found at
<https://github.com/earthlab/cft/blob/main/vignettes/firehose.md>

## We can look at just the unique variable types to get an idea of what’s available

``` r
levels(as.factor(inputs$variable_names$Variable))
```

    ## [1] "Eastward Wind"                       "Maximum Relative Humidity"          
    ## [3] "Maximum Temperature"                 "Minimum Relative Humidity"          
    ## [5] "Minimum Temperature"                 "Northward Wind"                     
    ## [7] "Precipitation"                       "Specific Humidity"                  
    ## [9] "Surface Downswelling Shortwave Flux"

``` r
levels(as.factor(inputs$variable_names$`Variable abbreviation`))
```

    ## [1] "huss"   "pr"     "rhsmax" "rhsmin" "rsds"   "tasmax" "tasmin" "uas"   
    ## [9] "vas"

``` r
levels(as.factor(inputs$variable_names$Scenario))
```

    ## [1] "RCP 4.5" "RCP 8.5"

``` r
levels(as.factor(inputs$variable_names$`Scenario abbreviation`))
```

    ## [1] "rcp45" "rcp85"

``` r
levels(as.factor(inputs$variable_names$Model))
```

    ##  [1] "Beijing Climate Center - Climate System Model 1.1"                                            
    ##  [2] "Beijing Normal University - Earth System Model"                                               
    ##  [3] "Canadian Earth System Model 2"                                                                
    ##  [4] "Centre National de Recherches Météorologiques - Climate Model 5"                              
    ##  [5] "Commonwealth Scientific and Industrial Research Organisation - Mk3.6.0"                       
    ##  [6] "Community Climate System Model 4"                                                             
    ##  [7] "Geophysical Fluid Dynamics Laboratory - Earth System Model 2 Generalized Ocean Layer Dynamics"
    ##  [8] "Geophysical Fluid Dynamics Laboratory - Earth System Model 2 Modular Ocean"                   
    ##  [9] "Hadley Global Environment Model 2 - Climate Chemistry 365 (day) "                             
    ## [10] "Hadley Global Environment Model 2 - Earth System 365 (day)"                                   
    ## [11] "Institut Pierre Simon Laplace (IPSL) - Climate Model 5A - Low Resolution"                     
    ## [12] "Institut Pierre Simon Laplace (IPSL) - Climate Model 5A - Medium Resolution"                  
    ## [13] "Institut Pierre Simon Laplace (IPSL) - Climate Model 5B - Low Resolution"                     
    ## [14] "Institute of Numerical Mathematics Climate Model 4"                                           
    ## [15] "Meteorological Research Institute - Coupled Global Climate Model 3"                           
    ## [16] "Model for Interdisciplinary Research On Climate - Earth System Model"                         
    ## [17] "Model for Interdisciplinary Research On Climate - Earth System Model - Chemistry"             
    ## [18] "Model for Interdisciplinary Research On Climate 5"                                            
    ## [19] "Norwegian Earth System Model 1 - Medium Resolution"

``` r
levels(as.factor(inputs$variable_names$`Model abbreviation`))
```

    ##  [1] "bcc-csm1-1"     "bcc-csm1-1-m"   "BNU-ESM"        "CanESM2"       
    ##  [5] "CCSM4"          "CNRM-CM5"       "CSIRO-Mk3-6-0"  "GFDL-ESM2G"    
    ##  [9] "GFDL-ESM2M"     "HadGEM2-CC365"  "HadGEM2-ES365"  "inmcm4"        
    ## [13] "IPSL-CM5A-LR"   "IPSL-CM5A-MR"   "IPSL-CM5B-LR"   "MIROC-ESM"     
    ## [17] "MIROC-ESM-CHEM" "MIROC5"         "MRI-CGCM3"      "NorESM1-M"

## But we prefer to use the table version so we can easily select combinations of variables that we want to pull together.

Here you will use tidy notation to filter the available_data table to
only include the entries that you would like to download.

## Filter variable names

This filter includes all of the climate models, all of the scenarios,
and 5 variables. It is a big request.

``` r
input_variables <- inputs$variable_names %>% 
  filter(Variable %in% c("Maximum Relative Humidity", 
                       "Maximum Temperature", 
                       "Minimum Relative Humidity",          
                       "Minimum Temperature",                 
                       "Precipitation")) %>% 
  filter(Scenario %in% c( "RCP 4.5", "RCP 8.5")) %>% 
  filter(Model %in% c(
    "Beijing Climate Center - Climate System Model 1.1",
    "Beijing Normal University - Earth System Model",
    "Canadian Earth System Model 2",                                                                
  "Centre National de Recherches Météorologiques - Climate Model 5",                              
  "Commonwealth Scientific and Industrial Research Organisation - Mk3.6.0",                       
  "Community Climate System Model 4",                                                             
  "Geophysical Fluid Dynamics Laboratory - Earth System Model 2 Generalized Ocean Layer Dynamics",
  "Geophysical Fluid Dynamics Laboratory - Earth System Model 2 Modular Ocean",                   
  "Hadley Global Environment Model 2 - Climate Chemistry 365 (day) ",                             
 "Hadley Global Environment Model 2 - Earth System 365 (day)",                                   
 "Institut Pierre Simon Laplace (IPSL) - Climate Model 5A - Low Resolution",                     
 "Institut Pierre Simon Laplace (IPSL) - Climate Model 5A - Medium Resolution",                  
 "Institut Pierre Simon Laplace (IPSL) - Climate Model 5B - Low Resolution",                     
 "Institute of Numerical Mathematics Climate Model 4",                                           
 "Meteorological Research Institute - Coupled Global Climate Model 3",                           
 "Model for Interdisciplinary Research On Climate - Earth System Model",                         
 "Model for Interdisciplinary Research On Climate - Earth System Model - Chemistry",             
 "Model for Interdisciplinary Research On Climate 5",                                            
 "Norwegian Earth System Model 1 - Medium Resolution"  )) %>%
  
  pull("Available variable")

input_variables
```

    ##   [1] "pr_BNU-ESM_r1i1p1_rcp45"            "pr_BNU-ESM_r1i1p1_rcp85"           
    ##   [3] "pr_CCSM4_r6i1p1_rcp45"              "pr_CCSM4_r6i1p1_rcp85"             
    ##   [5] "pr_CNRM-CM5_r1i1p1_rcp45"           "pr_CNRM-CM5_r1i1p1_rcp85"          
    ##   [7] "pr_CSIRO-Mk3-6-0_r1i1p1_rcp45"      "pr_CSIRO-Mk3-6-0_r1i1p1_rcp85"     
    ##   [9] "pr_CanESM2_r1i1p1_rcp45"            "pr_CanESM2_r1i1p1_rcp85"           
    ##  [11] "pr_GFDL-ESM2G_r1i1p1_rcp45"         "pr_GFDL-ESM2G_r1i1p1_rcp85"        
    ##  [13] "pr_GFDL-ESM2M_r1i1p1_rcp45"         "pr_GFDL-ESM2M_r1i1p1_rcp85"        
    ##  [15] "pr_HadGEM2-CC365_r1i1p1_rcp45"      "pr_HadGEM2-CC365_r1i1p1_rcp85"     
    ##  [17] "pr_HadGEM2-ES365_r1i1p1_rcp45"      "pr_HadGEM2-ES365_r1i1p1_rcp85"     
    ##  [19] "pr_IPSL-CM5A-LR_r1i1p1_rcp45"       "pr_IPSL-CM5A-LR_r1i1p1_rcp85"      
    ##  [21] "pr_IPSL-CM5A-MR_r1i1p1_rcp45"       "pr_IPSL-CM5A-MR_r1i1p1_rcp85"      
    ##  [23] "pr_IPSL-CM5B-LR_r1i1p1_rcp45"       "pr_IPSL-CM5B-LR_r1i1p1_rcp85"      
    ##  [25] "pr_MIROC-ESM-CHEM_r1i1p1_rcp45"     "pr_MIROC-ESM-CHEM_r1i1p1_rcp85"    
    ##  [27] "pr_MIROC-ESM_r1i1p1_rcp85"          "pr_MIROC-ESM_r1i1p1_rcp45"         
    ##  [29] "pr_MIROC5_r1i1p1_rcp45"             "pr_MIROC5_r1i1p1_rcp85"            
    ##  [31] "pr_MRI-CGCM3_r1i1p1_rcp45"          "pr_MRI-CGCM3_r1i1p1_rcp85"         
    ##  [33] "pr_NorESM1-M_r1i1p1_rcp45"          "pr_NorESM1-M_r1i1p1_rcp85"         
    ##  [35] "pr_bcc-csm1-1_r1i1p1_rcp45"         "pr_bcc-csm1-1_r1i1p1_rcp85"        
    ##  [37] "pr_inmcm4_r1i1p1_rcp45"             "pr_inmcm4_r1i1p1_rcp85"            
    ##  [39] "rhsmax_BNU-ESM_r1i1p1_rcp45"        "rhsmax_BNU-ESM_r1i1p1_rcp85"       
    ##  [41] "rhsmax_CNRM-CM5_r1i1p1_rcp45"       "rhsmax_CNRM-CM5_r1i1p1_rcp85"      
    ##  [43] "rhsmax_CSIRO-Mk3-6-0_r1i1p1_rcp45"  "rhsmax_CSIRO-Mk3-6-0_r1i1p1_rcp85" 
    ##  [45] "rhsmax_CanESM2_r1i1p1_rcp45"        "rhsmax_CanESM2_r1i1p1_rcp85"       
    ##  [47] "rhsmax_GFDL-ESM2G_r1i1p1_rcp45"     "rhsmax_GFDL-ESM2G_r1i1p1_rcp85"    
    ##  [49] "rhsmax_GFDL-ESM2M_r1i1p1_rcp45"     "rhsmax_HadGEM2-CC365_r1i1p1_rcp45" 
    ##  [51] "rhsmax_HadGEM2-CC365_r1i1p1_rcp85"  "rhsmax_HadGEM2-ES365_r1i1p1_rcp45" 
    ##  [53] "rhsmax_HadGEM2-ES365_r1i1p1_rcp85"  "rhsmax_IPSL-CM5A-LR_r1i1p1_rcp45"  
    ##  [55] "rhsmax_IPSL-CM5A-LR_r1i1p1_rcp85"   "rhsmax_IPSL-CM5A-MR_r1i1p1_rcp45"  
    ##  [57] "rhsmax_IPSL-CM5A-MR_r1i1p1_rcp85"   "rhsmax_IPSL-CM5B-LR_r1i1p1_rcp45"  
    ##  [59] "rhsmax_IPSL-CM5B-LR_r1i1p1_rcp85"   "rhsmax_MIROC-ESM-CHEM_r1i1p1_rcp45"
    ##  [61] "rhsmax_MIROC-ESM-CHEM_r1i1p1_rcp85" "rhsmax_MIROC-ESM_r1i1p1_rcp45"     
    ##  [63] "rhsmax_MIROC-ESM_r1i1p1_rcp85"      "rhsmax_MIROC5_r1i1p1_rcp45"        
    ##  [65] "rhsmax_MIROC5_r1i1p1_rcp85"         "rhsmax_MRI-CGCM3_r1i1p1_rcp45"     
    ##  [67] "rhsmax_MRI-CGCM3_r1i1p1_rcp85"      "rhsmax_bcc-csm1-1_r1i1p1_rcp45"    
    ##  [69] "rhsmax_bcc-csm1-1_r1i1p1_rcp85"     "rhsmax_inmcm4_r1i1p1_rcp45"        
    ##  [71] "rhsmax_inmcm4_r1i1p1_rcp85"         "rhsmin_BNU-ESM_r1i1p1_rcp45"       
    ##  [73] "rhsmin_BNU-ESM_r1i1p1_rcp85"        "rhsmin_CNRM-CM5_r1i1p1_rcp45"      
    ##  [75] "rhsmin_CNRM-CM5_r1i1p1_rcp85"       "rhsmin_CSIRO-Mk3-6-0_r1i1p1_rcp45" 
    ##  [77] "rhsmin_CSIRO-Mk3-6-0_r1i1p1_rcp85"  "rhsmin_CanESM2_r1i1p1_rcp45"       
    ##  [79] "rhsmin_CanESM2_r1i1p1_rcp85"        "rhsmin_GFDL-ESM2G_r1i1p1_rcp45"    
    ##  [81] "rhsmin_GFDL-ESM2G_r1i1p1_rcp85"     "rhsmin_GFDL-ESM2M_r1i1p1_rcp45"    
    ##  [83] "rhsmin_GFDL-ESM2M_r1i1p1_rcp85"     "rhsmin_HadGEM2-CC365_r1i1p1_rcp45" 
    ##  [85] "rhsmin_HadGEM2-CC365_r1i1p1_rcp85"  "rhsmin_HadGEM2-ES365_r1i1p1_rcp45" 
    ##  [87] "rhsmin_HadGEM2-ES365_r1i1p1_rcp85"  "rhsmin_IPSL-CM5A-LR_r1i1p1_rcp45"  
    ##  [89] "rhsmin_IPSL-CM5A-LR_r1i1p1_rcp85"   "rhsmin_IPSL-CM5A-MR_r1i1p1_rcp45"  
    ##  [91] "rhsmin_IPSL-CM5A-MR_r1i1p1_rcp85"   "rhsmin_IPSL-CM5B-LR_r1i1p1_rcp45"  
    ##  [93] "rhsmin_IPSL-CM5B-LR_r1i1p1_rcp85"   "rhsmin_MIROC-ESM-CHEM_r1i1p1_rcp45"
    ##  [95] "rhsmin_MIROC-ESM-CHEM_r1i1p1_rcp85" "rhsmin_MIROC-ESM_r1i1p1_rcp45"     
    ##  [97] "rhsmin_MIROC-ESM_r1i1p1_rcp85"      "rhsmin_MIROC5_r1i1p1_rcp45"        
    ##  [99] "rhsmin_MIROC5_r1i1p1_rcp85"         "rhsmin_MRI-CGCM3_r1i1p1_rcp45"     
    ## [101] "rhsmin_MRI-CGCM3_r1i1p1_rcp85"      "rhsmin_bcc-csm1-1_r1i1p1_rcp45"    
    ## [103] "rhsmin_bcc-csm1-1_r1i1p1_rcp85"     "rhsmin_inmcm4_r1i1p1_rcp45"        
    ## [105] "rhsmin_inmcm4_r1i1p1_rcp85"         "tasmax_BNU-ESM_r1i1p1_rcp45"       
    ## [107] "tasmax_BNU-ESM_r1i1p1_rcp85"        "tasmax_CCSM4_r6i1p1_rcp45"         
    ## [109] "tasmax_CCSM4_r6i1p1_rcp85"          "tasmax_CNRM-CM5_r1i1p1_rcp45"      
    ## [111] "tasmax_CNRM-CM5_r1i1p1_rcp85"       "tasmax_CSIRO-Mk3-6-0_r1i1p1_rcp45" 
    ## [113] "tasmax_CSIRO-Mk3-6-0_r1i1p1_rcp85"  "tasmax_CanESM2_r1i1p1_rcp45"       
    ## [115] "tasmax_CanESM2_r1i1p1_rcp85"        "tasmax_GFDL-ESM2G_r1i1p1_rcp45"    
    ## [117] "tasmax_GFDL-ESM2G_r1i1p1_rcp85"     "tasmax_GFDL-ESM2M_r1i1p1_rcp45"    
    ## [119] "tasmax_GFDL-ESM2M_r1i1p1_rcp85"     "tasmax_HadGEM2-CC365_r1i1p1_rcp45" 
    ## [121] "tasmax_HadGEM2-CC365_r1i1p1_rcp85"  "tasmax_HadGEM2-ES365_r1i1p1_rcp45" 
    ## [123] "tasmax_HadGEM2-ES365_r1i1p1_rcp85"  "tasmax_IPSL-CM5A-LR_r1i1p1_rcp45"  
    ## [125] "tasmax_IPSL-CM5A-LR_r1i1p1_rcp85"   "tasmax_IPSL-CM5A-MR_r1i1p1_rcp45"  
    ## [127] "tasmax_IPSL-CM5A-MR_r1i1p1_rcp85"   "tasmax_IPSL-CM5B-LR_r1i1p1_rcp45"  
    ## [129] "tasmax_IPSL-CM5B-LR_r1i1p1_rcp85"   "tasmax_MIROC-ESM-CHEM_r1i1p1_rcp45"
    ## [131] "tasmax_MIROC-ESM-CHEM_r1i1p1_rcp85" "tasmax_MIROC-ESM_r1i1p1_rcp45"     
    ## [133] "tasmax_MIROC-ESM_r1i1p1_rcp85"      "tasmax_MIROC5_r1i1p1_rcp45"        
    ## [135] "tasmax_MIROC5_r1i1p1_rcp85"         "tasmax_MRI-CGCM3_r1i1p1_rcp45"     
    ## [137] "tasmax_MRI-CGCM3_r1i1p1_rcp85"      "tasmax_NorESM1-M_r1i1p1_rcp45"     
    ## [139] "tasmax_NorESM1-M_r1i1p1_rcp85"      "tasmax_bcc-csm1-1_r1i1p1_rcp45"    
    ## [141] "tasmax_bcc-csm1-1_r1i1p1_rcp85"     "tasmax_inmcm4_r1i1p1_rcp45"        
    ## [143] "tasmax_inmcm4_r1i1p1_rcp85"         "tasmin_BNU-ESM_r1i1p1_rcp45"       
    ## [145] "tasmin_BNU-ESM_r1i1p1_rcp85"        "tasmin_CCSM4_r6i1p1_rcp45"         
    ## [147] "tasmin_CCSM4_r6i1p1_rcp85"          "tasmin_CNRM-CM5_r1i1p1_rcp45"      
    ## [149] "tasmin_CNRM-CM5_r1i1p1_rcp85"       "tasmin_CSIRO-Mk3-6-0_r1i1p1_rcp45" 
    ## [151] "tasmin_CSIRO-Mk3-6-0_r1i1p1_rcp85"  "tasmin_CanESM2_r1i1p1_rcp45"       
    ## [153] "tasmin_CanESM2_r1i1p1_rcp85"        "tasmin_GFDL-ESM2G_r1i1p1_rcp45"    
    ## [155] "tasmin_GFDL-ESM2G_r1i1p1_rcp85"     "tasmin_GFDL-ESM2M_r1i1p1_rcp45"    
    ## [157] "tasmin_GFDL-ESM2M_r1i1p1_rcp85"     "tasmin_HadGEM2-CC365_r1i1p1_rcp45" 
    ## [159] "tasmin_HadGEM2-CC365_r1i1p1_rcp85"  "tasmin_HadGEM2-ES365_r1i1p1_rcp45" 
    ## [161] "tasmin_HadGEM2-ES365_r1i1p1_rcp85"  "tasmin_IPSL-CM5A-LR_r1i1p1_rcp45"  
    ## [163] "tasmin_IPSL-CM5A-LR_r1i1p1_rcp85"   "tasmin_IPSL-CM5A-MR_r1i1p1_rcp45"  
    ## [165] "tasmin_IPSL-CM5A-MR_r1i1p1_rcp85"   "tasmin_IPSL-CM5B-LR_r1i1p1_rcp45"  
    ## [167] "tasmin_IPSL-CM5B-LR_r1i1p1_rcp85"   "tasmin_MIROC-ESM-CHEM_r1i1p1_rcp45"
    ## [169] "tasmin_MIROC-ESM-CHEM_r1i1p1_rcp85" "tasmin_MIROC-ESM_r1i1p1_rcp45"     
    ## [171] "tasmin_MIROC-ESM_r1i1p1_rcp85"      "tasmin_MIROC5_r1i1p1_rcp45"        
    ## [173] "tasmin_MIROC5_r1i1p1_rcp85"         "tasmin_MRI-CGCM3_r1i1p1_rcp45"     
    ## [175] "tasmin_MRI-CGCM3_r1i1p1_rcp85"      "tasmin_NorESM1-M_r1i1p1_rcp45"     
    ## [177] "tasmin_NorESM1-M_r1i1p1_rcp85"      "tasmin_bcc-csm1-1_r1i1p1_rcp45"    
    ## [179] "tasmin_bcc-csm1-1_r1i1p1_rcp85"     "tasmin_inmcm4_r1i1p1_rcp45"        
    ## [181] "tasmin_inmcm4_r1i1p1_rcp85"

# Climate Futures Toolbox Functions

As previously mentioned, the climate futures toolbox includes two
functions: available_data() and single_point_firehose(). While both of
these functions are used to download data from the MACA climate model,
they have slightly different usage cases which will be described below.

## Available Data Function

The available_data() function can be used to download data from the MACA
climate model. These downloads can include data about multiple variables
for multiple emission scenarios and from multiple climate models over a
desired length of time and over a desired spatial region. However, there
is a 500 MB limit on the size of the download request when using
available_data which limits the amount of data that can be requested in
a download and successfully downloaded. It is possible to submit a
download request that exceeds the 500 MB limit, but the download will
not finish and an error message will be produced, as mentioned above.
Notice that there is no singular cut-off on the number of variables,
emissions scenarios, and climate models can be requested for a given
time period and a given spatial region. If you need to download more
than 500 MB of data, you can either make multiple download requests by
calling available_data multiple times and stitching the data obtained
from those download requests together or you can use the
single_point_firehose function which parallelizes download requests and
combines the data into a single spatial dataframe. An example of how to
make multiple download requests using available_data is shown in the
available_data vignette at:
<https://github.com/earthlab/cft/blob/main/vignettes/available-data.md>.
As is mentioned in the available_data vignette, it is computationally
expensive to stitch the data from multiple download requests using
availabe_data together, so it is easier and more computationally
efficient to use the single_point_firehose function if you encounter
errors when trying to download data using the available_data function.

**Overall, the available_data function works best for downloading MACA
climate model data for several climate variables from several climate
models for any number of emission scenarios over a relatively small
spatial region and over a relatively short time period.**

## Firehose Function

The single_point_firehose() function is also used to download data from
the MACA climate model. Unlike the available_data function, however, the
single_point_firehose function parallelizes multiple download requests
across the cores of your computer. This allows for faster downloading of
data from the MACA climate model and permits users to request data about
multiple climate variables from multiple models and emission scenarios
in their entirety because the download requests are broken up such that
no download request exceeds the 500 MB limit. After the data are
downloaded from the MACA climate model from these parallelized download
requests, the single_point_firehose function combines the data into a
single spatial dataframe. It is important to note that the
single_point_firehose function obtains data from the MACA climate model
for multiple climate variables from multiple models and emission
scenarios in their entirety **for a single lat/long location**. If you
need MACA climate model data for multiple climate variables from
multiple models and emission scenarios in their entirety at multiple
lat/long locations, you will need to make multiple calls to the
single_point_firehose function and combine the data from those requests.
An example of how to use the single_point_firehose function to download
MACA climate model data is shown in the firehose vignette at
<https://github.com/earthlab/cft/blob/main/vignettes/firehose.md>.

**Therefore, the single_point_firehose function works best for
downloading MACA climate model data for multiple climate variables from
multiple climate models and emission scenarios in their entirety for a
single lat/long location.**
