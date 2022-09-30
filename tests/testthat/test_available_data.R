test_that("Verify that available_data runs and returns something reasonable", {
  skip_on_cran()
  skip_if_offline(host = "r-project.org")
  
  library(cft)
  
	inputs <- cft::available_data()
	
	# First check the variables that were returned
	vars <- levels(as.factor(inputs$variable_names$Variable))
	expect_gt(length(vars), 0)

	# These are the only variables expected / parsed into columns by available_data 
	expected_variables = c("Eastward Wind", "Maximum Relative Humidity", "Maximum Temperature", 
			       "Minimum Relative Humidity", "Minimum Temperature", "Northward Wind",
 			       "Precipitation", "Specific Humidity", "Surface Downswelling Shortwave Flux",
			       "Vapor Pressure Deficit"
			)

        for (variable in vars) {
		expect_true(variable %in% expected_variables)
	}
	
	# Verify the scenarios
	scenarios <- levels(as.factor(inputs$variable_names$Scenario))
	expect_gt(length(scenarios), 0)
	
	# These are the only scenarios expected / parsed into columns by available_data
	expected_scenarios = c("RCP 4.5", "RCP 8.5")
	for (scenario in scenarios) {
		expect_true(scenario %in% expected_scenarios)
	}

	# Verify the models 
	models <- levels(as.factor(inputs$variable_names$Model))
	expect_gt(length(models), 0)
	
	# These are the only models expected / parsed into columns by avaialable_data
	expected_models <- c("Beijing Climate Center - Climate System Model 1.1",
			     "Beijing Climate Center - Climate System Model 1.1 Moderate Resolution",
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
			     "Norwegian Earth System Model 1 - Medium Resolution")

	for (model in models) {
		expect_true(model %in% expected_models)
	}

	# Verify the amount of data returned is not zero
        expect_gt(length(inputs$variable_names$'Available variable'), 0)
	
	# Verify the amount of available times is not zero
	expect_gt(length(inputs$available_times$"Available times"), 0)

	# Verify the source is still intact and the counts are all non-zero
	for (count in inputs$src$dimension$count) {
		expect_gt(count, 0)
	}
	
	# Verify all of the column names are what are expected
	expected_variable_colnames <- c("Available variable",
                                  "Variable",
                                  "Units",
                                  "Model",
                                  "Model ensemble type (only CCSM4 relevant)",
                                  "Scenario",
                                  "Variable abbreviation",
                                  "Model abbreviation",
                                  "Scenario abbreviation")
	expect_setequal(colnames(inputs$variable_names), expected_variable_colnames)
	
	expected_available_times_colnames <- c("Available times", "dates")
	expect_setequal(colnames(inputs$available_times), expected_available_times_colnames)

}
)
