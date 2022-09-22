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

