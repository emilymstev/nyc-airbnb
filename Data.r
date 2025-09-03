library(dplyr)
library(shiny)
library(readxl)
library(leaflet)
library(tidyverse)

setwd("C:/Users/Emily Stevenson/OneDrive/Documents/Project 2")

# Read AirBnB data
airbnb <- read_csv("AB_NYC_2019.csv")
census_detail <- read_csv("nyc_census_tracts.csv")

# Perform summary stats across each neighborhood group
census_detail <- census_detail %>%
  group_by(Borough) %>%
  summarize(
    `Total Population` = sum(TotalPop, na.rm = TRUE),
    `Percentage Below Poverty` = mean(Poverty, na.rm = TRUE),
    `Transit Percentage` = mean(Transit, na.rm = TRUE),
    `Walking Percentage` = mean(Walk, na.rm = TRUE)
  )

# Merge the data and rename a few columns for better labeling
census_full <- left_join(airbnb, census_detail,  by = c("neighbourhood_group" = "Borough")) %>%
  rename(
    `Price` = price, 
    `Availability (365 days)` = availability_365,
    `Number of Reviews` = number_of_reviews,
    Name = name,
    Host = host_name
  )

# Aggregate both datasets for shiny app use. Return them as a list
get_aggregated_data <- function() {
  aggregated_data_list <- list(census_full = census_full, census_detail = census_detail)
  return(aggregated_data_list)
}