## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE:

* Depends: includes the non-default packages:
    'plyr', 'dplyr', 'osmdata', 'tidync', 'future', 'magrittr', 'furrr',
    'sf'
  Adding so many packages to the search path is excessive and importing
  selectively is preferable.
  
  It is necessary for each of these packages to be loaded for CFT's 
  most common use cases. Thus it is convenient for the user to
  only have to call library(cft) when using CFT in an R session or in an 
  R script.
  
## Unit testing
Unit tests in testthat cover 97% of the code. Coverage report can be found 
at https://app.codecov.io/gh/earthlab/cft-CRAN?branch=master

## Test environments
The CFT package has been tested on both macOS and Linux. It has been tested with 
the latest R development version on CRAN's servers as well. 