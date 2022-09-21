## -----------------------------------------------------------------------------
library(cft)
ls(pos="package:cft")

## -----------------------------------------------------------------------------
inputs <- cft::available_data()

## -----------------------------------------------------------------------------
?available_data
?single_point_firehose

## -----------------------------------------------------------------------------
levels(as.factor(inputs$variable_names$Variable))
levels(as.factor(inputs$variable_names$`Variable abbreviation`))
levels(as.factor(inputs$variable_names$Scenario))
levels(as.factor(inputs$variable_names$`Scenario abbreviation`))
levels(as.factor(inputs$variable_names$Model))
levels(as.factor(inputs$variable_names$`Model abbreviation`))

## -----------------------------------------------------------------------------
library(magrittr)
library(dplyr)
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

## ----bounding_box_small, cache=TRUE-------------------------------------------
library(osmdata)
bb <- getbb("Hot Springs")
my_boundary <- opq(bb, timeout=300) %>% 
  add_osm_feature(key = "boundary", value = "national_park") %>% 
osmdata_sf() 
my_boundary

## ----pulled_bounding_box_small, cache=TRUE------------------------------------
library(osmdata)
library(sf)
boundaries <- my_boundary$osm_multipolygons
pulled_bb <- st_bbox(boundaries)
pulled_bb

## ----plot_of_area_of_interest_small, cache=TRUE, warning=FALSE, fig.height=8----
library(ggplot2)
basemap <- ggplot(data = boundaries) +
  geom_sf(fill = "cornflowerblue") +
  suppressWarnings(geom_sf_text(aes(label = boundaries$name))) 
basemap

## ----pull data for single point for one year, eval=TRUE-----------------------
library(osmdata)
library(sf)
library(tidync)
start_time <- Sys.time()
center_point <- st_centroid(boundaries) %>% st_bbox(center_point)
times <- inputs$available_times
Pulled_data_single_space_single_timepoint <- inputs$src %>% 
  hyper_filter(lat = lat <= c(center_point[4]+0.05) & lat >= c(center_point[2]-0.05)) %>% 
  hyper_filter(lon = lon <= c(center_point[3]+0.05) & lon >= c(center_point[1]-0.05)) %>%
  hyper_filter(time = times$`Available times` ==  44558) %>% 
  hyper_tibble(select_var = input_variables[1:38]) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant") 
end_time <- Sys.time()
print(end_time - start_time)
head(Pulled_data_single_space_single_timepoint)

## ----pull data for single point for all years, eval=FALSE---------------------
#  library(osmdata)
#  library(sf)
#  library(tidync)
#  start_time <- Sys.time()
#  center_point <- st_centroid(boundaries) %>% st_bbox(center_point)
#  Pulled_data_single_space_all_timepoints <- inputs$src %>%
#    hyper_filter(lat = lat <= c(center_point[4]+0.05) & lat >= c(center_point[2]-0.05)) %>%
#    hyper_filter(lon = lon <= c(center_point[3]+0.05) & lon >= c(center_point[1]-0.05)) %>%
#    hyper_filter(time = times$`Available times` ==  44558) %>%
#    hyper_tibble(select_var = input_variables) %>%
#    st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant")
#  end_time <- Sys.time()
#  print(end_time - start_time)
#  head(Pulled_data_single_space_all_timepoints)

## ----filter_time_for_single_poing_with_error, cache=TRUE, eval=TRUE-----------
library(tibble)
# Year 2034
time_min <- 38716
time_max <- 73048
input_times <- inputs$available_times %>% 
  add_column(index = 0) %>% 
  add_column(first_half = 0) %>% 
  add_column(second_half = 0) 
input_times[which(inputs$available_times[,1] >= time_min & inputs$available_times[,1] <= time_max ),3] <- 1
med <- median(row_number(input_times[,3])) 
input_times[which(as.numeric(row.names(input_times)) <= med),4] <- 1
input_times[which(as.numeric(row.names(input_times)) > med),5] <- 1
tail(input_times)

## ----stitch_pull_for_single_poing, cache=TRUE, eval=FALSE---------------------
#  library(tidync)
#  Pulled_data_sub1 <- Pulled_data <- inputs$src %>%
#    hyper_filter(lat = lat <= c(center_point[4]+0.05) & lat >= c(center_point[2]-0.05)) %>%
#    hyper_filter(lon = lon <= c(center_point[3]+0.05) & lon >= c(center_point[1]-0.05)) %>%
#    hyper_filter(time =  input_times[,4] == 1) %>%
#    hyper_tibble(select_var = input_variables
#      )
#  Pulled_data_sub2 <- Pulled_data <- inputs$src %>%
#    hyper_filter(lat = lat <= c(center_point[4]+0.05) & lat >= c(center_point[2]-0.05)) %>%
#    hyper_filter(lon = lon <= c(center_point[3]+0.05) & lon >= c(center_point[1]-0.05)) %>%
#    hyper_filter(time =  input_times[,5] == 1) %>%
#    hyper_tibble(select_var = input_variables
#      )
#  tail(Pulled_data_sub1)
#  tail(Pulled_data_sub2)

## ----bounding_box_large, cache=TRUE-------------------------------------------
library(osmdata)
library(sf)
bb <- getbb("yellowstone")
bb_manual <- bb
bb_manual[1,1] <- -111.15594815937659
bb_manual[1,2] <- -109.8305463801207
bb_manual[2,1] <- 44.12354048271325
bb_manual[2,2] <- 45.11911641599412
my_boundary_yellow <- opq(bb_manual, timeout=300) %>% 
  add_osm_feature(key = "boundary", value = "national_park") %>% 
osmdata_sf() 
my_boundary_yellow
boundaries_large <- my_boundary_yellow$osm_multipolygons
pulled_bb_large <- st_bbox(boundaries_large)
pulled_bb_large

## ----plot_of_area_of_interest_large, cache=TRUE, warning=FALSE, fig.height=8----
library(ggplot2)
basemap <- ggplot(data = boundaries_large) +
  geom_sf(fill = "cornflowerblue") +
  suppressWarnings(geom_sf_text(aes(label = boundaries_large$name))) 
basemap

## ----filter_variables_few, cache=TRUE-----------------------------------------
input_variables <- inputs$variable_names %>% 
  filter(Variable %in% c( "Precipitation")) %>% 
  filter(Scenario %in% c( "RCP 8.5")) %>% 
  filter(Model %in% c(
             
 "Model for Interdisciplinary Research On Climate 5" )) %>%
  
  pull("Available variable")
input_variables

## ----pulled_data_for_small_area, cache=TRUE, eval=TRUE------------------------
library(tidync)
Pulled_data_large_area_few_variables <- inputs$src %>% 
  hyper_filter(lat = lat <= c(pulled_bb_large[4]+0.05) & lat >= c(pulled_bb_large[2]-0.05)) %>% 
  hyper_filter(lon = lon <= c(pulled_bb_large[3]+0.05) & lon >= c(pulled_bb_large[1]-0.05)) %>%
  hyper_filter(time = input_times$`Available times` ==  73048) %>% 
  hyper_tibble(select_var = input_variables
    ) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant")
head(Pulled_data_large_area_few_variables)
tail(Pulled_data_large_area_few_variables)

## ----plot pulled data for small area, eval=FALSE------------------------------
#  plot(Pulled_data_large_area_few_variables$time, Pulled_data_large_area_few_variables$`pr_MIROC5_r1i1p1_rcp85`)

## ----check_pulled_data_for_large_area, cache=TRUE, fig.height=8, eval=TRUE----
library(ggplot2)
check_filter <- Pulled_data_large_area_few_variables %>% filter(time == min(Pulled_data_large_area_few_variables$time))
ggplot() +
  geom_sf(data = boundaries_large, fill = "cornflowerblue") +
 geom_sf(data = check_filter, color = "red", size=0.5) +
  coord_sf(crs = 4326) 

## ----stitch_pull_for_large_area, cache=TRUE, eval=TRUE------------------------
library(tidync)
Pulled_data_sub1 <- inputs$src %>% 
  hyper_filter(lat = lat <= c(pulled_bb[4]+0.05) & lat >= c(pulled_bb[2]-0.05)) %>% 
  hyper_filter(lon = lon <= c(pulled_bb[3]+0.05) & lon >= c(pulled_bb[1]-0.05)) %>% 
  hyper_filter(time =  input_times[,4] == 1) %>% 
  hyper_tibble(select_var = input_variables) %>%  
  st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant")
Pulled_data_sub2 <- inputs$src %>% 
  hyper_filter(lat = lat <= c(pulled_bb[4]+0.05) & lat >= c(pulled_bb[2]-0.05)) %>% 
  hyper_filter(lon = lon <= c(pulled_bb[3]+0.05) & lon >= c(pulled_bb[1]-0.05)) %>% 
  hyper_filter(time =  input_times[,5] == 1) %>% 
  hyper_tibble(select_var = input_variables) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant")
tail(Pulled_data_sub1)
tail(Pulled_data_sub2)

## ----rbind_pulled_results_from_large_area, cache=TRUE, eval=TRUE--------------
Pulled_data_stitch <- bind_rows(Pulled_data_sub1, Pulled_data_sub2)

## ----plot_stitched_data, cache=TRUE, eval=TRUE--------------------------------
plot(Pulled_data_stitch$time, Pulled_data_stitch$`pr_MIROC5_r1i1p1_rcp85`)

## ----rasterize_with_stars, cache=TRUE, fig.height=7---------------------------
library(stars)
rast <- st_rasterize(Pulled_data_large_area_few_variables) 
plot(rast)

## ---- eval=TRUE---------------------------------------------------------------
library(terra)
library(tidyterra)
data <- rast(rast)

## ---- eval=TRUE---------------------------------------------------------------
library(terra)
points <- vect(as_Spatial(boundaries_large$geometry))
extracted <- terra::extract(data, points, xy=TRUE)

## ---- eval=TRUE---------------------------------------------------------------
names(extracted)[1] <- "nn"

## ---- eval=TRUE---------------------------------------------------------------
boundary_data <- vect(extracted, geom=c("x", "y"), crs="")
boundary_data

## ---- eval=TRUE---------------------------------------------------------------
plot(data$pr_MIROC5_r1i1p1_rcp85_lyr.1, main="Projected Humidity in 2040 in Yellowstone National Park")
points(boundary_data, col = 'blue', alpha=0.1)

## ----filter_time, cache=TRUE--------------------------------------------------
library(tibble)
# Year 2034
time_min <- 72048
time_max <- 73048
input_times <- inputs$available_times %>% add_column(index = 0) 
input_times[which(inputs$available_times[,1] > time_min & inputs$available_times[,1] < time_max ),3] <- 1
tail(input_times)

## ----filter_variables, cache=TRUE---------------------------------------------
input_variables <- inputs$variable_names %>% 
  filter(Variable == "Precipitation") %>% 
  filter(Model == c("Beijing Normal University - Earth System Model", "Hadley Global Environment Model 2 - Earth System 365 (day)")) %>%
  filter(Scenario == c( "RCP 8.5")) %>% 
  pull("Available variable")
input_variables

## ----bounding_box, cache=TRUE-------------------------------------------------
library(osmdata)
bb <- getbb("yellowstone")
bb_manual <- bb
bb_manual[1,1] <- -111.15594815937659
bb_manual[1,2] <- -109.8305463801207
bb_manual[2,1] <- 44.12354048271325
bb_manual[2,2] <- 45.11911641599412
my_boundary <- opq(bb_manual, timeout=300) %>% 
  add_osm_feature(key = "boundary", value = "national_park") %>% 
osmdata_sf() 
my_boundary

## ----pulled_bounding_box, cache=TRUE------------------------------------------
library(osmdata)
library(sf)
boundaries <- my_boundary$osm_multipolygons
pulled_bb <- st_bbox(boundaries)
pulled_bb

## ----plot_of_area_of_interest, cache=TRUE, warning=FALSE, fig.height=8--------
library(ggplot2)
basemap <- ggplot(data = boundaries) +
  geom_sf(fill = "cornflowerblue") +
  suppressWarnings(geom_sf_text(aes(label = boundaries$name))) 
basemap

## ----pulled_data, cache=TRUE--------------------------------------------------
library(tidync)
Pulled_data <- inputs$src %>% 
  hyper_filter(lat = lat <= c(pulled_bb[4]+0.05) & lat >= c(pulled_bb[2]-0.05)) %>% 
  hyper_filter(lon = lon <= c(pulled_bb[3]+0.05) & lon >= c(pulled_bb[1]-0.05)) %>% 
  hyper_filter(time =  input_times[,3] == 1) %>% 
  hyper_tibble(select_var = input_variables
    ) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant")
head(Pulled_data)

## ----check_pulled_data, cache=TRUE, fig.height=8, eval=TRUE-------------------
library(ggplot2)
check_filter <- Pulled_data %>% filter(time == min(Pulled_data$time))
ggplot() +
  geom_sf(data = boundaries, fill = "cornflowerblue") +
 geom_sf(data = check_filter, color = "red", size=0.5) +
  coord_sf(crs = 4326) 

## ----temp-midpoint, eval=TRUE-------------------------------------------------
library(tidync)
vars <- inputs$variable_names %>% 
  filter(Variable %in% c("Maximum Temperature", "Minimum Temperature", "Eastward Wind", "Northward Wind")) %>% 
  filter(Scenario %in% c("RCP 8.5")) %>% 
  filter(Model %in% c("Model for Interdisciplinary Research On Climate - Earth System Model" )) %>%
  pull("Available variable")
dat <- inputs$src %>% 
  hyper_filter(lat = lat <= c(pulled_bb_large[4]+0.05) & lat >= c(pulled_bb_large[2]-0.05)) %>% 
  hyper_filter(lon = lon <= c(pulled_bb_large[3]+0.05) & lon >= c(pulled_bb_large[1]-0.05)) %>%
  hyper_filter(time = input_times$`Available times` ==  73048) %>% 
  hyper_tibble(select_var = vars) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant")
head(dat)

## ---- eval=TRUE---------------------------------------------------------------
tasmax <- dat$`tasmax_MIROC-ESM_r1i1p1_rcp85`
tasmin <- dat$`tasmin_MIROC-ESM_r1i1p1_rcp85`
uas <- dat$`uas_MIROC-ESM_r1i1p1_rcp85`
vas <- dat$`vas_MIROC-ESM_r1i1p1_rcp85`
time <- dat$time
df <- data.frame(time, tasmax, tasmin, uas, vas)
head(df)

## ---- eval=TRUE---------------------------------------------------------------
df <- df %>%
  mutate(tasmid = (tasmax + tasmin) / 2)
head(df)

## ----wind-speed, eval=TRUE----------------------------------------------------
df <- df %>%
  mutate(wind_speed = sqrt(vas^2 + uas^2))
head(df)

## ---- eval=TRUE---------------------------------------------------------------
time_min <- inputs$available_times[which(inputs$available_times[,2] == '2019-12-31'),1]
time_max <- inputs$available_times[which(inputs$available_times[,2] == '2025-01-01'),1]

## ---- eval=TRUE---------------------------------------------------------------
input_times <- inputs$available_times
input_times$index <- rep(0, length(input_times$dates))
input_times[which(inputs$available_times[,1] > time_min & inputs$available_times[,1] < time_max ),3] <- 1
head(input_times)

## ---- eval=TRUE---------------------------------------------------------------
vars <- inputs$variable_names %>% 
  filter(Variable %in% c("Minimum Temperature", "Maximum Temperature")) %>% 
  filter(Scenario %in% c("RCP 8.5", "RCP 4.5")) %>% 
  filter(Model %in% c("Model for Interdisciplinary Research On Climate - Earth System Model", "Norwegian Earth System Model 1 - Medium Resolution")) %>%
  pull("Available variable")
vars

## ---- eval=TRUE---------------------------------------------------------------
library(tidync)
growing_data <- inputs$src %>% 
  hyper_filter(lat = lat <= c(44.5+0.05) & lat >= c(44.5-0.05)) %>% 
  hyper_filter(lon = lon <= c(-110.5+0.05) & lon >= c(-110.5-0.05)) %>% 
  hyper_filter(time =  input_times[,3] == 1) %>% 
  hyper_tibble(select_var = vars
    ) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant")
head(growing_data)

## -----------------------------------------------------------------------------
length(growing_data$time)

## -----------------------------------------------------------------------------
year <- rep(c(rep(2020, 4*366), rep(2021, 4*365), rep(2022, 4*365), rep(2023, 4*365), rep(2024, 4*366)), 4)
length(year)

## -----------------------------------------------------------------------------
rcp <- c(rep('rcp45', 7308), rep('rcp85', 7308), rep('rcp45', 7308), rep('rcp85', 7308))
length(rcp)

## -----------------------------------------------------------------------------
model <- c(rep('MIROC-ESM', 2*7308), rep('NorESM1-M', 2*7308))
length(model)

## -----------------------------------------------------------------------------
tasmax <- c(growing_data$`tasmax_MIROC-ESM_r1i1p1_rcp45`, growing_data$`tasmax_MIROC-ESM_r1i1p1_rcp85`, growing_data$`tasmax_NorESM1-M_r1i1p1_rcp45`, growing_data$`tasmax_NorESM1-M_r1i1p1_rcp85`)
tasmin <- c(growing_data$`tasmin_MIROC-ESM_r1i1p1_rcp45`, growing_data$`tasmin_MIROC-ESM_r1i1p1_rcp85`, growing_data$`tasmin_NorESM1-M_r1i1p1_rcp45`, growing_data$`tasmin_NorESM1-M_r1i1p1_rcp85`)

## ---- eval=TRUE---------------------------------------------------------------
df <- data.frame(tasmin, tasmax, year, rcp, model)
head(df)

## ---- eval=TRUE---------------------------------------------------------------
df <- df %>%
  mutate(tasmid = (tasmax + tasmin) / 2)
head(df)

## ----get-year, eval=FALSE-----------------------------------------------------
#  #df <- df %>%
#    #mutate(year = year(date))

## ----grow-season, eval=FALSE--------------------------------------------------
#  growing_seasons <- df %>%
#    group_by(year) %>%
#    mutate(season_length = sum(tasmid > 273.15))

## ----glimpse-grow-season, eval=FALSE------------------------------------------
#  growing_seasons

## ----plot-grow-season, fig.height = 5, fig.width = 6, eval=FALSE--------------
#  library(ggplot2)
#  growing_seasons %>%
#    ggplot(aes(x = year, y = season_length, color = rcp)) +
#    geom_line(alpha = .3) +
#    xlab("Year") +
#    ylab("Growing season length (days)") +
#    scale_color_manual(values = c("dodgerblue", "red")) +
#    theme(legend.position = "none")

## ---- eval=TRUE---------------------------------------------------------------
time_min <- inputs$available_times[which(inputs$available_times[,2] == '2019-12-31'),1]
time_max <- inputs$available_times[which(inputs$available_times[,2] == '2031-01-01'),1]

## ---- eval=TRUE---------------------------------------------------------------
input_times <- inputs$available_times
input_times$index <- rep(0, length(input_times$dates))
input_times[which(inputs$available_times[,1] > time_min & inputs$available_times[,1] < time_max ),3] <- 1
tail(input_times)

## ---- eval=TRUE---------------------------------------------------------------
vars <- inputs$variable_names %>% 
  filter(Variable %in% c("Precipitation", "Maximum Temperature")) %>% 
  filter(Scenario %in% c("RCP 8.5", "RCP 4.5")) %>% 
  filter(Model %in% c("Model for Interdisciplinary Research On Climate - Earth System Model", "Norwegian Earth System Model 1 - Medium Resolution")) %>%
  pull("Available variable")
vars

## ---- eval=TRUE---------------------------------------------------------------
library(tidync)
climate_data <- inputs$src %>% 
  hyper_filter(lat = lat <= c(44.5+0.05) & lat >= c(44.5-0.05)) %>% 
  hyper_filter(lon = lon <= c(-110.5+0.05) & lon >= c(-110.5-0.05)) %>% 
  hyper_filter(time =  input_times[,3] == 1) %>% 
  hyper_tibble(select_var = vars
    ) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, agr = "constant")
head(climate_data)

## -----------------------------------------------------------------------------
length(climate_data$time)

## -----------------------------------------------------------------------------
year <- rep(c(rep(2020, 4*366), rep(2021, 4*365), rep(2022, 4*365), rep(2023, 4*365), rep(2024, 4*366), rep(2025, 4*365), rep(2026, 4*365), rep(2027, 4*365), rep(2028, 4*366), rep(2029, 4*365), rep(2030, 4*365)), 4)
length(year)

## -----------------------------------------------------------------------------
rcp <- c(rep('rcp45', 16072), rep('rcp85', 16072), rep('rcp45', 16072), rep('rcp85', 16072))
length(rcp)

## -----------------------------------------------------------------------------
model <- c(rep('MIROC-ESM', 2*16072), rep('NorESM1-M', 2*16072))
length(model)

## -----------------------------------------------------------------------------
pr <- c(climate_data$`pr_MIROC-ESM_r1i1p1_rcp45`, climate_data$`pr_MIROC-ESM_r1i1p1_rcp85`, climate_data$`pr_NorESM1-M_r1i1p1_rcp45`, climate_data$`pr_NorESM1-M_r1i1p1_rcp85`)
length(pr)

## -----------------------------------------------------------------------------
tasmax <- c(climate_data$`tasmax_MIROC-ESM_r1i1p1_rcp45`, climate_data$`tasmax_MIROC-ESM_r1i1p1_rcp85`, climate_data$`tasmax_NorESM1-M_r1i1p1_rcp45`, climate_data$`tasmax_NorESM1-M_r1i1p1_rcp85`)
length(tasmax)

## ----comps, eval=FALSE--------------------------------------------------------
#  #comps <- compare_periods(df,
#                           #var1 = "pr",
#                           #var2 = "tasmax",
#                           #agg_fun = "mean",
#                           #target_period = c(2025, 2030),
#                           #reference_period = c(2020, 2024),
#                           #scenarios = c("rcp45", "rcp85"))

## ----glimpse-comps, eval=FALSE------------------------------------------------
#  #glimpse(comps)

## ----plot-comps, fig.height = 6, fig.width = 9, eval=FALSE--------------------
#  NA

## ----pull_river_data, fig.height=10, cache=TRUE-------------------------------
river <- opq(bb_manual, timeout=300) %>%
  add_osm_feature(key = "waterway", value = "river") %>%
  osmdata_sf() 
river

## ---- eval=TRUE---------------------------------------------------------------
library(terra)
river_sub <- st_buffer(river$osm_lines, 2200)
river_points <- vect(as_Spatial(river_sub))
extracted_river <- terra::extract(data, river_points, xy=TRUE)

## ---- eval=TRUE---------------------------------------------------------------
head(extracted_river)
colnames(extracted_river)[1] <- "pre"

## ---- eval=TRUE---------------------------------------------------------------
river_data <- vect(extracted_river, geom=c("x", "y"), crs="")
river_data

## ---- eval=TRUE---------------------------------------------------------------
plot(data$pr_MIROC5_r1i1p1_rcp85_lyr.1, main="Rivers of Yellowstone \n Projected humidity in 2040")
points(river_data, col = river_data$pre)

## ---- eval=TRUE---------------------------------------------------------------
data_extent <- ext(data)
data_extent

## ---- eval=TRUE---------------------------------------------------------------
xmin <- data_extent$xmin[[1]]
xmax <- data_extent$xmax[[1]]
ymin <- data_extent$ymin[[1]]
ymax <- data_extent$ymax[[1]]

## ---- eval=TRUE---------------------------------------------------------------
resy <- yres(data)
resx <- xres(data)

## ---- eval=TRUE---------------------------------------------------------------
template <- rast(crs = "WGS84", xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, resolution = resx)
template

## ---- eval=TRUE---------------------------------------------------------------
plot(template, main="Rivers of Yellowstone \n Projected humidity in 2040")
points(river_data, col = river_data$pre)

## ---- eval=TRUE---------------------------------------------------------------
library(terra)
roads <- opq(pulled_bb_large, timeout=300) %>%
  add_osm_feature(key = 'highway', value = 'primary') %>%
  add_osm_feature(key = 'highway', value = 'secondary') %>%
  osmdata_sf() 
roads_sub <- st_buffer(roads$osm_lines, 2200)
road_points <- vect(as_Spatial(roads_sub))
extracted_roads <- terra::extract(data, road_points, xy=TRUE)
colnames(extracted_roads)[1] <- "pre"

## ---- eval=TRUE---------------------------------------------------------------
road_data <- vect(extracted_roads, geom=c("x", "y"), crs="")
road_data

## ---- eval=TRUE---------------------------------------------------------------
plot(data$pr_MIROC5_r1i1p1_rcp85_lyr.1, main="Roads of Yellowstone \n Projected humidity in 2040")
points(road_data, col = road_data$pre)

## ---- eval=TRUE---------------------------------------------------------------
plot(template, main="Roads of Yellowstone \n Projected humidity in 2040")
points(road_data, col = road_data$pre)

