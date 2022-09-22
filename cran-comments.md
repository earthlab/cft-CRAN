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
The full unit test suite covers 97% of the code. Coverage report can be found 
at https://app.codecov.io/gh/earthlab/cft-CRAN?branch=master. 
test_single_point_firehose.R is moved out of the testthat directory because it 
takes too long to test. Tests that were removed from the submission because they
take too long can be found at 
https://github.com/earthlab/cft-CRAN/tree/master/full_tests

## Test platforms
Local testing was performed on MacOS Monterey 12.3.1. 

Testing was performed
on Ubuntu Linux 20.04.1 LTS, R-release, GCC using rhub and returned 2 NOTEs:

* Possibly misspelled words in DESCRIPTION:
  USGS (35:272)
  
  Acronym, not misspelled
  
* Depends: includes the non-default packages:
    'plyr', 'dplyr', 'osmdata', 'tidync', 'future', 'magrittr', 'furrr',
    'sf'
  Adding so many packages to the search path is excessive and importing
  selectively is preferable.
  
  It is necessary for each of these packages to be loaded for CFT's 
  most common use cases. Thus it is convenient for the user to
  only have to call library(cft) when using CFT in an R session or in an 
  R script.
The report can be found at 
https://builder.r-hub.io/status/cft_1.0.0.tar.gz-672f603b42944bc49658c5e8919da4e7

Testing was performed
on Fedora Linux, R-devel, clang, gfortran using rhub and returned 3 NOTEs:

* Possibly misspelled words in DESCRIPTION:
  USGS (35:272)
  
  Acronym, not misspelled
  
* Depends: includes the non-default packages:
    'plyr', 'dplyr', 'osmdata', 'tidync', 'future', 'magrittr', 'furrr',
    'sf'
  Adding so many packages to the search path is excessive and importing
  selectively is preferable.
  
  It is necessary for each of these packages to be loaded for CFT's 
  most common use cases. Thus it is convenient for the user to
  only have to call library(cft) when using CFT in an R session or in an 
  R script.

* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found

Looks to be an issue with the platform environment

The report can be found at 
https://builder.r-hub.io/status/cft_1.0.0.tar.gz-46fe6d4b058343fe99a5c20b0733d22f


## Downstream dependencies
This will be the initial release of CFT on CRAN