test_that("Verify that single_point_firehose runs and returns something reasonable", {
  skip_on_cran()
  skip_if_offline(host = "r-project.org")
  
  library(tools)
  library(lubridate)
  library(sf)
  
  get_b = function() {
    aoi_name <- "colorado"
    bb <- getbb(aoi_name)
    my_boundary <- opq(bb, timeout=180) %>%
      add_osm_feature(key = "boundary", value = "national_park") %>%
      osmdata_sf()
    return(my_boundary)
  }
  
  # Read in the available data from the server
  inputs <- cft::available_data()
  
  # Build a small request
  input_variables <- inputs$variable_names %>% 
    filter(Variable %in% c("Precipitation")) %>% 
    filter(Scenario %in% c("RCP 4.5")) %>% 
    filter(Model %in% c(
      "Beijing Climate Center - Climate System Model 1.1" )) %>%
    
    pull("Available variable")
  
  expect_gt(length(input_variables), 0)
  
  my_boundary <- NULL
  attempt <- 0
  while( is.null(my_boundary) && attempt <= 3 ) {
    attempt <- attempt + 1
    try(
      my_boundary <- get_b()
    )
  } 
  
  if (is.null(my_boundary)) {
    fail("Could not establish connection with") 
  }
  
  boundaries <- my_boundary$osm_multipolygons[1,] 
  suppressWarnings(pt <- st_coordinates(st_centroid(boundaries)))
  lat_pt <- pt[1,2]
  lon_pt <- pt[1,1]
  
  web_link = "https://cida.usgs.gov/thredds/dodsC/macav2metdata_daily_future"
  src <- tidync::tidync(web_link)
  
  lons <- src %>% activate("D2") %>% hyper_tibble()
  lats <- src %>% activate("D1") %>% hyper_tibble()
  
  # Find the closest boundary that exists in the available data
  known_lon <- lons[which(abs(lons-lon_pt)==min(abs(lons-lon_pt))),]
  known_lat <- lats[which(abs(lats-lat_pt)==min(abs(lats-lat_pt))),] 
  
  out <- cft::single_point_firehose(input_variables, known_lat, known_lon)
  
  # time and geometry should always be included, if there are more that means
  # we received data from our request
  
  o_colnames <- colnames(out)
  
  expect_gt(length(o_colnames), 2)
  
  for (colname in o_colnames) {
    if  (!colname %in% c("geometry", "time")) {
      # Make sure data set returned is part of the input variables 
      expect_true(colname %in% input_variables)
      # Make sure there is some data in the column
      expect_gt(length(out[[colname]]), 0)
    }
  }
  
  for (g in out$geometry) {
    # Test the longitude is close 
    expect_lt(abs(g[1][1] - known_lon), 0.05)
    
    # Test the latitude is close 
    expect_lt(abs(g[2][1] - known_lat), 0.05)
  }
  
  # Make sure range of times returned is within 1950 - 2099
  expect_lte(lubridate::date(inputs$available_times[which(
    inputs$available_times[, 1] == max(out$time)), 2]),
    lubridate::date("2099-12-31"))
  expect_gte(lubridate::date(inputs$available_times[which(
    inputs$available_times[, 1] == min(out$time)), 2]),
    lubridate::date("2006-01-01"))
  
  traceback()
  
})
